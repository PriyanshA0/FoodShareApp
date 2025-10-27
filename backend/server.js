const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config(); 

const db = require('./src/config/db'); // db now exports an object with a 'connect' method
const authRoutes = require('./src/routes/authRoutes');
const donationRoutes = require('./src/routes/donationRoutes');
const userRoutes = require('./src/routes/userRoutes');
const statsRoutes = require('./src/routes/statsRoutes');

const app = express();
// Use PORT provided by Render (or 3000 locally)
const PORT = process.env.PORT || 3000; 

// Middleware Setup
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Route Definitions
app.use('/api/auth', authRoutes);
app.use('/api/donations', donationRoutes);
app.use('/api/users', userRoutes);
app.use('/api/stats', statsRoutes); // Register the statistics route

// Test DB Connection and Start Server (FINAL CRITICAL FIX)
// CHANGE: Use the promise-based db.connect() method exported from db.js
db.connect()
    .then(() => {
        // Successful connection
        console.log('Connected to database successfully!');

        // Only start the server AFTER a successful database connection
        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });
    })
    .catch(err => {
        // Connection failed (ETIMEDOUT or authentication failure)
        console.error('Database connection failed:', err.stack);
        // CRITICAL: Exit with status 1 to prevent Render from declaring the service healthy
        process.exit(1); 
    });