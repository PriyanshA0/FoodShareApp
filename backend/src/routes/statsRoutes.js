// /backend/src/routes/statsRoutes.js
const express = require('express');
const router = express.Router();

// FIX: Import the entire module instead of using destructuring {}
const statsController = require('../controllers/statsController'); 

const { protect } = require('../middleware/authMiddleware'); // Assuming this is your JWT middleware

// Route: GET /api/stats/dashboard (Protected route for analytics)
// Access the function using dot notation: statsController.getDashboardStats
router.get('/dashboard', protect, statsController.getDashboardStats); 

module.exports = router;