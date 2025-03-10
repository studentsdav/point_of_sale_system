const express = require('express');
const pool = require('../db'); // PostgreSQL database connection

const router = express.Router();

// 📌 Create a new Loyalty Program
router.post('/', async (req, res) => {
    try {
        const { name, points_per_currency, redemption_value, min_points_redeemable, points_expiry_days, tier, max_redeemable_points } = req.body;

        const result = await pool.query(
            `INSERT INTO loyalty_programs 
            (name, points_per_currency, redemption_value, min_points_redeemable, points_expiry_days, tier, max_redeemable_points)
            VALUES ($1, $2, $3, $4, $5, $6, $7) 
            RETURNING *`,
            [name, points_per_currency, redemption_value, min_points_redeemable, points_expiry_days, tier, max_redeemable_points]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting loyalty program:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// 📌 Search Loyalty Programs (by name or tier)
router.post('/search', async (req, res) => {
    try {
        const { query } = req.body;

        if (!query) {
            return res.status(400).json({ error: 'Search query is required' });
        }

        const searchQuery = `
        SELECT * FROM loyalty_programs
        WHERE LOWER(name) LIKE LOWER($1) OR LOWER(tier) LIKE LOWER($2)
        ORDER BY created_at DESC
        LIMIT 10
        `;

        const result = await pool.query(searchQuery, [`%${query}%`, `%${query}%`]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'No loyalty programs found' });
        }

        res.json(result.rows);
    } catch (err) {
        console.error('Error searching loyalty programs:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// 📌 Get all Loyalty Programs
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM loyalty_programs ORDER BY created_at DESC');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching loyalty programs:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// 📌 Get Loyalty Program by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM loyalty_programs WHERE program_id = $1', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Loyalty program not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching loyalty program with ID ${id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// 📌 Update Loyalty Program by ID
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, points_per_currency, redemption_value, min_points_redeemable, points_expiry_days, tier, max_redeemable_points } = req.body;

        const result = await pool.query(
            `UPDATE loyalty_programs
            SET name = $1, points_per_currency = $2, redemption_value = $3, 
                min_points_redeemable = $4, points_expiry_days = $5, tier = $6, 
                max_redeemable_points = $7, created_at = NOW()
            WHERE program_id = $8 RETURNING *`,
            [name, points_per_currency, redemption_value, min_points_redeemable, points_expiry_days, tier, max_redeemable_points, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Loyalty program not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating loyalty program with ID ${id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// 📌 Delete Loyalty Program by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM loyalty_programs WHERE program_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Loyalty program not found' });
        }

        res.status(200).json({ message: 'Loyalty program deleted successfully' });
    } catch (err) {
        console.error(`Error deleting loyalty program with ID ${id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
