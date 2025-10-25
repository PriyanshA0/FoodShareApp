const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config(); 

const db = require('./src/config/db'); 
const authRoutes = require('./src/routes/authRoutes');
const donationRoutes = require('./src/routes/donationRoutes');
const userRoutes = require('./src/routes/userRoutes');
const statsRoutes = require('./src/routes/statsRoutes'); // NEW: Import the statistics routes

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware Setup
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// IMPORTANT: This static serving of 'uploads' is now OBSOLETE 
// because images are served from Cloudinary. This can be REMOVED
// once you confirm no other local files are served from this directory.
// For now, we will leave it, but it should be noted for cleanup.
app.use('/api/uploads', express.static('uploads')); 

// Test DB Connection
db.getConnection((err, connection) => {
    if (err) {
        console.error('Database connection failed:', err.stack);
        return;
    }
    console.log('Connected to database as ID:', connection.threadId);
    connection.release();
});

// Route Definitions
app.use('/api/auth', authRoutes);
app.use('/api/donations', donationRoutes);
app.use('/api/users', userRoutes);
app.use('/api/stats', statsRoutes); // NEW: Register the statistics route

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});