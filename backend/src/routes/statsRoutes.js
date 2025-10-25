// /backend/src/routes/statsRoutes.js
const express = require('express');
const router = express.Router();
const { getDashboardStats } = require('../controllers/statsController');
const { protect } = require('../middleware/authMiddleware'); // Assuming this is your JWT middleware

// Route: GET /api/stats/dashboard (Protected route for analytics)
router.get('/dashboard', protect, getDashboardStats);

module.exports = router;