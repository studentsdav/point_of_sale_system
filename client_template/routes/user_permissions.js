const express = require('express');
const pool = require('../db');  // Replace with your database connection file

const router = express.Router();

// CREATE - Insert a new user permission
router.post('/', async (req, res) => {
  try {
    const {
      user_id,
      outlet_id,
      outlet_name,
      permission_name,
      property_id, username
    } = req.body;

    const result = await pool.query(
      `INSERT INTO user_permissions 
       (user_id, outlet_id, outlet_name, permission_name, property_id,username) 
       VALUES ($1, $2, $3, $4, $5, $6) 
       RETURNING *`,
      [user_id, outlet_id, outlet_name, permission_name, property_id, username]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating user permission:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get all user permissions
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM user_permissions');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching user permissions:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get a user permission by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM user_permissions WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User permission not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error fetching user permission with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE - Edit a user permission by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      user_id,
      outlet_id,
      outlet_name,
      permission_name,
      property_id, username
    } = req.body;

    const result = await pool.query(
      `UPDATE user_permissions 
       SET user_id = $1, outlet_id = $2, outlet_name = $3, permission_name = $4, property_id = $5, username = $6, updated_at = NOW() 
       WHERE id = $7
       RETURNING *`,
      [user_id, outlet_id, outlet_name, permission_name, property_id, username, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User permission not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error updating user permission with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// DELETE - Remove a user permission by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM user_permissions WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User permission not found' });
    }
    res.status(204).end();
  } catch (err) {
    console.error(`Error deleting user permission with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
