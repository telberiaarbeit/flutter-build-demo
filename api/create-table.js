const SUPABASE_URL = 'https://vzusoizwmnarilhtmzuc.supabase.co';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export default async function handler(req, res) {
    const { method, query } = req;

    let sql = '';
    if (method === 'POST') {
        try {
            const body = await req.json?.();
            sql = body?.sql || '';
        } catch (e) {
            return res.status(400).json({ error: 'Invalid JSON body' });
        }
    } else if (method === 'GET') {
        sql = query.sql;
    } else {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    if (!sql) {
        return res.status(400).json({ error: 'Missing SQL query' });
    }

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
            return res.status(500).json({
                error: '❌ Failed to execute SQL',
                detail: result,
            });
        }

        return res.status(200).json({ message: '✅ SQL executed successfully' });
    } catch (err) {
        return res.status(500).json({ error: '❌ Unexpected server error', details: err.message });
    }
}
