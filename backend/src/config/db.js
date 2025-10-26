// /backend/src/config/db.js

const mysql = require('mysql2'); // Assuming you are using mysql2 or similar driver

// Use separate environment variables for stability
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'food_waste_management_db',
    // CRITICAL: Add the PORT for production environments
    port: process.env.DB_PORT || 3306, // Default MySQL port is 3306, Postgres is 5432
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = pool;