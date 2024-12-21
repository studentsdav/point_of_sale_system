// const express = require('express');
// const pool = require('../db'); // Replace with your database connection file

// const router = express.Router();

// // Update and Finalize Order with Bill and Item Details
// router.put('/:id/generate-bill', async (req, res) => {
//   const orderId = req.params.id;
//   const {
//     guest_id,
//     payment_status,
//     tax_value,
//     discount_percentage,
//     discount_value,
//     service_charge_percentage,
//     service_charge_value,
//     total_happy_hour_discount,
//     cashier,
//     status,
//     staff_id,
//     created_by,
//     bill_generated,
//     bill_generated_at,
//     bill_payment_status,
//     bill_number,
//     packing_charge,
//     packing_charge_percentage,
//     delivery_charge,
//     delivery_charge_percentage,
//     itemDiscounts, // Array of { item_id, discount_percentage, discount_value }
//     table_no, // Table number to identify the active order
//   } = req.body;

//   if (!itemDiscounts || !Array.isArray(itemDiscounts)) {
//     return res.status(400).json({ error: 'Invalid itemDiscounts format. It must be an array.' });
//   }

//   try {
//     // Identify the running order based on table_no and status
//     const runningOrder = await pool.query(
//       `SELECT id FROM orders WHERE table_no = $1 AND status = 'pending' LIMIT 1`,
//       [table_no]
//     );

//     if (runningOrder.rowCount === 0) {
//       return res.status(404).json({ error: 'No running order found for the given table' });
//     }

//     const runningOrderId = runningOrder.rows[0].id;

//     // Update the order details
//     const orderResult = await pool.query(
//       `UPDATE orders SET
//         guest_id = $1,
//         payment_status = $2,
//         tax_value = $3,
//         discount_percentage = $4,
//         discount_value = $5,
//         service_charge_percentage = $6,
//         service_charge_value = $7,
//         total_happy_hour_discount = $8,
//         cashier = $9,
//         status = 'billed',  // Update status to 'billed'
//         staff_id = $10,
//         created_by = $11,
//         bill_generated = $12,
//         bill_generated_at = $13,
//         bill_payment_status = $14,
//         bill_number = $15,
//         packing_charge = $16,
//         packing_charge_percentage = $17,
//         delivery_charge = $18,
//         delivery_charge_percentage = $19,
//         updated_at = CURRENT_TIMESTAMP
//       WHERE id = $20 RETURNING id`,
//       [
//         guest_id,
//         payment_status,
//         tax_value,
//         discount_percentage,
//         discount_value,
//         service_charge_percentage,
//         service_charge_value,
//         total_happy_hour_discount,
//         cashier,
//         status,  // 'billed'
//         staff_id,
//         created_by,
//         bill_generated,
//         bill_generated_at,
//         bill_payment_status,
//         bill_number,
//         packing_charge,
//         packing_charge_percentage,
//         delivery_charge,
//         delivery_charge_percentage,
//         runningOrderId, // Use the identified running order id
//       ]
//     );

//     if (orderResult.rowCount === 0) {
//       return res.status(404).json({ error: 'Failed to update order details' });
//     }

//     // Update the discount details and bill number for all items in the order
//     for (const item of itemDiscounts) {
//       const { item_id, discount_percentage, discount_value } = item;

//       // Update order_items using item_id and order_id
//       await pool.query(
//         `UPDATE order_items SET
//           discount_percentage = $1,
//           discount_value = $2,
//           bill_number = $3,
//           packing_charge = $4,
//           packing_charge_percentage = $5,
//           delivery_charge = $6,
//           delivery_charge_percentage = $7,
//           updated_at = CURRENT_TIMESTAMP
//         WHERE item_id = $8 AND order_id = $9`, // Use item_id and order_id
//         [
//           discount_percentage,
//           discount_value,
//           bill_number,
//           packing_charge,
//           packing_charge_percentage,
//           delivery_charge,
//           delivery_charge_percentage,
//           item_id,   // Item ID
//           runningOrderId, // Order ID
//         ]
//       );
//     }

//     res.status(200).json({
//       message: 'Order and item details updated with bill successfully',
//       orderId: orderResult.rows[0].id,
//     });
//   } catch (error) {
//     res.status(500).json({ error: 'Failed to update order and items with bill details', details: error.message });
//   }
// });

// module.exports = router;


const express = require('express');
const pool = require('../db'); // Database connection

const router = express.Router();


router.get('/:status', async (req, res) => {
  try {
    // Get the 'status' parameter from the URL (not query string)
    const { status } = req.params;

    // Check if the status is provided
    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }

    // Construct the base query
    const query = `
      SELECT 
        id,
        bill_number, 
        total_amount, 
        tax_value, 
        discount_value, 
        grand_total, 
        outlet_name, 
        status, 
        bill_generated_at, 
        table_no
      FROM bills 
      WHERE status = $1
    `;

    // Execute the query with the provided status
    const result = await pool.query(query, [status]);

    // Check if no bills are found
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No bills found for the specified status' });
    }

    // Return the results
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error retrieving bills:', error.message);
    res.status(500).json({ error: 'Failed to retrieve bills', details: error.message });
  }
});

router.post('/', async (req, res) => {
  const {
    table_no, tax_value, discount_percentage, service_charge_percentage,
    packing_charge_percentage, delivery_charge_percentage, other_charge,
    property_id, outletname, billstatus, items
  } = req.body;

  try {
    // Fetch all pending orders for the table
    const ordersResult = await pool.query(
      `SELECT order_id, total_amount FROM orders WHERE table_number = $1 AND status = 'Pending'`,
      [table_no]
    );

    if (ordersResult.rowCount === 0) {
      return res.status(404).json({ error: 'No pending orders found for the specified table' });
    }

    const orders = ordersResult.rows;

    // Calculate aggregated values for the bill
    let total_amount = 0;
    orders.forEach(order => total_amount += parseFloat(order.total_amount));

    const discount_value = (total_amount * (discount_percentage / 100)).toFixed(2);
    const service_charge_value = (total_amount * (service_charge_percentage / 100)).toFixed(2);
    const packing_charge = (total_amount * (packing_charge_percentage / 100)).toFixed(2);
    const delivery_charge = (total_amount * (delivery_charge_percentage / 100)).toFixed(2);
    const grand_total = (
      total_amount -
      parseFloat(discount_value) +
      parseFloat(tax_value) +
      parseFloat(service_charge_value) +
      parseFloat(packing_charge) +
      parseFloat(delivery_charge) +
      parseFloat(other_charge || 0)
    ).toFixed(2);

    // Insert the new bill into the `bills` table
    const billResult = await pool.query(
      `INSERT INTO bills (bill_number, total_amount, tax_value, discount_value, service_charge_value, 
                          packing_charge, delivery_charge, other_charge, grand_total, property_id, outlet_name, 
                          packing_charge_percentage, delivery_charge_percentage, discount_percentage, service_charge_percentage, 
                          status, table_no, bill_generated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, CURRENT_TIMESTAMP) 
       RETURNING id`,
      [
        `BILL-${Date.now()}`, // Generate a unique bill number
        total_amount,
        tax_value,
        discount_value,
        service_charge_value,
        packing_charge,
        delivery_charge,
        other_charge,
        grand_total,
        property_id,
        outletname,
        packing_charge_percentage,
        delivery_charge_percentage,
        discount_percentage,
        service_charge_percentage,
        billstatus,
        table_no
      ]
    );

    const billId = billResult.rows[0].id;

    // Update the `orders` table to link the bill with the orders
    const orderIds = orders.map(order => order.order_id);
    await pool.query(
      `UPDATE orders SET bill_id = $1, status = 'billed' WHERE order_id = ANY($2::int[])`,
      [billId, orderIds]
    );

    await pool.query(
      `UPDATE table_configurations SET status = 'Dirty' WHERE table_no = $1 AND status = 'Occupied'`,
      [table_no]
    );

    await pool.query(
      `UPDATE bills SET status = 'UnPaid' WHERE id = $1`,
      [billId]
    );

    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration updated'");

    // **Update order_items table** for the given items
    for (const item of items) {
      const { order_id, item_name, total, dis_amt, tax, discountPercentage } = item;

      await pool.query(
        `UPDATE order_items 
         SET total_item_value = $1, total_discount_value = $2, item_tax=$3, discount_percentage=$4
         WHERE order_id = $5 AND item_name = $6`,
        [total, dis_amt, tax, discountPercentage, order_id, item_name]
      );
    }

    res.status(201).json({
      message: 'Bill generated successfully and order items updated',
      billId,
      grand_total,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to generate bill', details: error.message });
  }
});


module.exports = router;
