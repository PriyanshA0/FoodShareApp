// /backend/src/config/db.js
const mysql = require('mysql2/promise'); 

const pool = mysql.createPool({
    host: process.env.DB_HOST, 
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306, // CRITICAL: Use 3306 for MySQL
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = {
    connect: async () => {
        const connection = await pool.getConnection();
        connection.release();
    },
    pool: pool
};