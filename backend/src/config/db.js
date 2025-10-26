// /backend/src/config/db.js
const { Pool } = require('pg'); // Correct driver

// CRITICAL: The pg driver MUST read the separate environment variables
const pool = new Pool({
    host: process.env.DB_HOST, 
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT, // 5432 for Postgres
});

module.exports = pool;