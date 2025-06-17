const express = require('express');
const pool = require('../db'); // Your PostgreSQL database connection

const router = express.Router();

// Create or update customer loyalty points
router.post('/', async (req, res) => {
    try {
        const { guest_id, program_id, points } = req.body;

        if (!guest_id || !program_id || points === undefined) {
            return res.status(400).json({ message: 'Guest ID, Program ID, and Points are required' });
        }

        const result = await pool.query(
            `INSERT INTO customer_loyalty (guest_id, program_id, total_points, last_updated, expiry_date)
             VALUES ($1, $2, $3, NOW(), NOW() + INTERVAL '1 year')
             ON CONFLICT (guest_id) 
             DO UPDATE SET total_points = customer_loyalty.total_points + EXCLUDED.total_points, last_updated = NOW()
             RETURNING *`,
            [guest_id, program_id, points]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error updating customer loyalty points:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all customer loyalty records
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM customer_loyalty');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching customer loyalty records:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get customer loyalty record by guest ID
router.get('/:guest_id', async (req, res) => {
    try {
        const { guest_id } = req.params;
        const result = await pool.query('SELECT * FROM customer_loyalty WHERE guest_id = $1', [guest_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Customer loyalty record not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching loyalty record for Guest ID ${req.params.guest_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Redeem points from customer loyalty
router.put('/redeem/:guest_id', async (req, res) => {
    try {
        const { guest_id } = req.params;
        const { points_to_redeem } = req.body;

        if (!points_to_redeem || points_to_redeem <= 0) {
            return res.status(400).json({ message: 'Invalid points to redeem' });
        }

        const checkBalance = await pool.query('SELECT total_points FROM customer_loyalty WHERE guest_id = $1', [guest_id]);

        if (checkBalance.rows.length === 0) {
            return res.status(404).json({ message: 'Customer loyalty record not found' });
        }

        const currentPoints = checkBalance.rows[0].total_points;

        if (currentPoints < points_to_redeem) {
            return res.status(400).json({ message: 'Insufficient points' });
        }

        const result = await pool.query(
            `UPDATE customer_loyalty 
             SET total_points = total_points - $1, last_updated = NOW() 
             WHERE guest_id = $2 RETURNING *`,
            [points_to_redeem, guest_id]
        );

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error redeeming points for Guest ID ${req.params.guest_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete customer loyalty record
router.delete('/:guest_id', async (req, res) => {
    try {
        const { guest_id } = req.params;
        const result = await pool.query('DELETE FROM customer_loyalty WHERE guest_id = $1 RETURNING *', [guest_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Customer loyalty record not found' });
        }

        res.status(200).json({ message: 'Customer loyalty record deleted successfully' });
    } catch (err) {
        console.error(`Error deleting loyalty record for Guest ID ${req.params.guest_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
