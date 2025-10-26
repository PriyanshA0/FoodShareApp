// /backend/src/routes/statsRoutes.js
const express = require('express');
const router = express.Router();

const statsController = require('../controllers/statsController'); 

// CRITICAL FIX: Change the middleware import syntax to be more robust
// We assume authMiddleware.js looks like: module.exports = { protect: async (...) => {...} }
// or the protect function is exported as module.exports.protect.

const authMiddleware = require('../middleware/authMiddleware'); // Import the whole module
const protect = authMiddleware.protect; // Access the function via dot notation

// Access the controller function using dot notation: statsController.getDashboardStats
router.get('/dashboard', protect, statsController.getDashboardStats); 
// Note: This must be line 12 in your file structure.

module.exports = router;