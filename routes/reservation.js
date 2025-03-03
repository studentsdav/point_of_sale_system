const express = require('express');
const pool = require('../db'); // Database connection
const router = express.Router();
// GET all reservations
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM reservation');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve reservations', details: error.message });
  }
});

// GET reservation by ID
router.get('/:id', async (req, res) => {
  const reservationId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM reservation WHERE id = $1', [reservationId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve reservation', details: error.message });
  }
});

// POST (Create) new reservation
router.post('/', async (req, res) => {
  const { guest_name, contact_info, address, email, reservation_date, reservation_time, table_no, status, remark, property_id, outlet_name } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO reservation (guest_name, contact_info, address, email, reservation_date, reservation_time, table_no, status, remark, property_id, outlet_name)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id`,
      [guest_name, contact_info, address, email, reservation_date, reservation_time, table_no, status, remark, property_id, outlet_name]
    );

    await pool.query(
      `UPDATE table_configurations SET status = 'Booked' WHERE table_no = $1 AND status != 'Occupied'`,
      [table_no]
    );
    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration updated'");

    res.status(201).json({ message: 'Reservation created successfully', reservationId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create reservation', details: error.message });
  }
});

// PUT (Update) reservation by ID
router.put('/:id', async (req, res) => {
  const reservationId = req.params.id;
  const { guest_name, contact_info, address, email, reservation_date, reservation_time, table_no, status, remark, property_id, outlet_name } = req.body;

  try {
    const result = await pool.query(
      `UPDATE reservation
      SET guest_name = $1, contact_info = $2, address = $3, email = $4, reservation_date = $5, reservation_time = $6, table_no = $7, status = $8, remark = $9, property_id = $10, outlet_name = $11, updated_at = CURRENT_TIMESTAMP
      WHERE id = $12 RETURNING id`,
      [guest_name, contact_info, address, email, reservation_date, reservation_time, table_no, status, remark, property_id, outlet_name, reservationId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }

    res.status(200).json({ message: 'Reservation updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update reservation', details: error.message });
  }
});

// DELETE reservation by ID
router.delete('/:id', async (req, res) => {
  const reservationId = req.params.id;
  const { tableNo } = req.body;
  try {
    const result = await pool.query('DELETE FROM reservation WHERE id = $1 RETURNING id', [reservationId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Reservation not found' });
    }
    await pool.query(
      `UPDATE table_configurations SET status = 'Vacant' WHERE table_no = $1`,
      [tableNo]
    );
    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration updated'");
    res.status(200).json({ message: 'Reservation deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete reservation', details: error.message });
  }
});

module.exports = router;
