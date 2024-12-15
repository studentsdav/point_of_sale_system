const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// Create a new category
router.post('/', async (req, res) => {
    try {
        const { property_id, outlet, category_name, category_description, sub_category_name, sub_category_description } = req.body;

        const result = await pool.query(
            `INSERT INTO categories (property_id, outlet, category_name, category_description, sub_category_name, sub_category_description)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [property_id, outlet, category_name, category_description, sub_category_name, sub_category_description]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting category:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all categories
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM categories');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching categories:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get category by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query('SELECT * FROM categories WHERE category_id = $1', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Category not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching category with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});



// Update a category by ID
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { property_id, outlet, category_name, category_description, sub_category_name, sub_category_description } = req.body;

        const result = await pool.query(
            `UPDATE categories
             SET property_id = $1, outlet = $2, category_name = $3, category_description = $4, sub_category_name = $5, sub_category_description = $6, updated_at = NOW()
             WHERE category_id = $7 RETURNING *`,
            [property_id, outlet, category_name, category_description, sub_category_name, sub_category_description, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Category not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating category with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete a category by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query('DELETE FROM categories WHERE category_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Category not found' });
        }

        res.status(204).end();
    } catch (err) {
        console.error(`Error deleting category with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
