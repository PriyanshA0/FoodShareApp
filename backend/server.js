const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config(); 

const db = require('./src/config/db'); 
const authRoutes = require('./src/routes/authRoutes');
const donationRoutes = require('./src/routes/donationRoutes');
const userRoutes = require('./src/routes/userRoutes');
const statsRoutes = require('./src/routes/statsRoutes');

const app = express();
const PORT = process.env.PORT || 3000; 

// Middleware Setup
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Route Definitions
app.use('/api/auth', authRoutes);
app.use('/api/donations', donationRoutes);
app.use('/api/users', userRoutes);
app.use('/api/stats', statsRoutes);

// Test DB Connection and Start Server (FINAL CRITICAL FIX)
// CHANGE: Use db.connect() (which returns a promise) instead of the invalid db.getConnection(callback)
db.connect()
    .then(client => {
        // Successful connection
        console.log('Connected to database successfully!');
        client.release(); // Release the test connection immediately

        // Only start the server AFTER a successful database connection
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch(err => {
        // Connection failed (ETIMEDOUT or other error)
        console.error('Database connection failed:', err.stack);
        process.exit(1); // Exit with status 1 to fail the Render deployment
    });