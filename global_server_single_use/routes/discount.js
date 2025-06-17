const express = require('express');
const pool = require('../db'); // Your database connection module

const router = express.Router();

// GET all discount configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM discount_config');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve discount configurations', details: error.message });
  }
});

// GET discount configuration by ID
router.get('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM discount_config WHERE id = $1', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Discount configuration not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve discount configuration', details: error.message });
  }
});

// POST (Create) new discount configuration
router.post('/', async (req, res) => {
  const { property_id, discount_type, discount_value, min_amount, max_amount, apply_on, status, start_date, outlet_name } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO discount_config (property_id, discount_type, discount_value, min_amount, max_amount, apply_on, status, start_date, outlet_name)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
      [property_id, discount_type, discount_value, min_amount, max_amount, apply_on, status, start_date, outlet_name]
    );
    res.status(201).json({ message: 'Discount configuration created successfully', discountConfigId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create discount configuration', details: error.message });
  }
});

// PUT (Update) discount configuration by ID
router.put('/:id', async (req, res) => {
  const configId = req.params.id;
  const { discount_type, discount_value, min_amount, max_amount, apply_on, status, start_date } = req.body;

  try {
    const result = await pool.query(
      `UPDATE discount_config
      SET discount_type = $1, discount_value = $2, min_amount = $3, max_amount = $4, apply_on = $5, status = $6, start_date = $7, updated_at = CURRENT_TIMESTAMP
      WHERE id = $8 RETURNING id`,
      [discount_type, discount_value, min_amount, max_amount, apply_on, status, start_date, configId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Discount configuration not found' });
    }

    res.status(200).json({ message: 'Discount configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update discount configuration', details: error.message });
  }
});

// DELETE discount configuration by ID
router.delete('/:id', async (req, res) => {
  const configId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM discount_config WHERE id = $1 RETURNING id', [configId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Discount configuration not found' });
    }
    res.status(200).json({ message: 'Discount configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete discount configuration', details: error.message });
  }
});

module.exports = router;
