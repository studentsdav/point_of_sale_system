const express = require('express');
const pool = require('../db'); // Database connection module

const router = express.Router();


// Create a new waiter

router.post('/', async (req, res) => {
  try {
    const { property_id, selected_outlet, waiter_name, contact_number, hire_date, status } = req.body;

    // Ensure property_id exists in the properties table
    const propertyCheck = await pool.query('SELECT * FROM properties WHERE property_id = $1', [property_id]);
    if (propertyCheck.rows.length === 0) {
      return res.status(400).json({ error: `Property with ID ${property_id} does not exist` });
    }

    const result = await pool.query(
      `INSERT INTO waiters (property_id, selected_outlet, waiter_name, contact_number, hire_date, status)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [property_id, selected_outlet, waiter_name, contact_number, hire_date, status]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating waiter:', err.message);
    res.status(500).json({ error: err.message });
  }
});


//Update an existing waiter

router.put('/:waiter_id', async (req, res) => {
  try {
    const { waiter_id } = req.params;
    const { property_id, selected_outlet, waiter_name, contact_number, hire_date, status } = req.body;

    // Ensure property_id exists in the properties table
    const propertyCheck = await pool.query('SELECT * FROM properties WHERE property_id = $1', [property_id]);
    if (propertyCheck.rows.length === 0) {
      return res.status(400).json({ error: `Property with ID ${property_id} does not exist` });
    }

    const result = await pool.query(
      `UPDATE waiters
       SET property_id = $1, selected_outlet = $2, waiter_name = $3, contact_number = $4, 
           hire_date = $5, status = $6, updated_at = NOW()
       WHERE waiter_id = $7 RETURNING *`,
      [property_id, selected_outlet, waiter_name, contact_number, hire_date, status, waiter_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Waiter not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating waiter:', err.message);
    res.status(500).json({ error: err.message });
  }
});


//Delete a waiter

router.delete('/:waiter_id', async (req, res) => {
  try {
    const { waiter_id } = req.params;

    const result = await pool.query('DELETE FROM waiters WHERE waiter_id = $1 RETURNING *', [waiter_id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Waiter not found' });
    }

    res.status(204).end(); // No content
  } catch (err) {
    console.error('Error deleting waiter:', err.message);
    res.status(500).json({ error: err.message });
  }
});


// Fetch all waiters

router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM waiters');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching waiters:', err.message);
    res.status(500).json({ error: err.message });
  }
});


// Fetch a waiter by ID

router.get('/:waiter_id', async (req, res) => {
  try {
    const { waiter_id } = req.params;

    const result = await pool.query('SELECT * FROM waiters WHERE waiter_id = $1', [waiter_id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Waiter not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching waiter:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
