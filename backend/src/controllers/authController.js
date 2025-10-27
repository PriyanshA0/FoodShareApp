const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_key';

exports.register = async (req, res) => {
    const { email, password, role, name, contact, address, license, registrationNo, volunteersCount } = req.body;
    
    // 1. Basic validation (required fields)
    if (!email || !password || !role || !name) {
        return res.status(400).json({ message: 'Missing required fields.' });
    }

    try {
        // Hashing password
        const hashedPassword = await bcrypt.hash(password, 10);
        
        // --- Start Transaction (for atomicity) ---
        // Using pool.connect() to ensure a single connection for the transaction
        const client = await db.pool.connect();
        await client.query('BEGIN'); 

        // 2. Insert into users table
        const userInsertResult = await client.query(
            'INSERT INTO users (email, password, role, status) VALUES ($1, $2, $3, $4) RETURNING id',
            [email, hashedPassword, role, 'pending']
        );
        const userId = userInsertResult.rows[0].id; // Get the ID inserted by Postgres

        // 3. Insert into role-specific table
        if (role === 'restaurant') {
            await client.query(
                `INSERT INTO restaurants (user_id, name, contact_number, address, license_proof, owner_name) 
                 VALUES ($1, $2, $3, $4, $5, $6)`,
                [
                    userId, 
                    name, 
                    contact || null, // FIX: Use || null for optional fields
                    address || null, 
                    license || null, 
                    name 
                ]
            );
        } else if (role === 'ngo') {
            await client.query(
                `INSERT INTO ngos (user_id, name, contact_person, contact_number, address, registration_certificate, volunteers_count) 
                 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
                [
                    userId, 
                    name, 
                    name || null, 
                    contact || null, 
                    address || null, 
                    registrationNo || null, 
                    volunteersCount || null 
                ]
            );
        }

        await client.query('COMMIT'); // Finalize transaction
        client.release(); // Release connection

        res.status(201).json({ message: 'Registration successful! Awaiting admin approval.' });

    } catch (error) {
        // Rollback transaction on any error
        if (client) {
             await client.query('ROLLBACK');
             client.release();
        }
        
        // --- CRITICAL DIAGNOSTIC ADDITION ---
        console.error("REGISTRATION EXCEPTION:", error); // Log the full exception
        // --- END DIAGNOSTIC ---

        // Check for specific error codes (Postgres error code for unique constraint is 23505)
        if (error.code === '23505' || error.message.includes('unique constraint')) {
            return res.status(409).json({ message: 'Email already registered.' });
        }
        res.status(500).json({ message: 'Registration failed.', error: error.message });
    }
};

exports.login = async (req, res) => {
    const { email, password } = req.body;
    
    // Note: The logic in login still uses db.promise().query, which is fine, 
    // but should be changed to use db.pool.query() for Postgres consistency.
    
    try {
        // --- CRITICAL: MUST BE CHANGED TO POSTGRES SYNTAX ---
        // Assuming your db.js exports a promise-based pool (db.pool)
        const client = await db.pool.connect(); 
        
        const userResult = await client.query('SELECT id, password, role, status FROM users WHERE email = $1', [email]);
        const user = userResult.rows[0];
        client.release();
        // --- END CRITICAL CHANGE ---

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