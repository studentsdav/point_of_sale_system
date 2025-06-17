const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// GET all printer configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM printer_config');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve printer configurations', details: error.message });
  }
});

// GET printer configuration by ID
router.get('/:id', async (req, res) => {
  const printerId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM printer_config WHERE id = $1', [printerId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Printer configuration not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve printer configuration', details: error.message });
  }
});

// POST (Create) new printer configuration
router.post('/', async (req, res) => {
  const { printer_number, printer_name, printer_type, ip_address, port, status, property_id, outlet_name } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO printer_config (printer_number, printer_name, printer_type, ip_address, port, status, property_id, outlet_name)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
      [printer_number, printer_name, printer_type, ip_address, port, status, property_id, outlet_name]
    );
    res.status(201).json({ message: 'Printer configuration created successfully', printerId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create printer configuration', details: error.message });
  }
});

// PUT (Update) printer configuration by ID
router.put('/:id', async (req, res) => {
  const printerId = req.params.id;
  const { printer_number, printer_name, printer_type, ip_address, port, status, property_id, outlet_name } = req.body;

  try {
    const result = await pool.query(
      `UPDATE printer_config
      SET printer_number = $1, printer_name = $2, printer_type = $3, ip_address = $4, port = $5, status = $6, property_id = $7, outlet_name = $8, updated_at = CURRENT_TIMESTAMP
      WHERE id = $9 RETURNING id`,
      [printer_number, printer_name, printer_type, ip_address, port, status, property_id, outlet_name, printerId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Printer configuration not found' });
    }

    res.status(200).json({ message: 'Printer configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update printer configuration', details: error.message });
  }
});

// DELETE printer configuration by ID
router.delete('/:id', async (req, res) => {
  const printerId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM printer_config WHERE id = $1 RETURNING id', [printerId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Printer configuration not found' });
    }
    res.status(200).json({ message: 'Printer configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete printer configuration', details: error.message });
  }
});

module.exports = router;
