const express = require('express');
const pool = require('../db'); // Your PostgreSQL database connection

const router = express.Router();

// Create a new guest record
router.post('/', async (req, res) => {
    try {
        const { guest_name, guest_address, phone_number, email, anniversary, dob, gst_no, company_name, discount, g_suggestion, property_id } = req.body;

        if (!property_id) {
            return res.status(400).json({ message: 'Property ID is required' });
        }

        const date_joined = new Date().toISOString().split('T')[0]; // Get current date

        const result = await pool.query(
            `INSERT INTO guest_record (date_joined, guest_name, guest_address, phone_number, email, anniversary, dob, gst_no, company_name, discount, g_suggestion, property_id)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *`,
            [date_joined, guest_name, guest_address, phone_number, email, anniversary, dob, gst_no, company_name, discount, g_suggestion, property_id]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting guest record:', err.message);
        res.status(500).json({ error: err.message });
    }
});


router.post("/search", async (req, res) => {
    try {
        const { query } = req.body; // Get search term from request query

        if (!query) {
            return res.status(400).json({ error: "Search query is required" });
        }

        const searchQuery = `
        SELECT * FROM guest_record
        WHERE LOWER(guest_name) LIKE LOWER($1) OR phone_number LIKE $2
        ORDER BY date_joined DESC
        LIMIT 10
      `;

        const result = await pool.query(searchQuery, [`%${query}%`, `%${query}%`]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: "No guests found" });
        }

        res.json(result.rows);
    } catch (err) {
        console.error("Error searching guests:", err.message);
        res.status(500).json({ error: err.message });
    }
});



// Get all guest records
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM guest_record');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching guest records:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get guest record by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM guest_record WHERE guest_id = $1', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Guest record not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching guest record with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update a guest record by ID
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { guest_name, guest_address, phone_number, email, anniversary, dob, gst_no, company_name, discount, g_suggestion, property_id } = req.body;

        if (!property_id) {
            return res.status(400).json({ message: 'Property ID is required' });
        }

        const result = await pool.query(
            `UPDATE guest_record
             SET guest_name = $1, guest_address = $2, phone_number = $3, email = $4, anniversary = $5, dob = $6, gst_no = $7, company_name = $8, discount = $9, g_suggestion = $10, property_id = $11, updated_at = NOW()
             WHERE guest_id = $12 RETURNING *`,
            [guest_name, guest_address, phone_number, email, anniversary, dob, gst_no, company_name, discount, g_suggestion, property_id, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Guest record not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating guest record with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete a guest record by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM guest_record WHERE guest_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Guest record not found' });
        }

        res.status(200).json({ message: 'Guest record deleted successfully' });
    } catch (err) {
        console.error(`Error deleting guest record with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
