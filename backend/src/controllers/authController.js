const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_key';

exports.register = async (req, res) => {
    const { email, password, role, name, contact, address, license, registrationNo, volunteersCount } = req.body;
    
    if (!email || !password || !role || !name) {
        return res.status(400).json({ message: 'Missing required fields.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [userResult] = await db.promise().query(
            'INSERT INTO users (email, password, role, status) VALUES (?, ?, ?, ?)',
            [email, hashedPassword, role, 'pending']
        );
        const userId = userResult.insertId;

        // Insert into role-specific table (simplified for brevity, ensuring placeholders exist)
        if (role === 'restaurant') {
            await db.promise().query(
                'INSERT INTO restaurants (user_id, name, contact_number, address, license_proof, owner_name) VALUES (?, ?, ?, ?, ?, ?)',
                [userId, name, contact, address, license, name]
            );
        } else if (role === 'ngo') {
            await db.promise().query(
                'INSERT INTO ngos (user_id, name, contact_person, contact_number, address, registration_certificate, volunteers_count) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [userId, name, name, contact, address, registrationNo, volunteersCount]
            );
        }

        res.status(201).json({ message: 'Registration successful! Awaiting admin approval.' });

    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ message: 'Email already registered.' });
        }
        res.status(500).json({ message: 'Registration failed.', error: error.message });
    }
};

exports.login = async (req, res) => {
    const { email, password } = req.body;

    try {
        const [users] = await db.promise().query('SELECT id, password, role, status FROM users WHERE email = ?', [email]);
        const user = users[0];

        if (!user || !(await bcrypt.compare(password, user.password))) {
            return res.status(401).json({ message: 'Invalid email or password.' });
        }
        if (user.status !== 'approved') {
            return res.status(403).json({ message: 'Account is pending admin approval.' });
        }

        const token = jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({
            message: 'Login successful!',
            user_id: user.id,
            role: user.role,
            token: token // Client must store this token
        });

    } catch (error) {
        res.status(500).json({ message: 'An error occurred.', error: error.message });
    }
};