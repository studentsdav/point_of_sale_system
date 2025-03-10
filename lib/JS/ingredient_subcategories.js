const express = require('express');
const router = express.Router();
const pool = require('../db'); // Assuming PostgreSQL connection is set up

// Get all ingredient subcategories
router.get('/ingredient-subcategories', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT s.*, c.category_name 
            FROM ingredient_subcategories s 
            JOIN ingredient_categories c ON s.category_id = c.category_id
            ORDER BY s.subcategory_id
        `);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single ingredient subcategory by ID
router.get('/ingredient-subcategories/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(`
            SELECT s.*, c.category_name 
            FROM ingredient_subcategories s 
            JOIN ingredient_categories c ON s.category_id = c.category_id
            WHERE s.subcategory_id = $1
        `, [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Subcategory not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new ingredient subcategory
router.post('/ingredient-subcategories', async (req, res) => {
    try {
        const { category_id, subcategory_name } = req.body;
        const result = await pool.query(
            'INSERT INTO ingredient_subcategories (category_id, subcategory_name) VALUES ($1, $2) RETURNING *',
            [category_id, subcategory_name]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating subcategory' });
    }
});

// Update an existing ingredient subcategory
router.put('/ingredient-subcategories/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { category_id, subcategory_name } = req.body;
        const result = await pool.query(
            'UPDATE ingredient_subcategories SET category_id = $1, subcategory_name = $2 WHERE subcategory_id = $3 RETURNING *',
            [category_id, subcategory_name, id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Subcategory not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating subcategory' });
    }
});

// Delete an ingredient subcategory
router.delete('/ingredient-subcategories/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM ingredient_subcategories WHERE subcategory_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Subcategory not found' });
        res.json({ message: 'Subcategory deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting subcategory' });
    }
});

module.exports = router;
