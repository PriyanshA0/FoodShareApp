const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config(); 

// Ensure db requires the corrected db.js file
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

// Test DB Connection and Start Server (Using the async db.connect())
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
        // Connection failed
        console.error('Database connection failed:', err.stack);
        process.exit(1); // Exit with status 1 to fail the Render deployment cleanly
    });