// /backend/src/controllers/statsController.js
const db = require('../config/db'); // Your MySQL connection pool

// This function must be correctly exported using the 'exports' keyword
exports.getDashboardStats = async (req, res) => {
    const { role, id: userId } = req.user;

    try {
        let stats = {};

        if (role === 'restaurant') {
            // Logic for Restaurant Dashboard Stats
            const [restaurants] = await db.promise().query('SELECT id FROM restaurants WHERE user_id = ?', [userId]);
            const restaurantId = restaurants[0]?.id;

            if (!restaurantId) {
                 return res.status(404).json({ message: 'Restaurant profile not found.' });
            }

            const [totalCompleted] = await db.promise().query("SELECT COUNT(*) AS totalCompleted FROM food_donations WHERE restaurant_id = ? AND status = 'picked_up'", [restaurantId]);
            const [totalPending] = await db.promise().query("SELECT COUNT(*) AS totalPending FROM food_donations WHERE restaurant_id = ? AND status = 'pending'", [restaurantId]);

            stats = {
                totalPickupsCompleted: totalCompleted[0].totalCompleted,
                totalPendingOrders: totalPending[0].totalPending
            };

        } else if (role === 'ngo') {
            // Logic for NGO Dashboard Stats
            const [ngos] = await db.promise().query('SELECT id FROM ngos WHERE user_id = ?', [userId]);
            const ngoId = ngos[0]?.id;
            
            const [ngoPickups] = await db.promise().query("SELECT COUNT(*) AS totalNgoPickups FROM food_donations WHERE ngo_id = ? AND status = 'picked_up'", [ngoId]);
            const [allPending] = await db.promise().query("SELECT COUNT(*) AS overallPendingDonations FROM food_donations WHERE status = 'pending'");

            stats = {
                ngoPickupsCompleted: ngoPickups[0].totalNgoPickups,
                overallPendingDonations: allPending[0].overallPendingDonations
            };
        }
        
        res.status(200).json(stats);
    } catch (error) {
        console.error("Dashboard Stats Error:", error);
        res.status(500).json({ message: "Failed to fetch dashboard statistics." });
    }
};