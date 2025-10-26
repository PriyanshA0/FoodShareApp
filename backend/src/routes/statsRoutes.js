// /backend/src/routes/statsRoutes.js
const express = require('express');
const router = express.Router();

// 1. Controller import (Fixed in previous steps to avoid crash)
const statsController = require('../controllers/statsController'); 

// 2. CRITICAL FIX: Import the default middleware function and assign it to 'protect'.
const protect = require('../middleware/authMiddleware'); 

// Access the controller function using dot notation: statsController.getDashboardStats
// The crash line now correctly receives the 'protect' function.
router.get('/dashboard', protect, statsController.getDashboardStats); 

module.exports = router;