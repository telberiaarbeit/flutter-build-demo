const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;

const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  const BRANCH = req.query.secret_code;
  if (!BRANCH) {
    return res.status(400).json({ error: 'Missing secret_code (branch name)' });
  }

  try {
    const maxRetries = 12;
    const delay = (ms) => new Promise((r) => setTimeout(r, ms));
    await delay(2500);

    let gitStatus = null;
    let gitConclusion = null;
    let gitSha = null;

    // Poll GitHub Actions for latest run status
    for (let i = 0; i < maxRetries; i++) {
      const githubResp = await fetch(
        `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
        {
          headers: { Authorization: `token ${GITHUB_TOKEN}` },
        }
      );
      const githubData = await githubResp.json();
      const latestRun = githubData.workflow_runs?.[0];
      gitStatus = latestRun?.status;
      gitConclusion = latestRun?.conclusion;
      gitSha = latestRun?.head_sha;

      if (gitStatus === 'completed') break;
      await delay(2500);
    }

    if (gitStatus !== 'completed' || gitConclusion !== 'success' || !gitSha) {
      return res.status(200).json({
        status: 'DEPLOYING',
        message: 'GitHub Actions not completed or failed.',
        gitStatus,
        gitConclusion,
        gitSha,
      });
    }

    // Poll Vercel for the correct build-triggered deployment
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
        ?.filter(
          (d) =>
            d.meta?.githubCommitRef?.toLowerCase() === BRANCH.toLowerCase() &&
            typeof d.meta?.githubMessage === 'string' &&
            d.meta.githubMessage.startsWith('Deploy Flutter web build from branch')
        )
        .sort((a, b) => b.createdAt - a.createdAt)?.[0];

      if (matchedDeployment?.state === 'READY') break;
      if (!matchedDeployment || matchedDeployment.state === 'ERROR') break;

      await delay(2500);
    }

    return res.status(200).json({
      status: matchedDeployment?.state === 'READY' ? 'READY' : 'DEPLOYING',
      deploymentUrl: matchedDeployment ? `https://${matchedDeployment.url}` : null,
      gitStatus,
      gitConclusion,
      gitSha,
      matchedCommit: matchedDeployment?.meta?.githubCommitSha || null,
      matchedBranch: matchedDeployment?.meta?.githubCommitRef || null,
      commitMessage: matchedDeployment?.meta?.githubMessage || null
    });

  } catch (error) {
    console.error('Deployment check error:', error);
    return res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
