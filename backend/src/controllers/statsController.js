// /backend/src/controllers/statsController.js
const db = require('../config/db'); 

// This function must be correctly exported using the 'exports' keyword
exports.getDashboardStats = async (req, res) => {
    const { role, id: userId } = req.user;

    try {
        let stats = {};
        let result;

        if (role === 'restaurant') {
            // Get restaurant ID
            result = await db.pool.query('SELECT id FROM restaurants WHERE user_id = $1', [userId]);
            const restaurantId = result.rows[0]?.id;

            if (!restaurantId) {
                 return res.status(404).json({ message: 'Restaurant profile not found.' });
            }

            // Get total completed donations
            result = await db.pool.query("SELECT COUNT(*) AS totalCompleted FROM food_donations WHERE restaurant_id = $1 AND status = 'picked_up'", [restaurantId]);
            const totalCompleted = result.rows[0].totalcompleted; // PostgreSQL lowercase column name
            
            // Get total pending orders
            result = await db.pool.query("SELECT COUNT(*) AS totalPending FROM food_donations WHERE restaurant_id = $1 AND status = 'pending'", [restaurantId]);
            const totalPending = result.rows[0].totalpending;

            stats = {
                totalPickupsCompleted: totalCompleted,
                totalPendingOrders: totalPending
            };

        } else if (role === 'ngo') {
            // Get NGO ID
            result = await db.pool.query('SELECT id FROM ngos WHERE user_id = $1', [userId]);
            const ngoId = result.rows[0]?.id;
            
            // Get NGO pickups
            result = await db.pool.query("SELECT COUNT(*) AS totalNgoPickups FROM food_donations WHERE ngo_id = $1 AND status = 'picked_up'", [ngoId]);
            const ngoPickups = result.rows[0].totalngopickups;

            // Get overall pending
            result = await db.pool.query("SELECT COUNT(*) AS overallPendingDonations FROM food_donations WHERE status = 'pending'");
            const allPending = result.rows[0].overallpendingdonations;

            stats = {
                ngoPickupsCompleted: ngoPickups,
                overallPendingDonations: allPending
            };
        }
        
        res.status(200).json(stats);
    } catch (error) {
        console.error("Dashboard Stats Error:", error);
        res.status(500).json({ message: "Failed to fetch dashboard statistics.", error: error.message });
    }
};