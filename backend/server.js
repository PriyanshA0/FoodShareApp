const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config(); 

const db = require('./src/config/db'); 
const authRoutes = require('./src/routes/authRoutes');
const donationRoutes = require('./src/routes/donationRoutes');
const userRoutes = require('./src/routes/userRoutes');
const statsRoutes = require('./src/routes/statsRoutes'); // Import the statistics routes

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

// Test DB Connection and Start Server (CRITICAL: Database check before startup)
db.getConnection((err, connection) => {
    if (err) {
        // If the database connection fails, log and EXIT the process
        console.error('Database connection failed:', err.stack);
        process.exit(1); // Exit with status 1 to force Render deployment failure
        return;
    }
    console.log('Connected to database as ID:', connection.threadId);
    connection.release();

    // Only start the server AFTER a successful database connection
    app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });
});
// Note: The previous static serving of 'uploads' has been omitted as it is obsolete 
// with Cloudinary and unsafe for Render.