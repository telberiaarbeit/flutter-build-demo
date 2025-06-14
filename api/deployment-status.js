export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Only GET allowed' });
  }

  try {
    const githubResp = await fetch(
      `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs?branch=${BRANCH}&per_page=1`,
      { headers: { Authorization: `token ${GITHUB_TOKEN}` } }
    );
    const githubData = await githubResp.json();
    const latestRun = githubData.workflow_runs?.[0];

    if (!latestRun) {
      return res.status(404).json({ error: 'No GitHub workflow found' });
    }

    const gitSha = latestRun.head_sha;
    const gitStatus = latestRun.status;
    const gitConclusion = latestRun.conclusion;

    // Step 1: If build is running → wait
    if (gitStatus === 'in_progress' || gitStatus === 'queued') {
      let attempt = 0;
      while (attempt < MAX_ATTEMPTS) {
        const checkRun = await fetch(
          `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runs/${latestRun.id}`,
          { headers: { Authorization: `token ${GITHUB_TOKEN}` } }
        );
        const data = await checkRun.json();
        if (data.status === 'completed' && data.conclusion === 'success') break;

        await new Promise((r) => setTimeout(r, POLL_INTERVAL_MS));
        attempt++;
      }
    }

    // Step 2: Check Vercel (single lookup)
    const vercelResp = await fetch(
      `https://api.vercel.com/v6/deployments?projectId=${VERCEL_PROJECT_ID}&limit=5`,
      { headers: { Authorization: `Bearer ${VERCEL_TOKEN}` } }
    );
    const vercelData = await vercelResp.json();

    const matched = vercelData.deployments?.find(
      (d) => d.meta?.githubCommitSha === gitSha && d.state === 'READY'
    );

    return res.status(200).json({
      status: matched ? 'READY' : 'DEPLOYING',
      deploymentUrl: matched?.url || null,
    });
  } catch (err) {
    console.error('Check error:', err);
    return res.status(500).json({ error: 'Internal error' });
  }
}
