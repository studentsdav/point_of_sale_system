const express = require('express');
const pool = require('../db');

const router = express.Router();

// User registration route
router.post('/register', async (req, res) => {
  try {
    const { username, password_hash, dob, mobile, email, outlet, property_id, role } = req.body;
    const result = await pool.query(
      `INSERT INTO user_login 
       (username, password_hash, dob, mobile, email, outlet, property_id, role) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [username, password_hash, dob, mobile, email, outlet, property_id, role]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error registering user:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
