const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const userController = require('../controllers/userController');

router.get('/get_profile', authMiddleware, userController.getProfile);
router.post('/update_profile', authMiddleware, userController.updateProfile);

module.exports = router;