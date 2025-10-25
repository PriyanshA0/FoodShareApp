// /backend/src/routes/statsRoutes.js
const express = require('express');
const router = express.Router();

// FIX: Import the entire module 
const statsController = require('../controllers/statsController'); 

const { protect } = require('../middleware/authMiddleware'); 

// Access the function using dot notation: statsController.getDashboardStats
// THIS MUST BE THE CODE ON LINE 12 WHERE THE ERROR OCCURS
router.get('/dashboard', protect, statsController.getDashboardStats); 

module.exports = router;