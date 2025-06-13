const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;
const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  try {
    // Get latest deployment from Vercel
    const vercelResp = await fetch(
      `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=1`,
      { headers: { Authorization: `Bearer ${VERCEL_TOKEN}` } }
    );
    const vercelData = await vercelResp.json();

    if (!vercelData.deployments?.length) {
      return res.status(404).json({ error: 'No Vercel deployments found' });
    }

    const latestDeployment = vercelData.deployments[0];
    const deployedCommitSha = latestDeployment.meta?.githubCommitSha || 'unknown';

    // Get latest GitHub commit SHA from main
    const githubResp = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/commits/main`,
      { headers: { Authorization: `token ${GITHUB_TOKEN}` } }
    );
    const githubData = await githubResp.json();
    const latestCommitSha = githubData.sha;

    res.status(200).json({
      status: latestDeployment.state,
      deploymentUrl: `https://${latestDeployment.url}`,
      deployedCommitSha,
      latestCommitSha,
      upToDate: deployedCommitSha === latestCommitSha,
    });
  } catch (error) {
    console.error('Check deployment error:', error);
    res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
