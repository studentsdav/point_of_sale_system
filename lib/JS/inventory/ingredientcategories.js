const express = require('express');
const router = express.Router();
const pool = require('../db'); // Assuming PostgreSQL connection is set up

// Get all ingredient categories
router.get('/ingredient-categories', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM ingredient_categories ORDER BY category_id');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single ingredient category by ID
router.get('/ingredient-categories/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM ingredient_categories WHERE category_id = $1', [id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Category not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new ingredient category
router.post('/ingredient-categories', async (req, res) => {
    try {
        const { category_name } = req.body;
        const result = await pool.query(
            'INSERT INTO ingredient_categories (category_name) VALUES ($1) RETURNING *',
            [category_name]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating category' });
    }
});

// Update an existing ingredient category
router.put('/ingredient-categories/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { category_name } = req.body;
        const result = await pool.query(
            'UPDATE ingredient_categories SET category_name = $1 WHERE category_id = $2 RETURNING *',
            [category_name, id]
        );
        if (result.rows.length === 0) return res.status(404).json({ error: 'Category not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating category' });
    }
});

// Delete an ingredient category
router.delete('/ingredient-categories/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM ingredient_categories WHERE category_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) return res.status(404).json({ error: 'Category not found' });
        res.json({ message: 'Category deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting category' });
    }
});

module.exports = router;
