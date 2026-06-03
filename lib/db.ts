import { Pool, QueryResult } from 'pg';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL environment variable is required');
}

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Graceful shutdown
process.on('exit', () => pool.end());

/**
 * Execute a parameterized SQL query against the connection pool.
 * All queries MUST use parameterized form ($1, $2, ...) — never string interpolation.
 */
export async function query(text: string, params?: any[]): Promise<QueryResult> {
  const start = Date.now();
  const result = await pool.query(text, params);
  const duration = Date.now() - start;
  if (process.env.NODE_ENV !== 'production') {
    console.log('[db] query', { text, duration, rows: result.rowCount });
  }
  return result;
}
