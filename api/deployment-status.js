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
    // 1. Get latest GitHub Actions run for the branch
    const githubResp = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
      {
        headers: { Authorization: `token ${GITHUB_TOKEN}` },
      }
    );
    const githubData = await githubResp.json();
    const latestRun = githubData.workflow_runs?.[0];

    const gitStatus = latestRun?.status;
    const gitConclusion = latestRun?.conclusion;
    const gitSha = latestRun?.head_sha;

    // 2. Get recent Vercel deployments
    const vercelResp = await fetch(
      `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=20`,
      {
        headers: { Authorization: `Bearer ${VERCEL_TOKEN}` },
      }
    );
    const vercelData = await vercelResp.json();

    // 3. Match by SHA exactly
    const matchedDeployment = vercelData.deployments
      ?.filter(
        (d) =>
          d.state === 'READY' &&
          d.meta?.githubCommitSha?.toLowerCase() === gitSha?.toLowerCase()
      )
      .sort((a, b) => b.createdAt - a.createdAt)?.[0];

    return res.status(200).json({
      status:
        gitStatus === 'completed' &&
        gitConclusion === 'success' &&
        matchedDeployment
          ? 'READY'
          : 'DEPLOYING',
      deploymentUrl: matchedDeployment ? `https://${matchedDeployment.url}` : null,
      gitStatus,
      gitConclusion,
      gitSha,
      matchedCommit: matchedDeployment?.meta?.githubCommitSha || null,
      matchedBranch: matchedDeployment?.meta?.githubCommitRef || null
    });

  } catch (error) {
    console.error('Deployment check error:', error);
    return res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
