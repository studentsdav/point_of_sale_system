const express = require('express');
const pool = require('../db'); // PostgreSQL database connection

const router = express.Router();

// Create a new redemption limit
router.post('/', async (req, res) => {
    try {
        const { program_id, min_spend_amount, max_daily_redeem, max_monthly_redeem } = req.body;

        if (!program_id) {
            return res.status(400).json({ message: 'Program ID is required' });
        }

        const result = await pool.query(
            `INSERT INTO loyalty_redemption_limits (program_id, min_spend_amount, max_daily_redeem, max_monthly_redeem, created_at)
             VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
            [program_id, min_spend_amount || 1000, max_daily_redeem || 500, max_monthly_redeem || 5000]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting redemption limit:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get all redemption limits
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM loyalty_redemption_limits ORDER BY created_at DESC');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching redemption limits:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get redemption limit by program ID
router.get('/program/:program_id', async (req, res) => {
    try {
        const { program_id } = req.params;
        const result = await pool.query('SELECT * FROM loyalty_redemption_limits WHERE program_id = $1', [program_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'No redemption limits found for this program' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error fetching redemption limit for Program ID ${program_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update a redemption limit by ID
router.put('/:limit_id', async (req, res) => {
    try {
        const { limit_id } = req.params;
        const { min_spend_amount, max_daily_redeem, max_monthly_redeem } = req.body;

        const result = await pool.query(
            `UPDATE loyalty_redemption_limits
             SET min_spend_amount = $1, max_daily_redeem = $2, max_monthly_redeem = $3, created_at = NOW()
             WHERE limit_id = $4 RETURNING *`,
            [min_spend_amount, max_daily_redeem, max_monthly_redeem, limit_id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Redemption limit not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error(`Error updating redemption limit with ID ${limit_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete a redemption limit by ID
router.delete('/:limit_id', async (req, res) => {
    try {
        const { limit_id } = req.params;
        const result = await pool.query('DELETE FROM loyalty_redemption_limits WHERE limit_id = $1 RETURNING *', [limit_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Redemption limit not found' });
        }

        res.status(200).json({ message: 'Redemption limit deleted successfully' });
    } catch (err) {
        console.error(`Error deleting redemption limit with ID ${limit_id}:`, err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
