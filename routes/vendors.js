const express = require('express');
const router = express.Router();
const pool = require('../db'); // Assuming PostgreSQL connection is set up

// Get all vendors
router.get('/vendors', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM vendors ORDER BY vendor_id');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single vendor by ID
router.get('/vendors/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM vendors WHERE vendor_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Vendor not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new vendor
router.post('/vendors', async (req, res) => {
    try {
        const { name, contact_person, phone, email, address } = req.body;
        const result = await pool.query(`
            INSERT INTO vendors (name, contact_person, phone, email, address) 
            VALUES ($1, $2, $3, $4, $5) RETURNING *
        `, [name, contact_person, phone, email, address]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating vendor' });
    }
});

// Update an existing vendor
router.put('/vendors/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, contact_person, phone, email, address } = req.body;
        const result = await pool.query(`
            UPDATE vendors 
            SET name = $1, contact_person = $2, phone = $3, email = $4, address = $5
            WHERE vendor_id = $6 RETURNING *
        `, [name, contact_person, phone, email, address, id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Vendor not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating vendor' });
    }
});

// Delete a vendor
router.delete('/vendors/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM vendors WHERE vendor_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Vendor not found' });
        res.json({ message: 'Vendor deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting vendor' });
    }
});

module.exports = router;
