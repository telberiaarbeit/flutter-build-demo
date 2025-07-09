import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Only POST allowed' });
  }

  const { secret_code, name_app, table_name, columns } = req.body || {};
  if (!secret_code || !name_app || !table_name || !columns) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  // Build safe table name
  const newTableName = `${secret_code}_${name_app}_${table_name}`.replace(/[^a-zA-Z0-9_]/g, '_');
  const columnsSql = columns.map(col => `${col.name} ${col.type}`).join(', ');
  const sql = `CREATE TABLE IF NOT EXISTS "${newTableName}" (${columnsSql});`;

  // Call Supabase function to execute SQL
  const { error } = await supabase.rpc('execute_sql', { sql });
  if (error) {
    return res.status(500).json({ error: 'Table creation failed', details: error });
  }
  return res.status(200).json({ status: 'success', message: `Table ${newTableName} created.` });
}
