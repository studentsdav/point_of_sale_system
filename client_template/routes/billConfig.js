const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// CREATE - Insert a new bill configuration
router.post('/', async (req, res) => {
  try {
    const {
      property_id,
      selected_outlet,
      bill_prefix,
      bill_suffix,
      starting_bill_number,
      series_start_date,
      currency_symbol,
      date_format
    } = req.body;

    const result = await pool.query(
      `INSERT INTO bill_config 
       (property_id, selected_outlet, bill_prefix, bill_suffix, starting_bill_number, series_start_date, currency_symbol, date_format) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
       RETURNING *`,
      [
        property_id,
        selected_outlet,
        bill_prefix,
        bill_suffix,
        starting_bill_number,
        series_start_date,
        currency_symbol,
        date_format
      ]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating bill configuration:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get all bill configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM bill_config');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching bill configurations:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get a bill configuration by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM bill_config WHERE config_id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Bill configuration not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error fetching bill configuration with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE - Edit a bill configuration by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      property_id,
      selected_outlet,
      bill_prefix,
      bill_suffix,
      starting_bill_number,
      series_start_date,
      currency_symbol,
      date_format
    } = req.body;

    const result = await pool.query(
      `UPDATE bill_config 
       SET property_id = $1, selected_outlet = $2, bill_prefix = $3, bill_suffix = $4, 
           starting_bill_number = $5, series_start_date = $6, currency_symbol = $7, 
           date_format = $8, updated_at = NOW() 
       WHERE config_id = $9 
       RETURNING *`,
      [
        property_id,
        selected_outlet,
        bill_prefix,
        bill_suffix,
        starting_bill_number,
        series_start_date,
        currency_symbol,
        date_format,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Bill configuration not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error updating bill configuration with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// DELETE - Remove a bill configuration by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM bill_config WHERE config_id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Bill configuration not found' });
    }
    res.status(204).end();
  } catch (err) {
    console.error(`Error deleting bill configuration with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
