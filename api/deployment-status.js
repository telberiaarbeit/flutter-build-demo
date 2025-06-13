const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;

const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const BRANCH = 'web-build'; // or 'web-build'

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  try {
    // Get latest GitHub Actions run
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

    // Get latest Vercel deployment
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

    const bothSuccess =
      gitStatus === 'completed' &&
      gitConclusion === 'success' &&
      vercelState === 'READY' &&
      gitSha === vercelSha;


    return res.status(200).json({
      status: gitStatus === 'completed' ? vercelState : gitStatus,
      deploymentUrl: gitStatus === 'completed' && vercelState === 'READY'
        ? latestDeployment.url
        : null,
    });
  } catch (error) {
    console.error('Error checking deploy status:', error);
    res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
