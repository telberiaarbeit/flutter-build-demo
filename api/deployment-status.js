const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;
const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const BRANCH = 'web-build'; // or 'web-build'

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  try {
    // 1. Get latest GitHub Actions run
    const actionsResp = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
      {
        headers: {
          Authorization: `token ${GITHUB_TOKEN}`,
          Accept: 'application/vnd.github+json',
        },
      }
    );
    const actionsData = await actionsResp.json();
    const latestRun = actionsData.workflow_runs?.[0];

    if (!latestRun) {
      return res.status(404).json({ error: 'No GitHub Actions runs found' });
    }

    const gitStatus = latestRun.status;
    const gitConclusion = latestRun.conclusion;
    const gitSha = latestRun.head_sha;

    const gitSuccess = gitStatus === 'completed' && gitConclusion === 'success';

    // 2. Get latest deployment from Vercel
    const vercelResp = await fetch(
      `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=1`,
      {
        headers: { Authorization: `Bearer ${VERCEL_TOKEN}` },
      }
    );
    const vercelData = await vercelResp.json();

    if (!vercelData.deployments?.length) {
      return res.status(404).json({ error: 'No Vercel deployments found' });
    }

    const latestDeployment = vercelData.deployments[0];
    const deployedSha = latestDeployment.meta?.githubCommitSha || 'unknown';
    const vercelReady = latestDeployment.state === 'READY';

    const upToDate = gitSuccess && vercelReady && deployedSha === gitSha;

    res.status(200).json({
      github: {
        status: gitStatus,
        conclusion: gitConclusion,
        sha: gitSha,
        url: latestRun.html_url,
      },
      vercel: {
        status: latestDeployment.state,
        deployedSha,
        url: `https://${latestDeployment.url}`,
      },
      upToDate,
      previewUrl: upToDate ? `https://${latestDeployment.url}` : null,
    });
  } catch (error) {
    console.error('Check deployment error:', error);
    res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
