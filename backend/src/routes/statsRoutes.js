// /backend/src/routes/statsRoutes.js
const express = require('express');
const router = express.Router();

// FIX: Import the entire module instead of using destructuring {}
const statsController = require('../controllers/statsController'); 

const { protect } = require('../middleware/authMiddleware'); 

// Access the function using dot notation: statsController.getDashboardStats
// THIS IS THE CRITICAL LINE (likely line 12 in your setup)
router.get('/dashboard', protect, statsController.getDashboardStats); 

module.exports = router;