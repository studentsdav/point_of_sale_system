const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// GET all table configurations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM table_configurations');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve table configurations', details: error.message });
  }
});


router.put('/clear/:tableno', async (req, res) => {
  const tableno = req.params.tableno;
  try {
    const result = await pool.query(
      `UPDATE table_configurations SET status = 'Vacant' WHERE table_no = $1 AND status = 'Dirty'`,
      [tableno]
    );
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve table configurations', details: error.message });
  }
});

// GET table configuration by ID
router.get('/:id', async (req, res) => {
  const tableId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM table_configurations WHERE id = $1', [tableId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Table configuration not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve table configuration', details: error.message });
  }
});

// POST (Create) new table configuration
router.post('/', async (req, res) => {
  const { table_no, seats, status, outlet_name, property_id, category, location } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO table_configurations (table_no, seats, status, outlet_name, property_id, category, location)
      VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
      [table_no, seats, status, outlet_name, property_id, category, location]
    );
    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration created'");
    res.status(201).json({ message: 'Table configuration created successfully', tableConfigId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create table configuration', details: error.message });
  }
});

// PUT (Update) table configuration by ID
router.put('/:id', async (req, res) => {
  const tableId = req.params.id;
  const { table_no, seats, status, outlet_name, category, location } = req.body;

  try {
    const result = await pool.query(
      `UPDATE table_configurations
      SET table_no = $1, seats = $2, status = $3, outlet_name = $4, category = $5, location= $6, updated_at = CURRENT_TIMESTAMP
      WHERE id = $7 RETURNING id`,
      [table_no, seats, status, outlet_name, tableId, category, location]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Table configuration not found' });
    }

    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration updated'");
    res.status(200).json({ message: 'Table configuration updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update table configuration', details: error.message });
  }
});

// DELETE table configuration by ID
router.delete('/:id', async (req, res) => {
  const tableId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM table_configurations WHERE id = $1 RETURNING id', [tableId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Table configuration not found' });
    }
    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration deleted'");
    res.status(200).json({ message: 'Table configuration deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete table configuration', details: error.message });
  }
});

module.exports = router;
