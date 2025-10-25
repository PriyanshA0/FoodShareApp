const db = require('../config/db');

exports.getProfile = async (req, res) => {
    const { id: userId, role: userRole } = req.user;

    try {
        // Dynamic column selection based on role
        let profileTable, verificationColumn, contactPersonColumn;
        if (userRole === 'restaurant') {
            profileTable = 'restaurants';
            verificationColumn = 'license_proof';
            contactPersonColumn = 'owner_name';
        } else if (userRole === 'ngo') {
            profileTable = 'ngos';
            verificationColumn = 'registration_certificate';
            contactPersonColumn = 'contact_person';
        } else {
            return res.status(400).json({ message: 'Invalid user role.' });
        }

        const sql = `
            SELECT 
                u.id, u.email, u.role, u.status,
                p.name, p.contact_number, p.address,
                p.${verificationColumn} AS verification_detail,
                p.volunteers_count,
                p.${contactPersonColumn} AS contact_person
            FROM users u
            JOIN ${profileTable} p ON u.id = p.user_id
            WHERE u.id = ?
        `;
        
        const [result] = await db.promise().query(sql, [userId]);

        if (result.length === 0) {
            return res.status(404).json({ message: 'Profile data not found.' });
        }

        // Send flattened structure for Flutter consumption
        res.status(200).json(result[0]);

    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch user data.', error: error.message });
    }
};

exports.updateProfile = async (req, res) => {
    const { id: userId, role: userRole } = req.user;
    const { name, contact_number, address } = req.body;

    try {
        let profileTable;
        if (userRole === 'restaurant') {
            profileTable = 'restaurants';
        } else if (userRole === 'ngo') {
            profileTable = 'ngos';
        } else {
            return res.status(400).json({ message: 'Invalid user role.' });
        }

        // Update profile table
        const sql = `
            UPDATE ${profileTable}
            SET name = ?, contact_number = ?, address = ?
            WHERE user_id = ?
        `;
        
        await db.promise().query(sql, [name, contact_number, address, userId]);

        res.status(200).json({ message: 'Profile updated successfully!' });

    } catch (error) {
        res.status(500).json({ message: 'Failed to update profile due to a database error.', error: error.message });
    }
};