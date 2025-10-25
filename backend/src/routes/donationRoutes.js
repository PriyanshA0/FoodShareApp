// src/routes/donationRoutes.js

const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const donationController = require('../controllers/donationController');

// Setup multer for file uploads
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

// Protected Routes
router.get('/get_all', authMiddleware, donationController.getAllDonations); // NGO view
router.post('/post', authMiddleware, upload.single('image'), donationController.postDonation); // Hotel post
router.post('/accept', authMiddleware, donationController.acceptDonation); // NGO accept
router.post('/in_transit', authMiddleware, donationController.markInTransit); // NGO mark in transit
router.post('/complete_pickup', authMiddleware, donationController.completePickup); // NGO mark complete

module.exports = router;