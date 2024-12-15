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
  const {
    bill_id,
    payment_method,
    payment_amount,
    payment_date,
    transaction_id,
    remarks,
    outlet_name,
    property_id, table_no
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO payments (
        bill_id, payment_method, payment_amount, payment_date, transaction_id,
        remarks, outlet_name, property_id
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
      [
        bill_id,
        payment_method,
        payment_amount,
        payment_date,
        transaction_id,
        remarks,
        outlet_name,
        property_id
      ]
    );
    await pool.query(
      `UPDATE table_configurations SET status = 'Vacant' WHERE table_no = $1 AND status = 'Dirty'`,
      [table_no]
    );

    await pool.query(
      `UPDATE bills SET status = 'Paid' WHERE id = $1`,
      [bill_id]
    );
    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration updated'");

    res.status(201).json({
      message: 'Payment created successfully',
      paymentId: result.rows[0].id
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create payment', details: error.message });
  }
});

// PUT (Update) payment by ID
router.put('/:id', async (req, res) => {
  const paymentId = req.params.id;
  const {
    bill_id,
    payment_method,
    payment_amount,
    payment_date,
    transaction_id,
    remarks,
    outlet_name,
    property_id
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE payments
      SET
        bill_id = $1,
        payment_method = $2,
        payment_amount = $3,
        payment_date = $4,
        transaction_id = $5,
        remarks = $6,
        outlet_name = $7,
        property_id = $8,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $9 RETURNING id`,
      [
        bill_id,
        payment_method,
        payment_amount,
        payment_date,
        transaction_id,
        remarks,
        outlet_name,
        property_id,
        paymentId
      ]
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
