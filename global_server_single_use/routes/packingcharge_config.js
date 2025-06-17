const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// GET all Packing charge configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM packingcharge_config');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve Packing charge configurations', details: error.message });
  }
});

// GET Packing charge configuration by ID
router.get('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM packingcharge_config WHERE id = $1', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Packing charge configuration not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve Packing charge configuration', details: error.message });
  }
});

// POST (Create) new Packing charge configuration
router.post('/', async (req, res) => {
  const { property_id, packing_charge, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO packingcharge_config (property_id, packing_charge, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
      [property_id, packing_charge, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax]
    );
    res.status(201).json({ message: 'Packing charge configuration created successfully', serviceChargeConfigId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create Packing charge configuration', details: error.message });
  }
});

// PUT (Update) Packing charge configuration by ID
router.put('/:id', async (req, res) => {
  const configId = req.params.id;
  const { packing_charge, min_amount, max_amount, apply_on, status, start_date } = req.body;

  try {
    const result = await pool.query(
      `UPDATE packingcharge_config
      SET packing_charge = $1, min_amount = $2, max_amount = $3, apply_on = $4, status = $5, start_date = $6, updated_at = CURRENT_TIMESTAMP
      WHERE id = $7 RETURNING id`,
      [packing_charge, min_amount, max_amount, apply_on, status, start_date, configId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Packing charge configuration not found' });
    }

    res.status(200).json({ message: 'Packing charge configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update Packing charge configuration', details: error.message });
  }
});

// DELETE Packing charge configuration by ID
router.delete('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM packingcharge_config WHERE id = $1 RETURNING id', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Packing charge configuration not found' });
    }
    res.status(200).json({ message: 'Packing charge configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete Packing charge configuration', details: error.message });
  }
});

module.exports = router;
