const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Apply a discount to an order
router.post('/applied-discounts', async (req, res) => {
    try {
        const { order_id, guest_id, discount_id, promo_id, discount_amount } = req.body;

        const result = await pool.query(
            `INSERT INTO applied_discounts (order_id, guest_id, discount_id, promo_id, discount_amount) 
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [order_id, guest_id, discount_id, promo_id, discount_amount]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while applying discount' });
    }
});

// Get all applied discounts
router.get('/applied-discounts', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM applied_discounts ORDER BY applied_at DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching applied discounts' });
    }
});

// Get applied discount by ID
router.get('/applied-discounts/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM applied_discounts WHERE applied_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Applied discount not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching applied discount' });
    }
});

// Get applied discounts for a specific order
router.get('/applied-discounts/order/:order_id', async (req, res) => {
    try {
        const { order_id } = req.params;
        const result = await pool.query('SELECT * FROM applied_discounts WHERE order_id = $1', [order_id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'No discounts found for this order' });
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching discounts for order' });
    }
});

// Remove an applied discount
router.delete('/applied-discounts/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM applied_discounts WHERE applied_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Applied discount not found' });
        res.json({ message: 'Applied discount removed successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while removing applied discount' });
    }
});

module.exports = router;
