// api/create-feature-table.js
const SUPABASE_URL = 'https://bwejefduwqariatiyfie.supabase.co';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const { appName, featureName } = req.body || {};
    if (!appName || !featureName) {
        return res.status(400).json({ error: 'Missing appName or featureName' });
    }

    const tableName = `${appName}_${featureName}`.replace(/[^a-zA-Z0-9_]/g, '').toLowerCase();

    const sql = `
    CREATE TABLE IF NOT EXISTS "${tableName}" (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      data jsonb
    );
  `;

    try {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/execute_sql`, {
            method: 'POST',
            headers: {
                apikey: SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ sql }),
        });

        const resultText = await response.text();
        const result = resultText ? JSON.parse(resultText) : {};

        if (!response.ok) {
            return res.status(500).json({ error: 'Failed to execute SQL', detail: result });
        }

        return res.status(200).json({ message: `Table ${tableName} created successfully!` });
    } catch (err) {
        return res.status(500).json({ error: 'Unexpected server error', details: err.message });
    }
}