const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Get all recipes
router.get('/recipes', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM recipes ORDER BY created_at DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single recipe by ID
router.get('/recipes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM recipes WHERE recipe_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Recipe not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get all recipes for a specific menu item
router.get('/recipes/menu-item/:menu_item_id', async (req, res) => {
    try {
        const { menu_item_id } = req.params;
        const result = await pool.query('SELECT * FROM recipes WHERE menu_item_id = $1', [menu_item_id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'No recipes found for this menu item' });
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new recipe
router.post('/recipes', async (req, res) => {
    try {
        const { menu_item_id, ingredient_id, category_id, subcategory_id, brand_id, quantity_used, unit } = req.body;
        const result = await pool.query(`
            INSERT INTO recipes (menu_item_id, ingredient_id, category_id, subcategory_id, brand_id, quantity_used, unit, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP) RETURNING *
        `, [menu_item_id, ingredient_id, category_id, subcategory_id, brand_id, quantity_used, unit]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating recipe' });
    }
});

// Update an existing recipe
router.put('/recipes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { menu_item_id, ingredient_id, category_id, subcategory_id, brand_id, quantity_used, unit } = req.body;
        const result = await pool.query(`
            UPDATE recipes 
            SET menu_item_id = $1, ingredient_id = $2, category_id = $3, subcategory_id = $4, brand_id = $5, quantity_used = $6, unit = $7
            WHERE recipe_id = $8 RETURNING *
        `, [menu_item_id, ingredient_id, category_id, subcategory_id, brand_id, quantity_used, unit, id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Recipe not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating recipe' });
    }
});

// Delete a recipe
router.delete('/recipes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM recipes WHERE recipe_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Recipe not found' });
        res.json({ message: 'Recipe deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting recipe' });
    }
});

module.exports = router;
