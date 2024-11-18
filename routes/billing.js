const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();


// Update Bill with Necessary Fields
router.put('/:id/bill', async (req, res) => {
  const orderId = req.params.id;
  const {
    total_amount,
    total_tax,
    total_service_charge,
    net_receivable,
    cashier,
    total_discount_value,
    subtotal,
    total_happy_hour_discount,
    person_count,
    guest_id,
    status,
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE kot_orders SET
        total_amount = $1, total_tax = $2, total_service_charge = $3, net_receivable = $4,
        total_discount_value = $5, subtotal = $6, total_happy_hour_discount = $7,
        person_count = $8, guest_id = $9, status = $10, cashier = $11, updated_at = CURRENT_TIMESTAMP
      WHERE id = $12 RETURNING id`,
      [
        total_amount, total_tax, total_service_charge, net_receivable, total_discount_value,
        subtotal, total_happy_hour_discount, person_count, guest_id, status, cashier, orderId
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.status(200).json({ message: 'Bill updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update bill', details: error.message });
  }
});

// Generate Bill (Mark Order as Completed and Update Bill Number)
router.put('/:id/generate-bill', async (req, res) => {
  const orderId = req.params.id;
  const { bill_number, cashier } = req.body;

  try {
    const result = await pool.query(
      `UPDATE kot_orders SET
        status = 'completed', bill_number = $1, cashier = $2, updated_at = CURRENT_TIMESTAMP
      WHERE id = $3 RETURNING id`,
      [bill_number, cashier, orderId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Update kot_order_items for the same bill_number
    await pool.query(
      `UPDATE kot_order_items SET
        bill_number = $1, status = 'completed', updated_at = CURRENT_TIMESTAMP
      WHERE kot_order_id = $2`,
      [bill_number, orderId]
    );

    res.status(200).json({ message: 'Bill generated and order marked as completed successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate bill', details: error.message });
  }
});

// Delete Bill (Delete Order and Associated Items)
router.delete('/:id', async (req, res) => {
  const orderId = req.params.id;

  try {
    const result = await pool.query(
      `DELETE FROM kot_orders WHERE id = $1 RETURNING id`,
      [orderId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Delete associated order items
    await pool.query(`DELETE FROM kot_order_items WHERE kot_order_id = $1`, [orderId]);

    res.status(200).json({ message: 'Order and associated items deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete order and items', details: error.message });
  }
});

// Edit Bill (Update Bill Details)
router.put('/:id/edit-bill', async (req, res) => {
  const orderId = req.params.id;
  const {
    total_amount,
    total_tax,
    total_service_charge,
    net_receivable,
    cashier,
    total_discount_value,
    subtotal,
    total_happy_hour_discount,
    status,
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE kot_orders SET
        total_amount = $1, total_tax = $2, total_service_charge = $3, net_receivable = $4,
        total_discount_value = $5, subtotal = $6, total_happy_hour_discount = $7,
        status = $8, cashier = $9, updated_at = CURRENT_TIMESTAMP
      WHERE id = $10 RETURNING id`,
      [
        total_amount, total_tax, total_service_charge, net_receivable, total_discount_value,
        subtotal, total_happy_hour_discount, status, cashier, orderId
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.status(200).json({ message: 'Bill updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to edit bill', details: error.message });
  }
});

// Select Bill (Get Bill Details)
router.get('/:id/bill', async (req, res) => {
  const orderId = req.params.id;

  try {
    const result = await pool.query(
      `SELECT * FROM kot_orders WHERE id = $1`,
      [orderId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch bill', details: error.message });
  }
});

module.exports = router;
