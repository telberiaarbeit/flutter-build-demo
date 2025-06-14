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
    const maxRetries = 12; // Wait max 60s
    const delay = (ms) => new Promise((r) => setTimeout(r, ms));

    // Fetch GitHub info once
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

    // No GitHub run? Return
    if (!gitSha) {
      return res.status(200).json({ status: 'NO_DEPLOY', message: 'No GitHub run found for this branch.' });
    }

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
            d.meta?.githubCommitSha?.toLowerCase() === gitSha.toLowerCase()
        )
        .sort((a, b) => b.createdAt - a.createdAt)?.[0];

      if (matchedDeployment?.state === 'READY') break;
      if (!matchedDeployment || matchedDeployment.state === 'ERROR') break;

      await delay(5000); // wait 5 seconds before retrying
      console.log(`Retrying... (${i + 1}/${maxRetries})`);
    }

    return res.status(200).json({
      status:
        gitStatus === 'completed' &&
        gitConclusion === 'success' &&
        matchedDeployment?.state === 'READY'
          ? 'READY'
          : matchedDeployment
          ? 'DEPLOYING'
          : 'NO_DEPLOY',
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
