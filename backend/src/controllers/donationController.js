const db = require('../config/db');
const fs = require('fs');
const cloudinary = require('../config/cloudinary'); 

exports.postDonation = async (req, res) => {
    const { id: userId, role } = req.user; 
    
    if (role !== 'restaurant') {
        return res.status(403).json({ message: 'Access denied. Only restaurants can post donations.' });
    }

    const { title, category, quantity, expiry_time, pickup_location } = req.body;
    const imageFile = req.file;

    // Check for required fields
    if (!title || !quantity || !expiry_time || !pickup_location) {
        if (imageFile && fs.existsSync(imageFile.path)) fs.unlinkSync(imageFile.path); 
        return res.status(400).json({ message: 'Missing required fields.' });
    }

    let imageUrl = null;
    let publicId = null; 

    // --- CRITICAL: CLOUDINARY UPLOAD LOGIC ---
    if (imageFile) {
        try {
            const result = await cloudinary.uploader.upload(imageFile.path, {
                folder: 'foodshare_donations',
            });
            
            imageUrl = result.secure_url; 
            publicId = result.public_id;

            // Clean up the temporary file
            if (fs.existsSync(imageFile.path)) {
                fs.unlinkSync(imageFile.path); 
            }
            
        } catch (error) {
            if (fs.existsSync(imageFile.path)) {
                fs.unlinkSync(imageFile.path);
            }
            console.error("Cloudinary Upload Error:", error);
            return res.status(500).json({ message: "Image upload failed. Please try again." });
        }
    }
    // --- END CLOUDINARY UPLOAD LOGIC ---

    try {
        const [restaurants] = await db.promise().query('SELECT id FROM restaurants WHERE user_id = ?', [userId]);
        const restaurantId = restaurants[0]?.id;

        const sql = `
            INSERT INTO food_donations (restaurant_id, title, category, quantity, expiry_time, pickup_location, image_url, cloudinary_public_id, status) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, "pending")
        `;
        await db.promise().query(sql, [restaurantId, title, category, quantity, expiry_time, pickup_location, imageUrl, publicId]);

        res.status(201).json({ message: 'Donation posted successfully.' });

    } catch (error) {
        res.status(500).json({ message: 'Failed to post donation.', error: error.message });
    }
};

exports.getAllDonations = async (req, res) => {
    const { role } = req.user; 
    if (role !== 'ngo') {
        return res.status(403).json({ message: 'Access denied. Only NGOs can view posts.' });
    }

    try {
        const sql = `
            SELECT 
                fd.*, 
                r.name AS restaurant_name 
            FROM food_donations fd 
            JOIN restaurants r ON fd.restaurant_id = r.id 
            WHERE fd.status = 'pending' 
            ORDER BY fd.posted_at DESC
        `;
        const [donations] = await db.promise().query(sql);

        res.status(200).json(donations);
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch donations.', error: error.message });
    }
};

exports.acceptDonation = async (req, res) => {
    const { id: userId, role } = req.user; 
    const { donation_id } = req.body;

    if (role !== 'ngo') return res.status(403).json({ message: 'Access denied.' });

    try {
        const [ngos] = await db.promise().query('SELECT id, name FROM ngos WHERE user_id = ?', [userId]);
        const ngoId = ngos[0]?.id;
        const ngoName = ngos[0]?.name;
        
        if (!ngoId) return res.status(403).json({ message: 'NGO profile not found.' });

        const [result] = await db.promise().query(
            'UPDATE food_donations SET status = "accepted", ngo_id = ?, ngo_name = ?, accepted_at = NOW() WHERE id = ? AND status = "pending"',
            [ngoId, ngoName, donation_id]
        );

        if (result.affectedRows === 0) {
            return res.status(409).json({ message: 'Donation is no longer available or was already accepted.' });
        }
        res.status(200).json({ message: 'Order accepted successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to accept order.', error: error.message });
    }
};

exports.markInTransit = async (req, res) => {
    const { id: userId, role } = req.user; 
    const { donation_id } = req.body;

    if (role !== 'ngo') return res.status(403).json({ message: 'Access denied.' });

    try {
        const [ngos] = await db.promise().query('SELECT id FROM ngos WHERE user_id = ?', [userId]);
        const ngoId = ngos[0]?.id;
        
        const [result] = await db.promise().query(
            'UPDATE food_donations SET status = "in_transit", in_transit_at = NOW() WHERE id = ? AND ngo_id = ? AND status = "accepted"',
            [donation_id, ngoId]
        );

        if (result.affectedRows === 0) {
            return res.status(409).json({ message: 'Status must be ACCEPTED to move to In Transit.' });
        }
        res.status(200).json({ message: 'Status updated to In Transit!' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to update status.', error: error.message });
    }
};

exports.completePickup = async (req, res) => {
    const { id: userId, role } = req.user; 
    const { donation_id } = req.body;

    if (role !== 'ngo') return res.status(403).json({ message: 'Access denied.' });

    try {
        const [ngos] = await db.promise().query('SELECT id FROM ngos WHERE user_id = ?', [userId]);
        const ngoId = ngos[0]?.id;
        
        const [result] = await db.promise().query(
            'UPDATE food_donations SET status = "picked_up", picked_up_at = NOW() WHERE id = ? AND ngo_id = ? AND status IN ("accepted", "in_transit")',
            [donation_id, ngoId]
        );

        if (result.affectedRows === 0) {
            return res.status(409).json({ message: 'Pickup status could not be confirmed.' });
        }
        
        res.status(200).json({ message: 'Pickup confirmed successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Failed to complete pickup.', error: error.message });
    }
};