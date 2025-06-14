const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;

const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  const branch = req.query.secret_code || 'web-build';

  try {
    // Step 1: Get latest GitHub Action run for the branch
    const ghResp = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${branch}&per_page=1`,
      {
        headers: {
          Authorization: `token ${GITHUB_TOKEN}`,
          Accept: 'application/vnd.github+json',
        },
      }
    );
    const ghData = await ghResp.json();
    const latestRun = ghData.workflow_runs?.[0];

    if (!latestRun) {
      return res.status(404).json({ error: `No GitHub Actions run found for branch "${branch}"` });
    }

    // Step 2: Get latest Vercel deployments
    const vercelResp = await fetch(
      `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=10`,
      {
        headers: {
          Authorization: `Bearer ${VERCEL_TOKEN}`,
        },
      }
    );
    const vercelData = await vercelResp.json();

    // Step 3: Match deployment by branch in name or meta
    const matched = vercelData.deployments?.find(
      (d) =>
        (d.meta?.githubBranch === branch || d.name.includes(branch)) &&
        d.state === 'READY'
    );

    return res.status(200).json({
      status: matched ? 'READY' : 'DEPLOYING',
      deploymentUrl: matched ? `https://${matched.url}` : null,
    });
  } catch (err) {
    console.error('Deployment check error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
