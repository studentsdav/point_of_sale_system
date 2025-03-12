const express = require('express');
const router = express.Router();
const pool = require('../db'); // Assuming PostgreSQL connection is set up

// Get all vendor payments
router.get('/vendor-payments', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM vendor_payments ORDER BY payment_id');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get a single vendor payment by ID
router.get('/vendor-payments/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM vendor_payments WHERE payment_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Vendor payment not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new vendor payment
router.post('/vendor-payments', async (req, res) => {
    try {
        const { vendor_id, purchase_id, expense_id, payment_amount, amount_paid, payment_method, due_amount, payment_date, status } = req.body;
        const result = await pool.query(`
            INSERT INTO vendor_payments (vendor_id, purchase_id, expense_id, payment_amount, amount_paid, payment_method, due_amount, payment_date, status) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *
        `, [vendor_id, purchase_id, expense_id, payment_amount, amount_paid, payment_method, due_amount, payment_date, status]);

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating vendor payment' });
    }
});

// Update an existing vendor payment
router.put('/vendor-payments/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { vendor_id, purchase_id, expense_id, payment_amount, amount_paid, payment_method, due_amount, payment_date, status } = req.body;
        const result = await pool.query(`
            UPDATE vendor_payments 
            SET vendor_id = $1, purchase_id = $2, expense_id = $3, payment_amount = $4, amount_paid = $5, payment_method = $6, due_amount = $7, payment_date = $8, status = $9
            WHERE payment_id = $10 RETURNING *
        `, [vendor_id, purchase_id, expense_id, payment_amount, amount_paid, payment_method, due_amount, payment_date, status, id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Vendor payment not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error updating vendor payment' });
    }
});

// Delete a vendor payment
router.delete('/vendor-payments/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            'DELETE FROM vendor_payments WHERE payment_id = $1 RETURNING *', [id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Vendor payment not found' });
        res.json({ message: 'Vendor payment deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error deleting vendor payment' });
    }
});

module.exports = router;
