const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();
// 1. GET Tax Configuration by ID
router.get('/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('SELECT * FROM tax_config WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Tax configuration not found' });
    }

    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch tax configuration', details: error.message });
  }
});

// 2. GET All Tax Configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tax_config');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch tax configurations', details: error.message });
  }
});

// 3. POST Create a New Tax Configuration
router.post('/', async (req, res) => {
  const {
    tax_name,
    tax_percentage,
    tax_type,
    outlet_name,
    property_id,
    greater_than,
    less_than,
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO tax_config (tax_name, tax_percentage, tax_type, outlet_name, property_id, greater_than, less_than)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
      [tax_name, tax_percentage, tax_type, outlet_name, property_id, greater_than, less_than]
    );

    res.status(201).json({ message: 'Tax configuration created successfully', id: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create tax configuration', details: error.message });
  }
});

// 4. PUT Update an Existing Tax Configuration
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const {
    tax_name,
    tax_percentage,
    tax_type,
    outlet_name,
    property_id,
    greater_than,
    less_than,
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE tax_config 
       SET tax_name = $1, tax_percentage = $2, tax_type = $3, outlet_name = $4, property_id = $5, 
           greater_than = $6, less_than = $7, updated_at = CURRENT_TIMESTAMP
       WHERE id = $8 RETURNING id`,
      [tax_name, tax_percentage, tax_type, outlet_name, property_id, greater_than, less_than, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Tax configuration not found' });
    }

    res.status(200).json({ message: 'Tax configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update tax configuration', details: error.message });
  }
});

// 5. DELETE a Tax Configuration
router.delete('/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM tax_config WHERE id = $1 RETURNING id', [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Tax configuration not found' });
    }

    res.status(200).json({ message: 'Tax configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete tax configuration', details: error.message });
  }
});

module.exports = router;
