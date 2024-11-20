const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// GET all payments
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM payments');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve payments', details: error.message });
  }
});

// GET payment by ID
router.get('/:id', async (req, res) => {
  const paymentId = req.params.id;
  try {
    const result = await pool.query('SELECT * FROM payments WHERE id = $1', [paymentId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Payment not found' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve payment', details: error.message });
  }
});

// POST (Create) new payment
router.post('/', async (req, res) => {
  const { property_id, outlet_id, payment_method, amount, payment_date, bill_id } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO payments (property_id, outlet_id, payment_method, amount, payment_date, bill_id)
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`,
      [property_id, outlet_id, payment_method, amount, payment_date, bill_id]
    );
    res.status(201).json({ message: 'Payment created successfully', paymentId: result.rows[0].id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create payment', details: error.message });
  }
});

// PUT (Update) payment by ID
router.put('/:id', async (req, res) => {
  const paymentId = req.params.id;
  const { payment_method, amount, payment_date, bill_id } = req.body;

  try {
    const result = await pool.query(
      `UPDATE payments
      SET payment_method = $1, amount = $2, payment_date = $3, bill_id = $4, updated_at = CURRENT_TIMESTAMP
      WHERE id = $5 RETURNING id`,
      [payment_method, amount, payment_date, bill_id, paymentId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    res.status(200).json({ message: 'Payment updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update payment', details: error.message });
  }
});

// DELETE payment by ID
router.delete('/:id', async (req, res) => {
  const paymentId = req.params.id;
  try {
    const result = await pool.query('DELETE FROM payments WHERE id = $1 RETURNING id', [paymentId]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Payment not found' });
    }
    res.status(200).json({ message: 'Payment deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete payment', details: error.message });
  }
});

module.exports = router;
