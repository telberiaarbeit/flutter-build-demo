const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;

// Debug: Log token info (never log full token)
if (!GITHUB_TOKEN) {
  console.error('GITHUB_TOKEN is not set!');
} else {
  console.log('GITHUB_TOKEN is set. Length:', GITHUB_TOKEN.length, 'Starts with:', GITHUB_TOKEN.slice(0, 5));
}
const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const FILE_PATH = 'lib/main.dart';

export default async function handler(req, res) {
  if (!GITHUB_TOKEN) {
    return res.status(500).json({ error: 'GITHUB_TOKEN is not set' });
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST allowed' });
  }

  const { code, secret_code } = req.body || {};
  if (!code || !secret_code) {
    return res.status(400).json({ error: 'Missing Flutter code or secret_code' });
  }

  const branch = secret_code;

  const headers = {
    Authorization: `token ${GITHUB_TOKEN}`,
    Accept: 'application/vnd.github+json'
  };

  const fileUrl = `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents/${FILE_PATH}`;
  const branchUrl = `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/git/ref/heads/${branch}`;

  // Step 1: Check if branch exists
  let branchExists = true;
  try {
    const resp = await fetch(branchUrl, { headers });
    if (!resp.ok) branchExists = false;
  } catch {
    branchExists = false;
  }

  // Step 2: If branch doesn't exist, clone from source branch (try 'web-build', then 'main')
  if (!branchExists) {
    let sourceBranch = 'web-build';
    let sourceRefResp = await fetch(`https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/git/ref/heads/${sourceBranch}`, { headers });
    let sourceRef = await sourceRefResp.json();
    if (!sourceRef.object || !sourceRef.object.sha) {
      // Fallback to 'main' if 'web-build' not found
      sourceBranch = 'main';
      sourceRefResp = await fetch(`https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/git/ref/heads/${sourceBranch}`, { headers });
      sourceRef = await sourceRefResp.json();
      if (!sourceRef.object || !sourceRef.object.sha) {
        return res.status(500).json({ error: "Neither 'web-build' nor 'main' source branches found", details: { webBuild: sourceRef } });
      }
    }
    try {
      const createBranchResp = await fetch(`https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/git/refs`, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          ref: `refs/heads/${branch}`,
          sha: sourceRef.object.sha
        })
      });
      if (!createBranchResp.ok) {
        const err = await createBranchResp.json();
        return res.status(500).json({ error: 'Branch creation failed', details: err });
      }
    } catch (err) {
      return res.status(500).json({ error: 'Error cloning branch from source', message: err.message });
    }
  }

  // Step 3: Get current SHA of file (if it exists)
  let sha = null;
  try {
    const resp = await fetch(`${fileUrl}?ref=${branch}`, { headers });
    if (resp.ok) {
      const data = await resp.json();
      sha = data.sha;
    }
  } catch (err) {
    console.error('Error fetching file SHA:', err.message);
  }

  // Step 4: Prepare PUT body
  const body = {
    message: `Update ${FILE_PATH} via API`,
    content: Buffer.from(code).toString('base64'),
    branch,
    ...(sha ? { sha } : {})
  };

  // Step 5: Push update to GitHub
  try {
    const update = await fetch(fileUrl, {
      method: 'PUT',
      headers,
      body: JSON.stringify(body)
    });

    const json = await update.json();

    if (update.status === 200 || update.status === 201) {
      return res.status(200).json({ status: 'success', github_url: json.content?.html_url });
    } else {
      return res.status(500).json({ error: 'GitHub push failed', details: json });
    }
  } catch (err) {
    return res.status(500).json({ error: 'GitHub request error', message: err.message });
  }
}
