const express = require('express');
const pool = require('../db');

const router = express.Router();

// Get all items
router.get('/items.json', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM item_master');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching items:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Add new item
router.post('/items', async (req, res) => {
  try {
    const { item_name, price, stock_quantity } = req.body;
    const result = await pool.query(
      `INSERT INTO item_master (item_name, price, stock_quantity) 
       VALUES ($1, $2, $3) RETURNING *`,
      [item_name, price, stock_quantity]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding item:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
