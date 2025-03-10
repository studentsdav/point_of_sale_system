const express = require('express');
const pool = require('../db'); // PostgreSQL database connection

const router = express.Router();

// Create a new loyalty transaction (earn or redeem points)
router.post('/', async (req, res) => {
    try {
        const { guest_id, program_id, order_id, points_earned, points_redeemed, transaction_type, expiry_date, store_id, payment_method } = req.body;

        if (!guest_id || !program_id || !transaction_type || !store_id || !payment_method) {
            return res.status(400).json({ message: 'Guest ID, Program ID, Transaction Type, Store ID, and Payment Method are required' });
        }

        if (transaction_type === 'redeem' && (!points_redeemed || points_redeemed <= 0)) {
            return res.status(400).json({ message: 'Points to redeem must be greater than zero' });
        }

        if (transaction_type === 'earn' && (!points_earned || points_earned <= 0)) {
            return res.status(400).json({ message: 'Points earned must be greater than zero' });
        }

        const result = await pool.query(
            `INSERT INTO loyalty_transactions (guest_id, program_id, order_id, points_earned, points_redeemed, transaction_type, expiry_date, store_id, payment_method, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW()) RETURNING *`,
            [guest_id, program_id, order_id, points_earned || 0, points_redeemed || 0, transaction_type, expiry_date, store_id, payment_method]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error creating loyalty transaction:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all loyalty transactions
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM loyalty_transactions ORDER BY created_at DESC');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching loyalty transactions:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get loyalty transactions by guest ID
router.get('/guest/:guest_id', async (req, res) => {
    try {
        const { guest_id } = req.params;
        const result = await pool.query('SELECT * FROM loyalty_transactions WHERE guest_id = $1 ORDER BY created_at DESC', [guest_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'No loyalty transactions found for this guest' });
        }

        res.status(200).json(result.rows);
    } catch (err) {
        console.error(`Error fetching loyalty transactions for Guest ID ${guest_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get loyalty transactions by store ID
router.get('/store/:store_id', async (req, res) => {
    try {
        const { store_id } = req.params;
        const result = await pool.query('SELECT * FROM loyalty_transactions WHERE store_id = $1 ORDER BY created_at DESC', [store_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'No loyalty transactions found for this store' });
        }

        res.status(200).json(result.rows);
    } catch (err) {
        console.error(`Error fetching loyalty transactions for Store ID ${store_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete a loyalty transaction by ID
router.delete('/:transaction_id', async (req, res) => {
    try {
        const { transaction_id } = req.params;
        const result = await pool.query('DELETE FROM loyalty_transactions WHERE transaction_id = $1 RETURNING *', [transaction_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Loyalty transaction not found' });
        }

        res.status(200).json({ message: 'Loyalty transaction deleted successfully' });
    } catch (err) {
        console.error(`Error deleting loyalty transaction with ID ${transaction_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
