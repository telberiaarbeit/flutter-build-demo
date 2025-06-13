const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const VERCEL_TOKEN = process.env.VERCEL_TOKEN;
const VERCEL_PROJECT_ID = process.env.VERCEL_PROJECT_ID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;

const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const BRANCH = 'web-build';

async function getGitHubStatus() {
  const resp = await fetch(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
    {
      headers: { Authorization: `token ${GITHUB_TOKEN}` },
    }
  );
  const data = await resp.json();
  const latestRun = data.workflow_runs?.[0];
  return {
    status: latestRun?.status,
    conclusion: latestRun?.conclusion,
    sha: latestRun?.head_sha,
    url: latestRun?.html_url,
  };
}

async function getVercelStatus() {
  const resp = await fetch(
    `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=1`,
    {
      headers: { Authorization: `Bearer ${VERCEL_TOKEN}` },
    }
  );
  const data = await resp.json();
  const deployment = data.deployments?.[0];
  return {
    status: deployment?.state,
    sha: deployment?.meta?.githubCommitSha,
    url: deployment?.url,
  };
}

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  try {
    const timeout = 120 * 1000; // 60 seconds max
    const interval = 3000; // poll every 3 seconds
    const startTime = Date.now();

    let gitStatus, gitConclusion, gitSha, gitUrl;
    while (Date.now() - startTime < timeout) {
      const git = await getGitHubStatus();
      gitStatus = git.status;
      gitConclusion = git.conclusion;
      gitSha = git.sha;
      gitUrl = git.url;

      if (gitStatus === 'completed') break;
      await new Promise((r) => setTimeout(r, interval));
    }

    if (gitStatus !== 'completed' || gitConclusion !== 'success') {
      return res.status(200).json({
        status: gitStatus,
        deploymentUrl: null,
        github: { status: gitStatus, conclusion: gitConclusion, sha: gitSha, url: gitUrl },
        vercel: null,
      });
    }

    let vercelStatus, vercelSha, vercelUrl;
    while (Date.now() - startTime < timeout) {
      const vercel = await getVercelStatus();
      vercelStatus = vercel.status;
      vercelSha = vercel.sha;
      vercelUrl = vercel.url;

      const matched = gitSha === vercelSha && vercelStatus === 'READY';
      if (matched) {
        return res.status(200).json({
          status: 'READY',
          deploymentUrl: `https://${vercelUrl}`,
          github: { status: gitStatus, conclusion: gitConclusion, sha: gitSha, url: gitUrl },
          vercel: { status: vercelStatus, deployedSha: vercelSha, url: `https://${vercelUrl}` },
        });
      }

      await new Promise((r) => setTimeout(r, interval));
    }

    return res.status(200).json({
      status: vercelStatus || 'IN_PROGRESS',
      deploymentUrl: null,
      github: { status: gitStatus, conclusion: gitConclusion, sha: gitSha, url: gitUrl },
      vercel: { status: vercelStatus, deployedSha: vercelSha, url: vercelUrl },
    });

  } catch (error) {
    console.error('Error checking deploy status:', error);
    res.status(500).json({ error: 'Failed to check deployment status' });
  }
}
