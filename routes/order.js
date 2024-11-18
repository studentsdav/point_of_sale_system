const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// Create Order
router.post('/', async (req, res) => {
  const {
    order_number,
    table_number,
    waiter_name,
    person_count,
    remarks,
    property_id,
    guest_id,
    total_discount_value,
    total_amount,
    total_tax,
    subtotal,
    total_service_charge,
    total_happy_hour_discount,
    net_receivable,
    cashier,
    items,
  } = req.body;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Insert into kot_orders
    const orderResult = await client.query(
      `INSERT INTO kot_orders (
          order_number, table_number, waiter_name, person_count, remarks,
          property_id, guest_id, total_discount_value, total_amount,
          total_tax, subtotal, total_service_charge, total_happy_hour_discount,
          net_receivable, cashier, status
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, 'pending'
        ) RETURNING id`,
      [
        order_number, table_number, waiter_name, person_count, remarks,
        property_id, guest_id, total_discount_value, total_amount, total_tax,
        subtotal, total_service_charge, total_happy_hour_discount, net_receivable, cashier,
      ]
    );

    const orderId = orderResult.rows[0].id;

    // Insert order items if available
    if (items && Array.isArray(items)) {
      for (let item of items) {
        await client.query(
          `INSERT INTO kot_order_items (
            kot_order_id, item_name, quantity, rate, amount, tax, tax_percentage, tax_value,
            discount, discount_percentage, happy_hour_discount, subtotal, total, cashier, property_id, bill_number, status, order_type, remarks
          ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
          )`,
          [
            orderId, item.item_name, item.quantity, item.rate, item.amount, item.tax, item.tax_percentage, item.tax_value,
            item.discount, item.discount_percentage, item.happy_hour_discount, item.subtotal, item.total, item.cashier,
            item.property_id, item.bill_number, item.status, item.order_type, item.remarks,
          ]
        );
      }
    }

    await client.query('COMMIT');
    res.status(201).json({ message: 'Order created successfully', orderId });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Failed to create order', details: error.message });
  } finally {
    client.release();
  }
});

// Update Order
router.put('/:id', async (req, res) => {
  const orderId = req.params.id;
  const {
    order_number,
    table_number,
    waiter_name,
    person_count,
    remarks,
    total_discount_value,
    total_amount,
    total_tax,
    subtotal,
    total_service_charge,
    total_happy_hour_discount,
    net_receivable,
    cashier,
    status,
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE kot_orders SET
        order_number = $1, table_number = $2, waiter_name = $3, person_count = $4,
        remarks = $5, total_discount_value = $6, total_amount = $7, total_tax = $8,
        subtotal = $9, total_service_charge = $10, total_happy_hour_discount = $11,
        net_receivable = $12, cashier = $13, status = $14, updated_at = CURRENT_TIMESTAMP
      WHERE id = $15 RETURNING id`,
      [
        order_number, table_number, waiter_name, person_count, remarks, total_discount_value, total_amount,
        total_tax, subtotal, total_service_charge, total_happy_hour_discount, net_receivable, cashier, status, orderId
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.status(200).json({ message: 'Order updated successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update order', details: error.message });
  }
});

// Delete Order
router.delete('/:id', async (req, res) => {
  const orderId = req.params.id;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Delete order items first (cascade deletion is enabled)
    await client.query(`DELETE FROM kot_order_items WHERE kot_order_id = $1`, [orderId]);

    // Now delete the order itself
    const result = await client.query(`DELETE FROM kot_orders WHERE id = $1 RETURNING id`, [orderId]);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    await client.query('COMMIT');
    res.status(200).json({ message: 'Order deleted successfully' });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Failed to delete order', details: error.message });
  } finally {
    client.release();
  }
});

// Get Order
router.get('/:id', async (req, res) => {
  const orderId = req.params.id;

  try {
    const orderResult = await pool.query(
      `SELECT * FROM kot_orders WHERE id = $1`,
      [orderId]
    );

    if (orderResult.rowCount === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }

    const orderItemsResult = await pool.query(
      `SELECT * FROM kot_order_items WHERE kot_order_id = $1`,
      [orderId]
    );

    res.status(200).json({
      order: orderResult.rows[0],
      items: orderItemsResult.rows,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch order', details: error.message });
  }
});

module.exports = router;
