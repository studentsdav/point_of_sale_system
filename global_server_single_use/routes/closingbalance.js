const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Get closing balance for all ingredients
router.get('/closing-balance', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM closing_balance ORDER BY ingredient_name');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching closing balance' });
    }
});

// Get closing balance for a specific ingredient
router.get('/closing-balance/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM closing_balance WHERE ingredient_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Ingredient not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching closing balance' });
    }
});

module.exports = router;
