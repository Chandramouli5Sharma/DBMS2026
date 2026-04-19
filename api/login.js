import mysql from 'mysql2/promise';

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { username, password } = req.body;

  try {
    // Connect to the database using the Environment Variable configured in Vercel
    const db = await mysql.createConnection(process.env.DATABASE_URL);

    // Query the Users table
    const [rows] = await db.execute(
      'SELECT username, full_name as name, email, phone_number as phone FROM Users WHERE username = ? AND password_hash = ?', 
      [username, password]
    );
    
    await db.end();

    if (rows.length > 0) {
      return res.status(200).json(rows[0]);
    } else {
      return res.status(401).json({ error: 'Invalid username or password' });
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Database connection failed' });
  }
}