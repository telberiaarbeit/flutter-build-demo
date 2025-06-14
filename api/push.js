const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;

const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';

const POLL_INTERVAL_MS = 3000;
const MAX_ATTEMPTS = 40;

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  const branch = req.query.secret_code || 'web-build'; // dynamic

  try {
    const ghResp = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${branch}&per_page=1`,
      { headers: { Authorization: `token ${GITHUB_TOKEN}` } }
    );
    const ghData = await ghResp.json();
    const latestRun = ghData.workflow_runs?.[0];

    if (!latestRun) {
      return res.status(404).json({ error: `No GitHub Actions run found for branch "${branch}"` });
    }

    const runId = latestRun.id;
    const gitSha = latestRun.head_sha;

    // Optionally wait if build is running (1 short check)
    let statusCheck = latestRun.status;
    if (['in_progress', 'queued'].includes(statusCheck)) {
      const checkResp = await fetch(
        `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs/${runId}`,
        { headers: { Authorization: `token ${GITHUB_TOKEN}` } }
      );
      const checkData = await checkResp.json();
      statusCheck = checkData.status;
    }

    // Step 2: Check Vercel deployments
    const vercelResp = await fetch(
      `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=5`,
      {
        headers: {
          Authorization: `Bearer ${VERCEL_TOKEN}`,
        },
      }
    );
    const vercelData = await vercelResp.json();

    const matched = vercelData.deployments?.find(
      (d) => d.meta?.githubCommitSha === gitSha
    );

    return res.status(200).json({
      status: matched?.state === 'READY' ? 'READY' : 'DEPLOYING',
      deploymentUrl: matched?.state === 'READY' ? `https://${matched.url}` : null,
    });

  } catch (err) {
    console.error('Deployment check error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
