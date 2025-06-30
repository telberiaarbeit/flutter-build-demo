const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const CODEMAGIC_TOKEN = process.env.CODEMAGIC_TOKEN;
const CODEMAGIC_APP_ID = process.env.CODEMAGIC_APP_ID;
const WORKFLOW_ID = process.env.WORKFLOW_ID;
const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  const BRANCH = req.query.branch;
  if (!BRANCH) {
    return res.status(400).json({ error: 'Missing branch name' });
  }

  const delay = (ms) => new Promise((r) => setTimeout(r, ms));
  const maxRetries = 10;
  const retryDelay = 3000;

  let codemagicStatus = null;
  let codemagicBuildId = null;
  let codemagicArtifacts = [];

  try {
    // Step 1: Get latest build ID from branch
    for (let i = 0; i < maxRetries; i++) {
      const url = `https://api.codemagic.io/builds?appId=${CODEMAGIC_APP_ID}&workflow_id=${WORKFLOW_ID}&branch=${BRANCH}&limit=1`;
      const resp = await fetch(url, {
        headers: { Authorization: `Bearer ${CODEMAGIC_TOKEN}` },
      });

      const data = await resp.json();
      const latestBuild = data?.[0];
      codemagicBuildId = latestBuild?.id;

      if (codemagicBuildId) break;
      await delay(retryDelay);
    }

    if (!codemagicBuildId) {
      return res.status(200).json({
        status: 'DEPLOYING',
        codemagicStatus: null,
        message: 'No build found for branch.',
      });
    }

    // Step 2: Poll full build status
    for (let i = 0; i < maxRetries; i++) {
      const buildResp = await fetch(
        `https://api.codemagic.io/builds/${codemagicBuildId}`,
        {
          headers: { Authorization: `Bearer ${CODEMAGIC_TOKEN}` },
        }
      );
      const buildData = await buildResp.json();
      codemagicStatus = buildData?.status;

      if (codemagicStatus === 'finished' || codemagicStatus === 'failed') break;
      await delay(retryDelay);
    }

    if (codemagicStatus !== 'finished') {
      return res.status(200).json({
        status: 'DEPLOYING',
        codemagicStatus,
        codemagicBuildId,
        message: 'Codemagic build not yet complete.',
      });
    }

    // Step 3: Fetch artifacts
    const artifactResp = await fetch(
      `https://api.codemagic.io/builds/${codemagicBuildId}/artifacts`,
      {
        headers: { Authorization: `Bearer ${CODEMAGIC_TOKEN}` },
      }
    );
    const artifacts = await artifactResp.json();
    codemagicArtifacts = artifacts?.map((a) => ({
      name: a.name,
      url: a.url,
    })) || [];

    // Step 4: Extract specific links
    const android = codemagicArtifacts.find(a => a.name.endsWith('.apk') || a.name.endsWith('.aab'))?.url || null;
    const ios = codemagicArtifacts.find(a => a.name.endsWith('.ipa'))?.url || null;
    const web = codemagicArtifacts.find(a => a.name === 'web.zip')?.url || null;

    // Step 5: Poll Vercel deployment
    let matchedDeployment = null;
    for (let i = 0; i < maxRetries; i++) {
      const vercelResp = await fetch(
        `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=20`,
        {
          headers: { Authorization: `Bearer ${VERCEL_TOKEN}` },
        }
      );

      const vercelData = await vercelResp.json();
      matchedDeployment = vercelData.deployments
        ?.filter(d => d.meta?.githubCommitRef?.toLowerCase() === BRANCH.toLowerCase())
        .sort((a, b) => b.createdAt - a.createdAt)?.[0];

      if (matchedDeployment?.state === 'READY' || matchedDeployment?.state === 'ERROR') break;
      await delay(2500);
    }

    return res.status(200).json({
      status: matchedDeployment?.state === 'READY' ? 'READY' : 'DEPLOYING',
      codemagicStatus,
      codemagicBuildId,
      vercelState: matchedDeployment?.state || null,
      vercelBranch: matchedDeployment?.meta?.githubCommitRef || null,
      deploymentUrl: matchedDeployment ? `https://${matchedDeployment.url}` : null,
      artifacts: {
        android,
        ios,
        web
      },
      allArtifacts: codemagicArtifacts,
    });

  } catch (err) {
    console.error('Error checking status:', err);
    return res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
