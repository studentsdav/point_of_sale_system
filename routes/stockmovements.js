const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Get all stock movements
router.get('/stock-movements', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM stock_movements ORDER BY movement_date DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single stock movement by ID
router.get('/stock-movements/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM stock_movements WHERE movement_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Stock movement not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get all stock movements for a specific ingredient
router.get('/stock-movements/ingredient/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM stock_movements WHERE ingredient_id = $1 ORDER BY movement_date DESC', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'No movements found for this ingredient' });
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Record a new stock movement
router.post('/stock-movements', async (req, res) => {
    try {
        const { ingredient_id, category_id, subcategory_id, brand_id, change_type, quantity, reason } = req.body;
        const result = await pool.query(`
            INSERT INTO stock_movements (ingredient_id, category_id, subcategory_id, brand_id, change_type, quantity, reason, movement_date)
            VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP) RETURNING *
        `, [ingredient_id, category_id, subcategory_id, brand_id, change_type, quantity, reason]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error recording stock movement' });
    }
});

// Delete a stock movement
router.delete('/stock-movements/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM stock_movements WHERE movement_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Stock movement not found' });
        res.json({ message: 'Stock movement deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting stock movement' });
    }
});

module.exports = router;
