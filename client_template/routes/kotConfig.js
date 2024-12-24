const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// CREATE - Insert a new KOT configuration
router.post('/', async (req, res) => {
  try {
    const {
      kot_starting_number,
      start_date,
      selected_outlet,
      property_id
    } = req.body;

    const result = await pool.query(
      `INSERT INTO kot_configs 
       (kot_starting_number, start_date, selected_outlet, property_id) 
       VALUES ($1, $2, $3, $4) 
       RETURNING *`,
      [
        kot_starting_number,
        start_date,
        selected_outlet,
        property_id
      ]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating KOT configuration:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get all KOT configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM kot_configs');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching KOT configurations:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get a KOT configuration by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM kot_configs WHERE kot_id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'KOT configuration not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error fetching KOT configuration with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE - Edit a KOT configuration by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      kot_starting_number,
      start_date,
      selected_outlet,
      property_id
    } = req.body;

    const result = await pool.query(
      `UPDATE kot_configs 
       SET kot_starting_number = $1, start_date = $2, selected_outlet = $3, 
           property_id = $4, update_date = NOW() 
       WHERE kot_id = $5 
       RETURNING *`,
      [
        kot_starting_number,
        start_date,
        selected_outlet,
        property_id,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'KOT configuration not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error updating KOT configuration with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// DELETE - Remove a KOT configuration by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM kot_configs WHERE kot_id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'KOT configuration not found' });
    }
    res.status(204).end();
  } catch (err) {
    console.error(`Error deleting KOT configuration with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
