const express = require('express');
const pool = require('../db'); // Your PostgreSQL database connection

const router = express.Router();

// Create a new happy hour configuration
router.post('/', async (req, res) => {
    try {
        const {
            property_id,
            selected_outlet,
            selected_happy_hour,
            start_time,
            end_time,
            selected_items,
            discount
        } = req.body;

        if (!property_id) {
            return res.status(400).json({ message: 'Property ID is required' });
        }

        const result = await pool.query(
            `INSERT INTO happy_hour_config (property_id, selected_outlet, selected_happy_hour, start_time, end_time, selected_items, discount)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [property_id, selected_outlet, selected_happy_hour, start_time, end_time, selected_items, discount]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error creating happy hour config:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all happy hour configurations
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM happy_hour_config');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching happy hour configs:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get a specific happy hour configuration by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM happy_hour_config WHERE id = $1', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Happy hour config not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching happy hour config with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update a happy hour configuration by ID
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const {
            property_id,
            selected_outlet,
            selected_happy_hour,
            start_time,
            end_time,
            selected_items,
            discount
        } = req.body;

        if (!property_id) {
            return res.status(400).json({ message: 'Property ID is required' });
        }

        const result = await pool.query(
            `UPDATE happy_hour_config
             SET property_id = $1, selected_outlet = $2, selected_happy_hour = $3, start_time = $4, end_time = $5, selected_items = $6, discount = $7, updated_at = NOW()
             WHERE id = $8 RETURNING *`,
            [property_id, selected_outlet, selected_happy_hour, start_time, end_time, selected_items, discount, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Happy hour config not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating happy hour config with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete a happy hour configuration by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM happy_hour_config WHERE id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Happy hour config not found' });
        }

        res.status(200).json({ message: 'Happy hour config deleted successfully' });
    } catch (err) {
        console.error(`Error deleting happy hour config with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
