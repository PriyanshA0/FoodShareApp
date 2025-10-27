// /backend/src/config/db.js
// CRITICAL: Must use the 'pg' driver for PostgreSQL
const { Pool } = require('pg'); 

const pool = new Pool({
    host: process.env.DB_HOST, 
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT, // 5432 for Postgres
});

// CRITICAL: Export the Pool for controllers to use, and a connect test for server.js
module.exports = {
    // This connects to test the connection and then releases it
    connect: async () => {
        const client = await pool.connect();
        client.release(); 
    },
    pool: pool // The main pool used by controllers (e.g., db.pool.query(...))
};