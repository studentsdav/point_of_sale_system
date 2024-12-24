const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// Create a new subcategory
router.post('/', async (req, res) => {
    try {
        const { property_id, outlet, category_id, sub_category_name, sub_category_description } = req.body;

        const result = await pool.query(
            `INSERT INTO subcategories (property_id, outlet, category_id, sub_category_name, sub_category_description)
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [property_id, outlet, category_id, sub_category_name, sub_category_description]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting subcategory:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all subcategories
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM subcategories');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching subcategories:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get subcategory by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query('SELECT * FROM subcategories WHERE sub_category_id = $1', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Subcategory not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching subcategory with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update a subcategory by ID
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { property_id, outlet, category_id, sub_category_name, sub_category_description } = req.body;

        const result = await pool.query(
            `UPDATE subcategories
             SET property_id = $1, outlet = $2, category_id = $3, sub_category_name = $4, sub_category_description = $5, updated_at = NOW()
             WHERE sub_category_id = $6 RETURNING *`,
            [property_id, outlet, category_id, sub_category_name, sub_category_description, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Subcategory not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating subcategory with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete a subcategory by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query('DELETE FROM subcategories WHERE sub_category_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Subcategory not found' });
        }

        res.status(204).end();
    } catch (err) {
        console.error(`Error deleting subcategory with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
