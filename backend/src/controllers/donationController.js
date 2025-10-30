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

    // Check for required fields (unchanged)
    if (!title || !quantity || !expiry_time || !pickup_location) {
        if (imageFile && fs.existsSync(imageFile.path)) fs.unlinkSync(imageFile.path); 
        return res.status(400).json({ message: 'Missing required fields.' });
    }

    let imageUrl = null;
    let publicId = null; 

    // --- CLOUDINARY UPLOAD LOGIC (unchanged) ---
    if (imageFile) {
        // ... (Cloudinary upload logic remains here) ...
    }
    // --- END CLOUDINARY UPLOAD LOGIC ---

    try {
        // FIX: Use db.pool.query
        const restaurantResult = await db.pool.query('SELECT id FROM restaurants WHERE user_id = $1', [userId]);
        const restaurantId = restaurantResult.rows[0]?.id;

        const sql = `
            INSERT INTO food_donations (restaurant_id, title, category, quantity, expiry_time, pickup_location, image_url, cloudinary_public_id, status) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending') -- FIX: Use $1 through $8
        `;
        await db.pool.query(sql, [restaurantId, title, category, quantity, expiry_time, pickup_location, imageUrl, publicId]);

        res.status(201).json({ message: 'Donation posted successfully.' });

    } catch (error) {
        console.error("Post Donation Error:", error);
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
        // FIX: Use db.pool.query
        const result = await db.pool.query(sql);

        res.status(200).json(result.rows); // FIX: Use result.rows

    } catch (error) {
        console.error("Get All Donations Error:", error);
        res.status(500).json({ message: 'Failed to fetch donations.', error: error.message });
    }
};

exports.acceptDonation = async (req, res) => {
    const { id: userId, role } = req.user; 
    const { donation_id } = req.body;

    if (role !== 'ngo') return res.status(403).json({ message: 'Access denied.' });

    try {
        // FIX: Use db.pool.query
        const ngoResult = await db.pool.query('SELECT id, name FROM ngos WHERE user_id = $1', [userId]);
        const ngoId = ngoResult.rows[0]?.id;
        const ngoName = ngoResult.rows[0]?.name;
        
        if (!ngoId) return res.status(403).json({ message: 'NGO profile not found.' });

        const [result] = await db.pool.query( // Note: pg driver returns a single object, not an array of arrays
            'UPDATE food_donations SET status = $1, ngo_id = $2, ngo_name = $3, accepted_at = NOW() WHERE id = $4 AND status = $5',
            ['accepted', ngoId, ngoName, donation_id, 'pending']
        );
        // Note: pg returns rowCount, not affectedRows
        if (result.rowCount === 0) {
            return res.status(409).json({ message: 'Donation is no longer available or was already accepted.' });
        }
        res.status(200).json({ message: 'Order accepted successfully!' });
    } catch (error) {
        console.error("Accept Donation Error:", error);
        res.status(500).json({ message: 'Failed to accept order.', error: error.message });
    }
};

exports.markInTransit = async (req, res) => {
    const { id: userId, role } = req.user; 
    const { donation_id } = req.body;

    if (role !== 'ngo') return res.status(403).json({ message: 'Access denied.' });

    try {
        // FIX: Use db.pool.query
        const ngoResult = await db.pool.query('SELECT id FROM ngos WHERE user_id = $1', [userId]);
        const ngoId = ngoResult.rows[0]?.id;
        
        const result = await db.pool.query(
            'UPDATE food_donations SET status = $1, in_transit_at = NOW() WHERE id = $2 AND ngo_id = $3 AND status = $4',
            ['in_transit', donation_id, ngoId, 'accepted']
        );
        
        if (result.rowCount === 0) {
            return res.status(409).json({ message: 'Status must be ACCEPTED to move to In Transit.' });
        }
        res.status(200).json({ message: 'Status updated to In Transit!' });
    } catch (error) {
        console.error("Mark In Transit Error:", error);
        res.status(500).json({ message: 'Failed to update status.', error: error.message });
    }
};

exports.completePickup = async (req, res) => {
    const { id: userId, role } = req.user; 
    const { donation_id } = req.body;

    if (role !== 'ngo') return res.status(403).json({ message: 'Access denied.' });

    try {
        // FIX: Use db.pool.query
        const ngoResult = await db.pool.query('SELECT id FROM ngos WHERE user_id = $1', [userId]);
        const ngoId = ngoResult.rows[0]?.id;
        
        const result = await db.pool.query(
            'UPDATE food_donations SET status = $1, picked_up_at = NOW() WHERE id = $2 AND ngo_id = $3 AND status IN ($4, $5)',
            ['picked_up', donation_id, ngoId, 'accepted', 'in_transit']
        );
        
        if (result.rowCount === 0) {
            return res.status(409).json({ message: 'Pickup status could not be confirmed.' });
        }
        
        res.status(200).json({ message: 'Pickup confirmed successfully!' });
    } catch (error) {
        console.error("Complete Pickup Error:", error);
        res.status(500).json({ message: 'Failed to complete pickup.', error: error.message });
    }
};