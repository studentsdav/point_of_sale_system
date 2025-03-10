const express = require('express');
const router = express.Router();
const pool = require('../db'); // Assuming PostgreSQL connection is set up

// Get all ingredients
router.get('/ingredients', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT i.*, c.category_name, s.subcategory_name, b.brand_name 
            FROM ingredients i
            LEFT JOIN ingredient_categories c ON i.category_id = c.category_id
            LEFT JOIN ingredient_subcategories s ON i.subcategory_id = s.subcategory_id
            LEFT JOIN ingredient_brands b ON i.brand_id = b.brand_id
            ORDER BY i.ingredient_id
        `);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single ingredient by ID
router.get('/ingredients/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(`
            SELECT i.*, c.category_name, s.subcategory_name, b.brand_name 
            FROM ingredients i
            LEFT JOIN ingredient_categories c ON i.category_id = c.category_id
            LEFT JOIN ingredient_subcategories s ON i.subcategory_id = s.subcategory_id
            LEFT JOIN ingredient_brands b ON i.brand_id = b.brand_id
            WHERE i.ingredient_id = $1
        `, [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Ingredient not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new ingredient
router.post('/ingredients', async (req, res) => {
    try {
        const { ingredient_name, category_id, subcategory_id, brand_id, stock_quantity, unit, min_stock_level, reorder_level } = req.body;
        const result = await pool.query(`
            INSERT INTO ingredients (ingredient_name, category_id, subcategory_id, brand_id, stock_quantity, unit, min_stock_level, reorder_level) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *
        `, [ingredient_name, category_id, subcategory_id, brand_id, stock_quantity, unit, min_stock_level, reorder_level]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating ingredient' });
    }
});

// Update an existing ingredient
router.put('/ingredients/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { ingredient_name, category_id, subcategory_id, brand_id, stock_quantity, unit, min_stock_level, reorder_level } = req.body;
        const result = await pool.query(`
            UPDATE ingredients 
            SET ingredient_name = $1, category_id = $2, subcategory_id = $3, brand_id = $4, stock_quantity = $5, unit = $6, min_stock_level = $7, reorder_level = $8, updated_at = CURRENT_TIMESTAMP
            WHERE ingredient_id = $9 RETURNING *
        `, [ingredient_name, category_id, subcategory_id, brand_id, stock_quantity, unit, min_stock_level, reorder_level, id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Ingredient not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating ingredient' });
    }
});

// Delete an ingredient
router.delete('/ingredients/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM ingredients WHERE ingredient_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Ingredient not found' });
        res.json({ message: 'Ingredient deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting ingredient' });
    }
});

module.exports = router;
