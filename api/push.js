const fetch = global.fetch || ((...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args)));

const GITHUB_TOKEN = process.env.GITHUB_TOKEN; // Or hardcode it here for testing
const REPO_OWNER = 'telberiaarbeit';
const REPO_NAME = 'flutter-build-demo';
const BRANCH = 'web-build';
const FILE_PATH = 'lib/main.dart'; // Change to 'lib/main1.dart' if needed

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST allowed' });
  }

  const { code } = req.body || {};
  if (!code) {
    return res.status(400).json({ error: 'Missing Flutter code' });
  }

  const headers = {
    Authorization: `token ${GITHUB_TOKEN}`,
    Accept: 'application/vnd.github+json'
  };

  const fileUrl = `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents/${FILE_PATH}`;
  let sha = null;

  // Step 1: Try to get latest SHA of the file (if it exists)
  try {
    const resp = await fetch(`${fileUrl}?ref=${BRANCH}`, { headers });
    if (resp.ok) {
      const data = await resp.json();
      sha = data.sha;
    }
  } catch (err) {
    console.error('Error fetching file SHA:', err.message);
  }

  // Step 2: Prepare the PUT body
  const body = {
    message: `Update ${FILE_PATH} via API`,
    content: Buffer.from(code).toString('base64'),
    branch: BRANCH,
    ...(sha ? { sha } : {})
  };

  // Step 3: Push update to GitHub
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
      console.error('GitHub error:', json);
      return res.status(500).json({ error: 'GitHub push failed', details: json });
    }
  } catch (err) {
    return res.status(500).json({ error: 'GitHub request error', message: err.message });
  }
}
