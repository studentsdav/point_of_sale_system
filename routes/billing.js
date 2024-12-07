const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// Update and Finalize Order with Bill and Item Details
router.put('/:id/generate-bill', async (req, res) => {
  const orderId = req.params.id;
  const {
    guest_id,
    payment_status,
    tax_value,
    discount_percentage,
    discount_value,
    service_charge_percentage,
    service_charge_value,
    total_happy_hour_discount,
    cashier,
    status,
    staff_id,
    created_by,
    bill_generated,
    bill_generated_at,
    bill_payment_status,
    bill_number,
    packing_charge,
    packing_charge_percentage,
    delivery_charge,
    delivery_charge_percentage,
    itemDiscounts, // Array of { item_id, discount_percentage, discount_value }
    table_no, // Table number to identify the active order
  } = req.body;

  if (!itemDiscounts || !Array.isArray(itemDiscounts)) {
    return res.status(400).json({ error: 'Invalid itemDiscounts format. It must be an array.' });
  }

  try {
    // Identify the running order based on table_no and status
    const runningOrder = await pool.query(
      `SELECT id FROM orders WHERE table_no = $1 AND status = 'pending' LIMIT 1`,
      [table_no]
    );

    if (runningOrder.rowCount === 0) {
      return res.status(404).json({ error: 'No running order found for the given table' });
    }

    const runningOrderId = runningOrder.rows[0].id;

    // Update the order details
    const orderResult = await pool.query(
      `UPDATE orders SET
        guest_id = $1,
        payment_status = $2,
        tax_value = $3,
        discount_percentage = $4,
        discount_value = $5,
        service_charge_percentage = $6,
        service_charge_value = $7,
        total_happy_hour_discount = $8,
        cashier = $9,
        status = 'billed',  // Update status to 'billed'
        staff_id = $10,
        created_by = $11,
        bill_generated = $12,
        bill_generated_at = $13,
        bill_payment_status = $14,
        bill_number = $15,
        packing_charge = $16,
        packing_charge_percentage = $17,
        delivery_charge = $18,
        delivery_charge_percentage = $19,
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $20 RETURNING id`,
      [
        guest_id,
        payment_status,
        tax_value,
        discount_percentage,
        discount_value,
        service_charge_percentage,
        service_charge_value,
        total_happy_hour_discount,
        cashier,
        status,  // 'billed'
        staff_id,
        created_by,
        bill_generated,
        bill_generated_at,
        bill_payment_status,
        bill_number,
        packing_charge,
        packing_charge_percentage,
        delivery_charge,
        delivery_charge_percentage,
        runningOrderId, // Use the identified running order id
      ]
    );

    if (orderResult.rowCount === 0) {
      return res.status(404).json({ error: 'Failed to update order details' });
    }

    // Update the discount details and bill number for all items in the order
    for (const item of itemDiscounts) {
      const { item_id, discount_percentage, discount_value } = item;

      // Update order_items using item_id and order_id
      await pool.query(
        `UPDATE order_items SET
          discount_percentage = $1,
          discount_value = $2,
          bill_number = $3,
          packing_charge = $4,
          packing_charge_percentage = $5,
          delivery_charge = $6,
          delivery_charge_percentage = $7,
          updated_at = CURRENT_TIMESTAMP
        WHERE item_id = $8 AND order_id = $9`, // Use item_id and order_id
        [
          discount_percentage,
          discount_value,
          bill_number,
          packing_charge,
          packing_charge_percentage,
          delivery_charge,
          delivery_charge_percentage,
          item_id,   // Item ID
          runningOrderId, // Order ID
        ]
      );
    }

    res.status(200).json({
      message: 'Order and item details updated with bill successfully',
      orderId: orderResult.rows[0].id,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update order and items with bill details', details: error.message });
  }
});

module.exports = router;
