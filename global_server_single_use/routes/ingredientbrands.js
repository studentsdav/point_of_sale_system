const express = require('express');
const router = express.Router();
const pool = require('../db'); // Assuming PostgreSQL connection is set up

// Get all ingredient brands
router.get('/ingredient-brands', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM ingredient_brands ORDER BY brand_id');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single ingredient brand by ID
router.get('/ingredient-brands/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM ingredient_brands WHERE brand_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Brand not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new ingredient brand
router.post('/ingredient-brands', async (req, res) => {
    try {
        const { brand_name } = req.body;
        const result = await pool.query(
            'INSERT INTO ingredient_brands (brand_name) VALUES ($1) RETURNING *',
            [brand_name]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating brand' });
    }
});

// Update an existing ingredient brand
router.put('/ingredient-brands/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { brand_name } = req.body;
        const result = await pool.query(
            'UPDATE ingredient_brands SET brand_name = $1 WHERE brand_id = $2 RETURNING *',
            [brand_name, id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Brand not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating brand' });
    }
});

// Delete an ingredient brand
router.delete('/ingredient-brands/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM ingredient_brands WHERE brand_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Brand not found' });
        res.json({ message: 'Brand deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting brand' });
    }
});

module.exports = router;
