const express = require('express');
const pool = require('../db'); // Your PostgreSQL database connection

const router = express.Router();

// Create a new inventory transaction
router.post('/', async (req, res) => {
    try {
        const {
            property_id,
            selected_outlet,
            selected_item,
            quantity,
            transaction_type,
            selected_date
        } = req.body;

        if (!property_id || !selected_item || !quantity || !transaction_type || !selected_date) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const result = await pool.query(
            `INSERT INTO inventory (property_id, selected_outlet, selected_item, quantity, transaction_type, selected_date)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [property_id, selected_outlet, selected_item, quantity, transaction_type, selected_date]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error creating inventory transaction:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all inventory transactions
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM inventory');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching inventory transactions:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get a specific inventory transaction by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM inventory WHERE id = $1', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Inventory transaction not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching inventory transaction with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update an inventory transaction by ID
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const {
            property_id,
            selected_outlet,
            selected_item,
            quantity,
            transaction_type,
            selected_date
        } = req.body;

        if (!property_id || !selected_item || !quantity || !transaction_type || !selected_date) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const result = await pool.query(
            `UPDATE inventory
             SET property_id = $1, selected_outlet = $2, selected_item = $3, quantity = $4, transaction_type = $5, selected_date = $6, updated_at = NOW()
             WHERE id = $7 RETURNING *`,
            [property_id, selected_outlet, selected_item, quantity, transaction_type, selected_date, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Inventory transaction not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating inventory transaction with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete an inventory transaction by ID
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM inventory WHERE id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Inventory transaction not found' });
        }

        res.status(200).json({ message: 'Inventory transaction deleted successfully' });
    } catch (err) {
        console.error(`Error deleting inventory transaction with ID ${req.params.id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
