// /backend/src/controllers/statsController.js
const db = require('../config/db'); // Your MySQL connection pool

exports.getDashboardStats = async (req, res) => {
    const { role, id: userId } = req.user;

    try {
        let stats = {};

        if (role === 'restaurant') {
            // Restaurant Dashboard Stats (e.g., their own performance)
            const [restaurants] = await db.promise().query('SELECT id FROM restaurants WHERE user_id = ?', [userId]);
            const restaurantId = restaurants[0]?.id;

            if (!restaurantId) {
                 return res.status(404).json({ message: 'Restaurant profile not found.' });
            }

            const [totalPosted] = await db.promise().query("SELECT COUNT(*) AS totalPosted FROM food_donations WHERE restaurant_id = ?", [restaurantId]);
            const [totalCompleted] = await db.promise().query("SELECT COUNT(*) AS totalCompleted FROM food_donations WHERE restaurant_id = ? AND status = 'picked_up'", [restaurantId]);
            const [totalPending] = await db.promise().query("SELECT COUNT(*) AS totalPending FROM food_donations WHERE restaurant_id = ? AND status = 'pending'", [restaurantId]);

            stats = {
                totalDonationsPosted: totalPosted[0].totalPosted,
                totalPickupsCompleted: totalCompleted[0].totalCompleted,
                totalPendingOrders: totalPending[0].totalPending
            };

        } else if (role === 'ngo') {
            // NGO Dashboard Stats (e.g., overall network activity or their own pickups)
            const [ngos] = await db.promise().query('SELECT id FROM ngos WHERE user_id = ?', [userId]);
            const ngoId = ngos[0]?.id;
            
            // Stats relevant to NGO's performance
            const [ngoPickups] = await db.promise().query("SELECT COUNT(*) AS totalNgoPickups FROM food_donations WHERE ngo_id = ? AND status = 'picked_up'", [ngoId]);
            const [ngoActiveOrders] = await db.promise().query("SELECT COUNT(*) AS totalActiveOrders FROM food_donations WHERE ngo_id = ? AND status IN ('accepted', 'in_transit')", [ngoId]);
            
            // Overall network stats (for general dashboard view)
            const [allPending] = await db.promise().query("SELECT COUNT(*) AS overallPendingDonations FROM food_donations WHERE status = 'pending'");

            stats = {
                ngoPickupsCompleted: ngoPickups[0].totalNgoPickups,
                ngoActiveOrders: ngoActiveOrders[0].totalActiveOrders,
                overallPendingDonations: allPending[0].overallPendingDonations
            };
        }
        
        res.status(200).json(stats);
    } catch (error) {
        console.error("Dashboard Stats Error:", error);
        res.status(500).json({ message: "Failed to fetch dashboard statistics." });
    }
};