const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// GET all service charge configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM servicecharge_config');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve service charge configurations', details: error.message });
  }
});

// GET service charge configuration by ID
router.get('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM servicecharge_config WHERE id = $1', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Service charge configuration not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve service charge configuration', details: error.message });
  }
});

// POST (Create) new service charge configuration
router.post('/', async (req, res) => {
  const { property_id, service_charge, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO servicecharge_config (property_id, service_charge, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
      [property_id, service_charge, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax]
    );
    res.status(201).json({ message: 'Service charge configuration created successfully', serviceChargeConfigId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create service charge configuration', details: error.message });
  }
});

// PUT (Update) service charge configuration by ID
router.put('/:id', async (req, res) => {
  const configId = req.params.id;
  const { service_charge, min_amount, max_amount, apply_on, status, start_date } = req.body;

  try {
    const result = await pool.query(
      `UPDATE servicecharge_config
      SET service_charge = $1, min_amount = $2, max_amount = $3, apply_on = $4, status = $5, start_date = $6, updated_at = CURRENT_TIMESTAMP
      WHERE id = $7 RETURNING id`,
      [service_charge, min_amount, max_amount, apply_on, status, start_date, configId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Service charge configuration not found' });
    }

    res.status(200).json({ message: 'Service charge configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update service charge configuration', details: error.message });
  }
});

// DELETE service charge configuration by ID
router.delete('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM servicecharge_config WHERE id = $1 RETURNING id', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Service charge configuration not found' });
    }
    res.status(200).json({ message: 'Service charge configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete service charge configuration', details: error.message });
  }
});

module.exports = router;
