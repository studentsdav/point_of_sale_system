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
    customer_name,
    customer_contact,
    payment_method,
    payment_status,
    payment_date,
    transaction_id,
    tax_percentage,
    tax_value,
    total_amount,
    discount_percentage,
    total_discount_value,
    service_charge_per,
    total_service_charge,
    total_happy_hour_discount,
    subtotal,
    total,
    cashier,
    status,
    order_type,
    order_notes,
    is_priority_order,
    customer_feedback,
    staff_id,
    order_cancelled_by,
    cancellation_reason,
    created_by,
    updated_by,
    delivery_address,
    delivery_time,
    order_received_time,
    order_ready_time,
    served_by,
    payment_method_details,
    dining_case,
    packing_case,
    complimentary_case,
    cancelled_case,
    modified_case,
    bill_generated,
    bill_generated_at,
    bill_payment_status,
    partial_payment,
    final_payment,
    order_type_change,
    modified_by,
    modify_reason,
    refund_status,
    refund_amount,
    refund_date,
    refund_processed_by,
    refund_reason,
    outlet_name,
    items // Added items array from request
  } = req.body;

  // Filter only required parameters (60 values)
  const orderParams = [
    order_number,
    table_number,
    waiter_name,
    person_count,
    remarks,
    property_id,
    guest_id,
    customer_name,
    customer_contact,
    payment_method,
    payment_status,
    payment_date,
    transaction_id,
    tax_percentage,
    tax_value,
    total_amount,
    discount_percentage,
    total_discount_value,
    service_charge_per,
    total_service_charge,
    total_happy_hour_discount,
    subtotal,
    total,
    cashier,
    status,
    order_type,
    order_notes,
    is_priority_order,
    customer_feedback,
    staff_id,
    order_cancelled_by,
    cancellation_reason,
    created_by,
    updated_by,
    delivery_address,
    delivery_time,
    order_received_time,
    order_ready_time,
    served_by,
    payment_method_details,
    dining_case,
    packing_case,
    complimentary_case,
    cancelled_case,
    modified_case,
    bill_generated,
    bill_generated_at,
    bill_payment_status,
    partial_payment,
    final_payment,
    order_type_change,
    modified_by,
    modify_reason,
    refund_status,
    refund_amount,
    refund_date,
    refund_processed_by,
    refund_reason,
    outlet_name
  ];

  // Remove any unused parameters (for 60 values) from the query
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Insert into orders table with only 60 parameters
    const orderResult = await client.query(
      `INSERT INTO orders (
        order_number, table_number, waiter_name, person_count, remarks,
        property_id, guest_id, customer_name, customer_contact, payment_method,
        payment_status, payment_date, transaction_id, tax_percentage, tax_value,
        total_amount, discount_percentage, total_discount_value, service_charge_per,
        total_service_charge, total_happy_hour_discount, subtotal, total, cashier, status,
        order_type, order_notes, is_priority_order, customer_feedback, staff_id,
        order_cancelled_by, cancellation_reason, created_by, updated_by, delivery_address,
        delivery_time, order_received_time, order_ready_time, served_by, payment_method_details,
        dining_case, packing_case, complimentary_case, cancelled_case, modified_case,
        bill_generated, bill_generated_at, bill_payment_status, partial_payment, final_payment,
        order_type_change, modified_by, modify_reason, refund_status, refund_amount, refund_date,
        refund_processed_by, refund_reason, outlet_name
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
        $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $50, $51, $52, $53, $54, $55, $56, $57, $58,
        $59
      ) RETURNING order_id`,
      orderParams
    );

    const orderId = orderResult.rows[0].order_id;

    await pool.query(
      `UPDATE table_configurations SET status = 'Occupied' WHERE table_no = $1 AND status != 'Occupied'`,
      [table_number]
    );
    // Notify PostgreSQL trigger to send notification
    await pool.query("NOTIFY table_update, 'Table configuration updated'");

    // Insert items for the order if the items array exists
    if (items && Array.isArray(items)) {
      for (let item of items) {
        await client.query(
          `INSERT INTO order_items (
            order_id, item_name, item_category, item_quantity, item_rate, item_amount, item_tax, total_item_value, outlet_name, property_id, taxRate, discountable
          ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8,$9,$10,$11,$12
          )`,
          [
            orderId, item.item_name, item.item_category, item.item_quantity, item.item_rate, item.item_amount, item.item_tax, item.total_item_value, outlet_name, property_id, item.taxRate, item.discountable
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

router.get('/max-order-number/:outletId', async (req, res) => {
  try {
    const { outletId } = req.params;

    // Get the latest KOT configuration for the given outlet
    const kotConfigResult = await pool.query(
      `SELECT kot_starting_number, created_at 
       FROM kot_configs 
       WHERE selected_outlet = $1 
       ORDER BY created_at DESC 
       LIMIT 1`,
      [outletId]
    );

    if (kotConfigResult.rows.length === 0) {
      return res.status(404).json({ error: 'No KOT configuration found for this outlet' });
    }

    const { kot_starting_number, created_at } = kotConfigResult.rows[0];

    // Get the max numeric part from order_number
    const maxOrderResult = await pool.query(
      `SELECT MAX(CAST(REGEXP_REPLACE(order_number, '^.*-(\\d+)$', '\\1', 'g') AS INTEGER)) AS max_order_number
       FROM orders 
       WHERE created_at >= $1 AND outlet_name = $2`,
      [created_at, outletId]
    );

    let maxOrderNumber = maxOrderResult.rows[0].max_order_number;

    // Determine the next order number
    const nextOrderNumber = maxOrderNumber ? maxOrderNumber + 1 : kot_starting_number;

    res.json({ nextOrderNumber, kot_starting_number, maxOrderNumber });
  } catch (err) {
    console.error('Error fetching max order number:', err.message);
    res.status(500).json({ error: err.message });
  }
});




// Update Order
router.put('/:orderId', async (req, res) => {
  const { orderId } = req.params;
  const {
    property_id,
    tax_percentage,
    tax_value,
    total_amount,
    discount_percentage,
    total_discount_value,
    service_charge_per,
    total_service_charge,
    total_happy_hour_discount,
    subtotal,
    total,
    staff_id,
    order_cancelled_by,
    cancellation_reason,
    updated_by,
    modified_case,
    modified_by,
    modify_reason,
    outlet_name,
    items // Updated items array from request
  } = req.body;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Update the orders table with partial fields
    const updateOrderQuery = `
      UPDATE orders
      SET 
        property_id = $1,
        tax_percentage = $2,
        tax_value = $3,
        total_amount = $4,
        discount_percentage = $5,
        total_discount_value = $6,
        service_charge_per = $7,
        total_service_charge = $8,
        total_happy_hour_discount = $9,
        subtotal = $10,
        total = $11,
        staff_id = $12,
        order_cancelled_by = $13,
        cancellation_reason = $14,
        updated_by = $15,
        modified_case = $16,
        modified_by = $17,
        modify_reason = $18,
        outlet_name = $19
      WHERE order_id = $20
    `;

    const orderUpdateParams = [
      property_id,
      tax_percentage,
      tax_value,
      total_amount,
      discount_percentage,
      total_discount_value,
      service_charge_per,
      total_service_charge,
      total_happy_hour_discount,
      subtotal,
      total,
      staff_id,
      order_cancelled_by,
      cancellation_reason,
      updated_by,
      modified_case,
      modified_by,
      modify_reason,
      outlet_name,
      orderId
    ];

    await client.query(updateOrderQuery, orderUpdateParams);

    // Delete existing items for the order
    await client.query('DELETE FROM order_items WHERE order_id = $1', [orderId]);

    // Insert updated items for the order
    if (items && Array.isArray(items)) {
      for (let item of items) {
        await client.query(
          `INSERT INTO order_items (
            order_id, item_name, item_category, item_quantity, item_rate, item_amount, item_tax,
            total_item_value, outlet_name, property_id, taxRate, discountable
          ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
          )`,
          [
            orderId,
            item.item_name,
            item.item_category,
            item.item_quantity,
            item.item_rate,
            item.item_amount,
            item.item_tax,
            item.total_item_value,
            outlet_name,
            property_id,
            item.taxRate,
            item.discountable
          ]
        );
      }
    }

    await client.query('COMMIT');
    res.status(200).json({ message: 'Order updated successfully', orderId });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Failed to update order', details: error.message });
  } finally {
    client.release();
  }
});


// Specific route for order items
router.get('/orderitem', async (req, res) => {
  try {
    const { orderIds } = req.query; // Expecting a comma-separated list of orderIds
    const orderIdsArray = orderIds.split(','); // Convert to an array of orderIds

    const result = await pool.query(
      `SELECT item_id, order_id, item_name, item_quantity, item_rate, taxrate, discountable,
        (item_quantity * item_rate) AS subtotal, 
        ((item_quantity * item_rate) * taxrate / 100) AS tax, 
        ((item_quantity * item_rate) + ((item_quantity * item_rate) * taxrate / 100)) AS total 
      FROM order_items 
      WHERE order_id = ANY($1::int[])`, // Use ANY with an array of values
      [orderIdsArray] // Pass the array of orderIds
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No items found for the specified order IDs' });
    }

    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching items for order IDs:', err.message);
    res.status(500).json({ error: err.message });
  }
});


router.get('/table/:status', async (req, res) => {
  try {
    const { status } = req.params;

    const result = await pool.query(
      'SELECT order_id, order_number, table_number, status, created_at, order_type FROM orders WHERE status = $1',
      [status]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No orders found for the specified table and status' });
    }

    res.status(200).json(result.rows);
  } catch (err) {
    console.error(`Error fetching orders for table ${req.params.tableNo} with status ${req.params.status}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});


router.get('/bills/:billid', async (req, res) => {
  try {
    const { billid } = req.params;

    const result = await pool.query(
      'SELECT order_id, order_number, table_number, status, created_at, order_type FROM orders WHERE bill_id = $1',
      [billid]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No orders found for the specified bill id' });
    }

    res.status(200).json(result.rows);
  } catch (err) {
    console.error(`Error fetching orders for ${req.params.billid}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});


router.put('/tableshift/:oldtableno/:newtableno/:status', async (req, res) => {
  try {
    const { oldtableno, newtableno, status } = req.params;

    // Check if the new table exists and is not occupied
    const newTableCheck = await pool.query(
      `SELECT * FROM table_configurations WHERE table_no = $1 AND status != 'Occupied'`,
      [newtableno]
    );

    if (newTableCheck.rowCount === 0) {
      return res.status(404).json({ message: 'New table not found or already occupied' });
    }

    // Update the new table's status to "Occupied"
    await pool.query(
      `UPDATE table_configurations SET status = 'Occupied' WHERE table_no = $1 AND status != 'Occupied'`,
      [newtableno]
    );

    // Update the old table's status to "Dirty"
    const oldTableUpdate = await pool.query(
      `UPDATE table_configurations SET status = 'Dirty' WHERE table_no = $1 AND status = 'Occupied'`,
      [oldtableno]
    );

    if (oldTableUpdate.rowCount === 0) {
      return res.status(404).json({ message: 'Old table not found or not occupied' });
    }

    // Update the orders to shift to the new table
    const ordersUpdate = await pool.query(
      `UPDATE orders SET table_number = $1 WHERE table_number = $2 AND status = 'Pending'`,
      [newtableno, oldtableno]
    );

    if (ordersUpdate.rowCount === 0) {
      return res.status(404).json({ message: 'No pending orders found for the old table' });
    }

    res.status(200).json({ message: 'Table shift successful' });
  } catch (err) {
    console.error(`Error during table shift:`, err.message);
    res.status(500).json({ error: err.message });
  }
});



// General route for orders by table number and status
router.get('/:tableNo/:status', async (req, res) => {
  try {
    const { tableNo, status } = req.params;

    const result = await pool.query(
      'SELECT order_id, order_number, table_number, status, created_at, order_type FROM orders WHERE table_number = $1 AND status = $2',
      [tableNo, status]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No orders found for the specified table and status' });
    }

    res.status(200).json(result.rows);
  } catch (err) {
    console.error(`Error fetching orders for table ${req.params.tableNo} with status ${req.params.status}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});




// Delete Order
router.delete('/:id', async (req, res) => {
  const orderId = req.params.id;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Delete order items first (cascade deletion is enabled)
    await client.query(`DELETE FROM order_items WHERE order_id = $1`, [orderId]);

    // Now delete the order itself
    const result = await client.query(`DELETE FROM orders WHERE order_id = $1 RETURNING order_id`, [orderId]);

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

module.exports = router;
