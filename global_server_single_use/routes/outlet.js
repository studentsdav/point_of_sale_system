const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// GET all outlet configurations
router.get('/outlets', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM outlet_configurations');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve outlet configurations', details: error.message });
  }
});

// GET outlet configuration by propertyid
router.get('/outlets/:propertyId', async (req, res) => {
  const outletId = req.params.propertyId;
  try {
    const result = await pool.query('SELECT * FROM outlet_configurations WHERE property_id = $1', [outletId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Outlet configuration not found' });
    }
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve outlet configuration', details: error.message });
  }
});

// GET outlet configuration by ID
router.get('/outlet/:id', async (req, res) => {
  const outletId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM outlet_configurations WHERE property_id = $1', [outletId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Outlet configuration not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve outlet configuration', details: error.message });
  }
});

// POST (Create) new outlet configuration
router.post('/outlet', async (req, res) => {
  const {
    property_id,
    outlet_name,
    address,
    city,
    country,
    state,
    contact_number,
    manager_name,
    opening_hours,
    currency,
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO outlet_configurations (property_id, outlet_name, address, city, country, state, contact_number, manager_name, opening_hours, currency)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
      [property_id, outlet_name, address, city, country, state, contact_number, manager_name, opening_hours, currency]
    );
    res.status(201).json({ message: 'Outlet configuration created successfully', outletId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create outlet configuration', details: error.message });
  }
});

// PUT (Update) outlet configuration by ID
router.put('/outlet/:id', async (req, res) => {
  const outletId = req.params.id;
  const {
    outlet_name,
    address,
    city,
    country,
    state,
    contact_number,
    manager_name,
    opening_hours,
    currency,
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE outlet_configurations
      SET outlet_name = $1, address = $2, city = $3, country = $4, state = $5, contact_number = $6, manager_name = $7,
          opening_hours = $8, currency = $9, updated_at = CURRENT_TIMESTAMP
      WHERE id = $10 RETURNING id`,
      [
        outlet_name, address, city, country, state, contact_number, manager_name, opening_hours, currency, outletId
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Outlet configuration not found' });
    }

    res.status(200).json({ message: 'Outlet configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update outlet configuration', details: error.message });
  }
});

// DELETE outlet configuration by ID
router.delete('/outlet/:id', async (req, res) => {
  const outletId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM outlet_configurations WHERE id = $1 RETURNING id', [outletId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Outlet configuration not found' });
    }
    res.status(200).json({ message: 'Outlet configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete outlet configuration', details: error.message });
  }
});

module.exports = router;
