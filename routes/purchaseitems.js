const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Get all purchase items
router.get('/purchase-items', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM purchase_items ORDER BY purchase_date DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single purchase item by ID
router.get('/purchase-items/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM purchase_items WHERE purchase_item_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Purchase item not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get all items for a specific purchase order
router.get('/purchase-items/purchase/:purchase_id', async (req, res) => {
    try {
        const { purchase_id } = req.params;
        const result = await pool.query('SELECT * FROM purchase_items WHERE purchase_id = $1', [purchase_id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'No items found for this purchase' });
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new purchase item
router.post('/purchase-items', async (req, res) => {
    try {
        const { purchase_id, ingredient_id, category_id, subcategory_id, brand_id, quantity, cost_per_unit, expiry_date } = req.body;
        const result = await pool.query(`
            INSERT INTO purchase_items (purchase_id, ingredient_id, category_id, subcategory_id, brand_id, quantity, cost_per_unit, expiry_date, purchase_date)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP) RETURNING *
        `, [purchase_id, ingredient_id, category_id, subcategory_id, brand_id, quantity, cost_per_unit, expiry_date]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating purchase item' });
    }
});

// Update an existing purchase item
router.put('/purchase-items/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { purchase_id, ingredient_id, category_id, subcategory_id, brand_id, quantity, cost_per_unit, expiry_date } = req.body;
        const result = await pool.query(`
            UPDATE purchase_items 
            SET purchase_id = $1, ingredient_id = $2, category_id = $3, subcategory_id = $4, brand_id = $5, quantity = $6, cost_per_unit = $7, expiry_date = $8
            WHERE purchase_item_id = $9 RETURNING *
        `, [purchase_id, ingredient_id, category_id, subcategory_id, brand_id, quantity, cost_per_unit, expiry_date, id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Purchase item not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating purchase item' });
    }
});

// Delete a purchase item
router.delete('/purchase-items/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM purchase_items WHERE purchase_item_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Purchase item not found' });
        res.json({ message: 'Purchase item deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting purchase item' });
    }
});

module.exports = router;
