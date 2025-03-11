const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Get all purchases
router.get('/purchases', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM purchases ORDER BY purchase_date DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single purchase by ID
router.get('/purchases/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM purchases WHERE purchase_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Purchase not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new purchase
router.post('/purchases', async (req, res) => {
    try {
        const { vendor_id, total_cost, amount_paid, payment_status } = req.body;
        const result = await pool.query(`
            INSERT INTO purchases (vendor_id, total_cost, amount_paid, purchase_date, payment_status) 
            VALUES ($1, $2, $3, CURRENT_TIMESTAMP, $4) RETURNING *
        `, [vendor_id, total_cost, amount_paid, payment_status]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating purchase order' });
    }
});

// Update an existing purchase
router.put('/purchases/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { vendor_id, total_cost, amount_paid, payment_status } = req.body;
        const result = await pool.query(`
            UPDATE purchases 
            SET vendor_id = $1, total_cost = $2, amount_paid = $3, payment_status = $4
            WHERE purchase_id = $5 RETURNING *
        `, [vendor_id, total_cost, amount_paid, payment_status, id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Purchase not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating purchase order' });
    }
});

// Delete a purchase
router.delete('/purchases/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM purchases WHERE purchase_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Purchase not found' });
        res.json({ message: 'Purchase order deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting purchase order' });
    }
});

module.exports = router;
