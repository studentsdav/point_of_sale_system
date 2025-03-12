const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Create a new promo code
router.post('/promo-codes', async (req, res) => {
    try {
        const { code, discount_id, max_uses, per_user_limit, is_active } = req.body;
        const result = await pool.query(
            `INSERT INTO promo_codes (code, discount_id, max_uses, per_user_limit, is_active) 
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [code, discount_id, max_uses, per_user_limit, is_active]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while adding promo code' });
    }
});

// Get all promo codes
router.get('/promo-codes', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM promo_codes ORDER BY created_at DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching promo codes' });
    }
});

// Get promo code by ID
router.get('/promo-codes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM promo_codes WHERE promo_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Promo code not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching promo code' });
    }
});

// Get promo code by code
router.get('/promo-codes/code/:code', async (req, res) => {
    try {
        const { code } = req.params;
        const result = await pool.query('SELECT * FROM promo_codes WHERE code = $1', [code]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Promo code not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching promo code' });
    }
});

// Update promo code details
router.put('/promo-codes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { code, discount_id, max_uses, per_user_limit, is_active } = req.body;
        const result = await pool.query(
            `UPDATE promo_codes 
             SET code = $1, discount_id = $2, max_uses = $3, per_user_limit = $4, is_active = $5 
             WHERE promo_id = $6 RETURNING *`,
            [code, discount_id, max_uses, per_user_limit, is_active, id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Promo code not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while updating promo code' });
    }
});

// Delete promo code
router.delete('/promo-codes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM promo_codes WHERE promo_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Promo code not found' });
        res.json({ message: 'Promo code deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while deleting promo code' });
    }
});

// Apply a promo code
router.post('/promo-codes/apply', async (req, res) => {
    try {
        const { user_id, code } = req.body;

        // Check if promo code exists and is active
        const promo = await pool.query('SELECT * FROM promo_codes WHERE code = $1 AND is_active = TRUE', [code]);
        if (promo.rows.length === 0) return res.status(400).json({ error: 'Invalid or expired promo code' });

        const promoData = promo.rows[0];

        // Check promo usage
        const usage = await pool.query(
            'SELECT COUNT(*) FROM user_promo_usage WHERE user_id = $1 AND promo_id = $2',
            [user_id, promoData.promo_id]
        );

        if (parseInt(usage.rows[0].count) >= promoData.per_user_limit) {
            return res.status(400).json({ error: 'Promo code usage limit reached' });
        }

        if (promoData.usage_count >= promoData.max_uses) {
            return res.status(400).json({ error: 'Promo code has been used maximum times' });
        }

        // Apply promo code (increase usage count)
        await pool.query('UPDATE promo_codes SET usage_count = usage_count + 1 WHERE promo_id = $1', [promoData.promo_id]);
        await pool.query(
            'INSERT INTO user_promo_usage (user_id, promo_id, applied_at) VALUES ($1, $2, CURRENT_TIMESTAMP)',
            [user_id, promoData.promo_id]
        );

        res.json({ message: 'Promo code applied successfully', discount_id: promoData.discount_id });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while applying promo code' });
    }
});

module.exports = router;
