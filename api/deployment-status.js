const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;

const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const BRANCH = 'web-build';

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  const maxAttempts = 20; // 20 x 5s = 100s timeout
  let attempt = 0;

  while (attempt < maxAttempts) {
    attempt++;

    try {
      // Check GitHub Actions status
      const githubResp = await fetch(
        `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
        {
          headers: {
            Authorization: `token ${GITHUB_TOKEN}`,
          },
        }
      );
      const githubData = await githubResp.json();
      const latestRun = githubData.workflow_runs?.[0];

      const gitStatus = latestRun?.status;
      const gitConclusion = latestRun?.conclusion;
      const gitSha = latestRun?.head_sha;

      // If GitHub hasn't finished yet, wait and retry
      if (gitStatus !== 'completed' || gitConclusion !== 'success') {
        await sleep(5000);
        continue;
      }

      // Check Vercel deploy status
      const vercelResp = await fetch(
        `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=1`,
        {
          headers: {
            Authorization: `Bearer ${VERCEL_TOKEN}`,
          },
        }
      );
      const vercelData = await vercelResp.json();
      const latestDeployment = vercelData.deployments?.[0];

      const vercelState = latestDeployment?.state;
      const vercelSha = latestDeployment?.meta?.githubCommitSha;

      const bothReady = vercelState === 'READY' && gitSha === vercelSha;

      if (bothReady) {
        return res.status(200).json({
          status: 'READY',
          deploymentUrl: `https://${latestDeployment.url}`,
        });
      }

      // Git done, but Vercel not yet ready – wait
      await sleep(5000);

    } catch (err) {
      console.error('Error during deploy check:', err);
      return res.status(500).json({ error: 'Error checking deployment status' });
    }
  }

  // Timeout reached
  return res.status(202).json({ status: 'IN_PROGRESS', deploymentUrl: null });
}
