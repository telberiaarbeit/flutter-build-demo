const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;

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
    let attempt = 0;
    let latestRun, gitStatus, gitConclusion, gitSha;

    // Step 1: Wait for GitHub Actions to complete
    while (attempt < MAX_ATTEMPTS) {
      const githubResp = await fetch(
        `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
        {
          headers: { Authorization: `token ${GITHUB_TOKEN}` },
        }
      );
      const githubData = await githubResp.json();
      latestRun = githubData.workflow_runs?.[0];

      gitStatus = latestRun?.status;
      gitConclusion = latestRun?.conclusion;
      gitSha = latestRun?.head_sha;

      if (gitStatus === 'completed' && gitConclusion === 'success') break;

      await new Promise(r => setTimeout(r, POLL_INTERVAL_MS));
      attempt++;
    }

    if (!gitSha || gitConclusion !== 'success') {
      return res.status(200).json({
        status: gitStatus || 'unknown',
        deploymentUrl: null,
      });
    }

    // Step 2: Wait for a Vercel deployment matching that SHA and state === READY
    attempt = 0;
    let deploymentUrl = null;
    while (attempt < MAX_ATTEMPTS) {
      const vercelResp = await fetch(
        `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=5`,
        {
          headers: { Authorization: `Bearer ${VERCEL_TOKEN}` },
        }
      );
      const vercelData = await vercelResp.json();

      const matched = vercelData.deployments?.find(
        (d) =>
          d.meta?.githubCommitSha === gitSha &&
          d.state === 'READY'
      );

      if (matched) {
        deploymentUrl = matched.url;
        break;
      }

      await new Promise(r => setTimeout(r, POLL_INTERVAL_MS));
      attempt++;
    }

    return res.status(200).json({
      status: deploymentUrl ? 'READY' : 'DEPLOYING',
      deploymentUrl: deploymentUrl || null,
    });

  } catch (err) {
    console.error('Error during deploy check:', err);
    return res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
