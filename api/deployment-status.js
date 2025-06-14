const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;

const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const BRANCH = 'web-build';

const POLL_INTERVAL_MS = 3000;
const MAX_ATTEMPTS = 40;

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  try {
    // Step 1: Get latest GitHub Actions run
    const ghResp = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
      { headers: { Authorization: `token ${GITHUB_TOKEN}` } }
    );
    const ghData = await ghResp.json();
    const latestRun = ghData.workflow_runs?.[0];

    if (!latestRun) {
      return res.status(404).json({ error: 'No GitHub Actions run found' });
    }

    const runId = latestRun.id;
    const gitSha = latestRun.head_sha;

    // Step 2: Wait if GitHub is still building
    let attempt = 0;
    while (
      ['in_progress', 'queued', 'waiting'].includes(latestRun.status) &&
      attempt < MAX_ATTEMPTS
    ) {
      await new Promise(r => setTimeout(r, POLL_INTERVAL_MS));

      const statusResp = await fetch(
        `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs/${runId}`,
        { headers: { Authorization: `token ${GITHUB_TOKEN}` } }
      );
      const statusData = await statusResp.json();
      if (statusData.status === 'completed') break;

      attempt++;
    }

    // Step 3: Check latest Vercel deployment
    const vercelResp = await fetch(
      `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=5`,
      {
        headers: {
          Authorization: `Bearer ${VERCEL_TOKEN}`,
        },
      }
    );
    const vercelData = await vercelResp.json();

    const deployment = vercelData.deployments?.find(
      (d) => d.meta?.githubCommitSha === gitSha
    );

    if (!deployment) {
      return res.status(200).json({ status: 'DEPLOYING', deploymentUrl: null });
    }

    return res.status(200).json({
      status: deployment.state === 'READY' ? 'READY' : 'DEPLOYING',
      deploymentUrl: deployment.state === 'READY' ? `https://${deployment.url}` : null,
    });

  } catch (error) {
    console.error('Error during check:', error?.message || error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
