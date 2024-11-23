const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// Create a new date configuration
router.post('/', async (req, res) => {
    try {
        const { property_id, outlet, selected_date, description } = req.body;

        const result = await pool.query(
            `INSERT INTO date_config (property_id, outlet, selected_date, description)
             VALUES ($1, $2, $3, $4) RETURNING *`,
            [property_id, outlet, selected_date, description]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting date configuration:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all date configurations
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM date_config');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching date configurations:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get date configuration by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query('SELECT * FROM date_config WHERE date_config_id = $1', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Date configuration not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching date configuration with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update a date configuration by ID
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { selected_date, description } = req.body;

        const result = await pool.query(
            `UPDATE date_config
             SET selected_date = $1, description = $2, updated_at = NOW()
             WHERE date_config_id = $3 RETURNING *`,
            [selected_date, description, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Date configuration not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating date configuration with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete a date configuration by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query('DELETE FROM date_config WHERE date_config_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Date configuration not found' });
        }

        res.status(204).end();
    } catch (err) {
        console.error(`Error deleting date configuration with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
