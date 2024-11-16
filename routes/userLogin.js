const express = require('express');
const pool = require('../db');

const router = express.Router();

// Get user details by ID
router.get('/users/:id.json', async (req, res) => {
  try {
    const { id } = req.params; // Get user ID from URL parameter
    const result = await pool.query('SELECT * FROM user_login WHERE user_id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error fetching user with ID ${req.params.id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
