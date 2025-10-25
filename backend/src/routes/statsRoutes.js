// /backend/src/routes/statsRoutes.js
const express = require('express');
const router = express.Router();
// CRITICAL: Ensure this path and function name are correct
const { getDashboardStats } = require('../controllers/statsController'); 
const { protect } = require('../middleware/authMiddleware'); // Assuming this is your JWT middleware

// Route: GET /api/stats/dashboard (Protected route for analytics)
// This is line 8 where the error occurred, ensure getDashboardStats is not undefined
router.get('/dashboard', protect, getDashboardStats);

module.exports = router;