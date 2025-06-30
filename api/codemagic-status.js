const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const CODEMAGIC_TOKEN = process.env.CODEMAGIC_TOKEN;
const CODEMAGIC_APP_ID = process.env.CODEMAGIC_APP_ID;
const WORKFLOW_ID = process.env.WORKFLOW_ID;

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

    // Step 4: Filter key artifacts
    const android = codemagicArtifacts.find(a => a.name.endsWith('.apk') || a.name.endsWith('.aab'))?.url || null;
    const ios = codemagicArtifacts.find(a => a.name.endsWith('.ipa'))?.url || null;
    const web = codemagicArtifacts.find(a => a.name === 'web.zip')?.url || null;

    return res.status(200).json({
      status: 'READY',
      codemagicStatus,
      codemagicBuildId,
      artifacts: {
        android,
        ios,
        web
      },
      allArtifacts: codemagicArtifacts,
    });

  } catch (err) {
    console.error('Error checking Codemagic status:', err);
    return res.status(500).json({ error: 'Failed to check Codemagic status' });
  }
}
