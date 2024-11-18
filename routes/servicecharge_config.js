const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// GET all service charge configurations
router.get('/servicecharge-configs', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM servicecharge_config');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve service charge configurations', details: error.message });
  }
});

// GET service charge configuration by ID
router.get('/servicecharge-config/:id', async (req, res) => {
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
router.post('/servicecharge-config', async (req, res) => {
  const { property_id, service_charge, min_amount, max_amount, apply_on, status, start_date } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO servicecharge_config (property_id, service_charge, min_amount, max_amount, apply_on, status, start_date)
      VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
      [property_id, service_charge, min_amount, max_amount, apply_on, status, start_date]
    );
    res.status(201).json({ message: 'Service charge configuration created successfully', serviceChargeConfigId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create service charge configuration', details: error.message });
  }
});

// PUT (Update) service charge configuration by ID
router.put('/servicecharge-config/:id', async (req, res) => {
  const configId = req.params.id;
  const { property_id, service_charge, min_amount, max_amount, apply_on, status, start_date } = req.body;

  try {
    const result = await pool.query(
      `UPDATE servicecharge_config
      SET property_id = $1, service_charge = $2, min_amount = $3, max_amount = $4, apply_on = $5, status = $6, start_date = $7, updated_at = CURRENT_TIMESTAMP
      WHERE id = $8 RETURNING id`,
      [property_id, service_charge, min_amount, max_amount, apply_on, status, start_date, configId]
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
router.delete('/servicecharge-config/:id', async (req, res) => {
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
