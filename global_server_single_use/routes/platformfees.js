const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// GET all platform fee configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM platformfees_config');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve platform fee configurations', details: error.message });
  }
});

// GET platform fee configuration by ID
router.get('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM platformfees_config WHERE id = $1', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Platform fee configuration not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve platform fee configuration', details: error.message });
  }
});

// POST (Create) new platform fee configuration
router.post('/', async (req, res) => {
  const { property_id, platform_fee, fee_type, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO platformfees_config (property_id, platform_fee, fee_type, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
      [property_id, platform_fee, fee_type, min_amount, max_amount, apply_on, status, start_date, outlet_name, tax]
    );
    res.status(201).json({ message: 'Platform fee configuration created successfully', platformFeeConfigId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create platform fee configuration', details: error.message });
  }
});

// PUT (Update) platform fee configuration by ID
router.put('/:id', async (req, res) => {
  const configId = req.params.id;
  const { platform_fee, min_amount, max_amount, apply_on, status, start_date } = req.body;

  try {
    const result = await pool.query(
      `UPDATE platformfees_config
      SET platform_fee = $1, min_amount = $2, max_amount = $3, apply_on = $4, status = $5, start_date = $6, updated_at = CURRENT_TIMESTAMP
      WHERE id = $7 RETURNING id`,
      [platform_fee, min_amount, max_amount, apply_on, status, start_date, configId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Platform fee configuration not found' });
    }

    res.status(200).json({ message: 'Platform fee configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update platform fee configuration', details: error.message });
  }
});

// DELETE platform fee configuration by ID
router.delete('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM platformfees_config WHERE id = $1 RETURNING id', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Platform fee configuration not found' });
    }
    res.status(200).json({ message: 'Platform fee configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete platform fee configuration', details: error.message });
  }
});

module.exports = router;
