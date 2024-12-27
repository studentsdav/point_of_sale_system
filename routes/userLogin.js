const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// CREATE - Insert a new user
router.post('/', async (req, res) => {
  try {
    const {
      username,
      password_hash,
      dob,
      mobile,
      email,
      outlet,
      property_id,
      role,
      status, full_name, join_date
    } = req.body;

    const result = await pool.query(
      `INSERT INTO user_login 
       (username, password_hash, dob, mobile, email, outlet, property_id, role, status,full_name,join_date) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) 
       RETURNING *`,
      [username, password_hash, dob, mobile, email, outlet, property_id, role, status, full_name, join_date]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating user:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get all users
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM user_login');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching users:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get a user by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM user_login WHERE user_id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error fetching user with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE - Edit a user by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      username,
      password_hash,
      dob,
      mobile,
      email,
      outlet,
      property_id,
      role,
      status, full_name, join_date
    } = req.body;

    const result = await pool.query(
      `UPDATE user_login 
       SET username = $1, password_hash = $2, dob = $3, mobile = $4, email = $5, outlet = $6, 
           property_id = $7, role = $8, status = $9, full_name = $10, join_date = $11, updated_at = NOW() 
       WHERE user_id = $12
       RETURNING *`,
      [username, password_hash, dob, mobile, email, outlet, property_id, role, status, full_name, join_date, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error updating user with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// DELETE - Remove a user by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM user_login WHERE user_id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(204).end();
  } catch (err) {
    console.error(`Error deleting user with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

