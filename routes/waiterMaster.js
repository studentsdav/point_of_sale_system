const express = require('express');
const pool = require('../db');

const router = express.Router();

// Get all waiters
router.get('/waiters.json', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM waiter_master');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching waiters:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// Add new waiter
router.post('/waiters', async (req, res) => {
  try {
    const { name, contact } = req.body;
    const result = await pool.query(
      `INSERT INTO waiter_master (name, contact) 
       VALUES ($1, $2) RETURNING *`,
      [name, contact]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding waiter:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
