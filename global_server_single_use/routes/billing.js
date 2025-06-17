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


router.get('/', async (req, res) => {
  try {
    const { status, billno } = req.query;

    if (!status && !billno) {
      return res.status(400).json({ error: 'Either status or billno must be provided' });
    }

    let query = '';
    let params = [];

    if (billno) {
      query = `
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
          table_no,
          guestName, 
          guestId,
          discount_percentage,
          service_charge_percentage,
          service_charge_value,
          packing_charge,
          delivery_charge,
          other_charge,
          delivery_charge_percentage,
          packing_charge_percentage, 
          pax
        FROM bills 
        WHERE bill_number = $1
      `;
      params = [billno];
    } else if (status) {
      query = `
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
          table_no,
          guestName, 
          guestId,
          discount_percentage,
          service_charge_percentage,
          service_charge_value,
          packing_charge,
          delivery_charge,
          other_charge,
          delivery_charge_percentage,
          packing_charge_percentage, 
          pax
        FROM bills 
        WHERE status = $1
      `;
      params = [status];
    }

    const result = await pool.query(query, params);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'No bills found for the provided criteria' });
    }

    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error retrieving bills:', error.message);
    res.status(500).json({ error: 'Failed to retrieve bills', details: error.message });
  }
});

router.get("/dashboard/today-stats", async (req, res) => {
  try {
    // Get today's date (YYYY-MM-DD)
    const today = new Date().toISOString().split("T")[0];

    // 1. Get today's reservations count
    const reservationQuery = `
          SELECT COUNT(*) AS today_reservations 
          FROM reservation 
          WHERE reservation_date = $1`;
    const reservationResult = await pool.query(reservationQuery, [today]);

    // 2. Get today's total sales
    const salesQuery = `
          SELECT COALESCE(SUM(total), 0) AS today_sales 
          FROM orders 
          WHERE DATE(created_at) = $1`;
    const salesResult = await pool.query(salesQuery, [today]);

    // 3. Get running orders count
    const runningOrdersQuery = `
          SELECT COUNT(*) AS running_orders 
          FROM orders 
          WHERE status = 'Pending' AND DATE(created_at) = $1`;
    const runningOrdersResult = await pool.query(runningOrdersQuery, [today]);

    // 4. Get pending payments count
    const pendingPaymentsQuery = `
            SELECT COALESCE(SUM(grand_total), 0) AS pending_payments 
           FROM bills 
          WHERE status = 'UnPaid' AND DATE(created_at) = $1`;
    const pendingPaymentsResult = await pool.query(pendingPaymentsQuery, [today]);

    // 5. Get total packing orders count
    const packingOrdersQuery = `
          SELECT COUNT(*) AS total_packing 
          FROM orders 
          WHERE packing_case = TRUE AND DATE(created_at) = $1`;
    const packingOrdersResult = await pool.query(packingOrdersQuery, [today]);

    // 6. Get today's total collection (final payments received)
    const collectionQuery = `
          SELECT COALESCE(SUM(grand_total), 0) AS today_collection 
          FROM bills 
          WHERE status = 'Paid' AND DATE(created_at) = $1`;
    const collectionResult = await pool.query(collectionQuery, [today]);

    // Sending JSON response
    res.json({
      today_reservations: parseInt(reservationResult.rows[0].today_reservations),
      today_sales: parseFloat(salesResult.rows[0].today_sales),
      running_orders: parseInt(runningOrdersResult.rows[0].running_orders),
      pending_payments: parseInt(pendingPaymentsResult.rows[0].pending_payments),
      total_packing: parseInt(packingOrdersResult.rows[0].total_packing),
      today_collection: parseFloat(collectionResult.rows[0].today_collection),
    });

  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});



router.get('/next-bill-number/:outletId', async (req, res) => {
  try {
    const { outletId } = req.params;
    console.log(`[LOG] Request received for outletId: ${outletId}`);

    // Get latest bill configuration
    const billConfigResult = await pool.query(
      `SELECT bill_prefix, bill_suffix, starting_bill_number, created_at 
       FROM bill_config 
       WHERE selected_outlet = $1 
       ORDER BY created_at DESC 
       LIMIT 1`,
      [outletId]
    );

    console.log(`[LOG] Bill configuration fetched:`, billConfigResult.rows);

    if (billConfigResult.rows.length === 0) {
      console.log(`[ERROR] No bill configuration found for outlet: ${outletId}`);
      return res.status(404).json({ error: 'No bill configuration found for this outlet' });
    }

    let { bill_prefix, bill_suffix, starting_bill_number, created_at } = billConfigResult.rows[0];

    console.log(`[LOG] Extracted bill config: prefix=${bill_prefix}, suffix=${bill_suffix}, starting_number=${starting_bill_number}, created_at=${created_at}`);

    // Convert created_at to a valid ISO Date string (if needed)
    if (typeof created_at === 'string') {
      created_at = new Date(created_at).toISOString().split('T')[0]; // Convert to YYYY-MM-DD
    } else {
      created_at = created_at.toISOString().split('T')[0]; // Convert to YYYY-MM-DD
    }

    console.log(`[LOG] Converted created_at: ${created_at}`);

    // Fetch the latest generated bill number with properly formatted date matching
    const maxBillResult = await pool.query(
      `SELECT bill_number 
       FROM bills 
       WHERE bill_generated_at::DATE >= $1::DATE
         AND outlet_name = $2
       ORDER BY bill_generated_at DESC 
       LIMIT 1`,
      [created_at, outletId]
    );

    console.log(`[LOG] Latest bill fetched:`, maxBillResult.rows);

    let nextBillNumber;

    if (maxBillResult.rows.length === 0 || !maxBillResult.rows[0].bill_number) {
      console.log(`[LOG] No previous bill found. Using starting bill number: ${starting_bill_number}`);
      nextBillNumber = starting_bill_number;
    } else {
      const lastBillNumber = maxBillResult.rows[0].bill_number;
      console.log(`[LOG] Last bill number retrieved: ${lastBillNumber}`);

      const numericPart = lastBillNumber.match(/\d+/g)?.[0]; // Extract first numeric sequence
      console.log(`[LOG] Extracted numeric part: ${numericPart}`);

      const lastNumeric = parseInt(numericPart, 10);
      console.log(`[LOG] Parsed last numeric bill number: ${lastNumeric}`);

      nextBillNumber = isNaN(lastNumeric) ? starting_bill_number : lastNumeric + 1;
      console.log(`[LOG] Next bill number determined: ${nextBillNumber}`);
    }

    // Format the new bill number
    const formattedBillNumber = `${bill_prefix}${nextBillNumber}${bill_suffix}`;
    console.log(`[LOG] Final formatted bill number: ${formattedBillNumber}`);

    res.json({
      nextBillNumber: formattedBillNumber,
      lastGeneratedBillNumber: maxBillResult.rows.length ? maxBillResult.rows[0].bill_number : null,
      bill_prefix,
      bill_suffix
    });

  } catch (err) {
    console.error('[ERROR] Fetching next bill number failed:', err.message);
    res.status(500).json({ error: err.message });
  }
});


router.post('/', async (req, res) => {
  const {
    table_no, tax_value, discount_percentage, service_charge_percentage,
    packing_charge_percentage, delivery_charge_percentage, other_charge, totalamount, subtotal,
    property_id, outletname, billstatus, items, bill_number, pax, guestId, guestName, platform_fees_percentage, platform_fees_tax, platform_fees_tax_per, packing_charge_tax, delivery_charge_tax, service_charge_tax, packing_charge_tax_per, delivery_charge_tax_per, service_charge_tax_per
  } = req.body;

  try {
    // Fetch all pending orders for the table
    const ordersResult = await pool.query(
      `SELECT order_id FROM orders WHERE table_number = $1 AND status = 'Pending'`,
      [table_no]
    );

    if (ordersResult.rowCount === 0) {
      return res.status(404).json({ error: 'No pending orders found for the specified table' });
    }

    const orders = ordersResult.rows;

    // Calculate aggregated values for the bill
    let total_amount = subtotal;
    const totalAmount = totalamount.toFixed(2);
    const subTotal = subtotal.toFixed(2);
    const discount_value = (totalAmount * (discount_percentage / 100)).toFixed(2);
    const service_charge_value = (total_amount * (service_charge_percentage / 100)).toFixed(2);
    const packing_charge = (total_amount * (packing_charge_percentage / 100)).toFixed(2);
    const delivery_charge = (total_amount * (delivery_charge_percentage / 100)).toFixed(2);
    const platform_fees = (total_amount * (platform_fees_percentage / 100)).toFixed(2);


    const grand_total = (
      totalAmount -
      parseFloat(discount_value) +
      parseFloat(tax_value) +
      parseFloat(service_charge_value) +
      parseFloat(packing_charge) +
      parseFloat(delivery_charge) + parseFloat(platform_fees) +
      parseFloat(other_charge || 0) + parseFloat(platform_fees_tax || 0) + parseFloat(packing_charge_tax || 0) + parseFloat(delivery_charge_tax || 0) + parseFloat(service_charge_tax || 0)
    ).toFixed(2);

    // Insert the new bill into the `bills` table
    const billResult = await pool.query(
      `INSERT INTO bills (bill_number, total_amount, tax_value, discount_value, service_charge_value, 
                          packing_charge, delivery_charge, other_charge, grand_total, property_id, outlet_name, 
                          packing_charge_percentage, delivery_charge_percentage, discount_percentage, service_charge_percentage, 
                          status, table_no, bill_generated_at, pax, guestId, guestName, platform_fees , platform_fees_tax , platform_fees_tax_per , packing_charge_tax , delivery_charge_tax , service_charge_tax , packing_charge_tax_per , delivery_charge_tax_per , service_charge_tax_per, subtotal )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, CURRENT_TIMESTAMP, $18, $19, $20, $21,$22,$23,$24,$25,$26,$27,$28,$29, $30) 
       RETURNING id`,
      [
        bill_number, // Generate a unique bill number
        totalAmount,
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
        table_no, pax, guestId, guestName, platform_fees, platform_fees_tax, platform_fees_tax_per, packing_charge_tax, delivery_charge_tax, service_charge_tax, packing_charge_tax_per, delivery_charge_tax_per, service_charge_tax_per, subTotal
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
      const { order_id, item_name, total, dis_amt, tax, discountPercentage, subtotal, grandtotal } = item;
      let total_item_value = total + tax;
      await pool.query(
        `UPDATE order_items 
         SET total_item_value = $1, total_discount_value = $2, item_tax=$3, discount_percentage=$4, subtotal= $5, grandtotal=$6
         WHERE order_id = $7 AND item_name = $8`,
        [total_item_value, dis_amt, tax, discountPercentage, subtotal, grandtotal, order_id, item_name]
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



async function fetchSalesData() {
  const salesQuery = `
 WITH daily_sales AS (
  SELECT DATE_TRUNC('day', created_at) AS period, COALESCE(SUM(total), 0) AS sales
  FROM orders
  WHERE created_at >= NOW() - INTERVAL '2 years'
  GROUP BY period
),
weekly_sales AS (
  SELECT DATE_TRUNC('week', created_at) AS period, COALESCE(SUM(total), 0) AS sales
  FROM orders
  WHERE created_at >= NOW() - INTERVAL '2 years'
  GROUP BY period
),
monthly_sales AS (
  SELECT DATE_TRUNC('month', created_at) AS period, COALESCE(SUM(total), 0) AS sales
  FROM orders
  WHERE created_at >= NOW() - INTERVAL '2 years'
  GROUP BY period
),
yearly_sales AS (
  SELECT DATE_TRUNC('year', created_at) AS period, COALESCE(SUM(total), 0) AS sales
  FROM orders
  WHERE created_at >= NOW() - INTERVAL '2 years'
  GROUP BY period
)
SELECT 
  (SELECT sales FROM daily_sales WHERE period = CURRENT_DATE) AS today_sales,
  (SELECT sales FROM daily_sales WHERE period = CURRENT_DATE - INTERVAL '1 day') AS yesterday_sales,
  (SELECT sales FROM weekly_sales WHERE period = DATE_TRUNC('week', CURRENT_DATE)) AS this_week_sales,
  (SELECT sales FROM weekly_sales WHERE period = DATE_TRUNC('week', CURRENT_DATE - INTERVAL '1 week')) AS last_week_sales,
  (SELECT sales FROM monthly_sales WHERE period = DATE_TRUNC('month', CURRENT_DATE)) AS this_month_sales,
  (SELECT sales FROM monthly_sales WHERE period = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')) AS last_month_sales,
  (SELECT sales FROM yearly_sales WHERE period = DATE_TRUNC('year', CURRENT_DATE)) AS this_year_sales,
  (SELECT sales FROM yearly_sales WHERE period = DATE_TRUNC('year', CURRENT_DATE - INTERVAL '1 year')) AS last_year_sales;
  `;

  const result = await pool.query(salesQuery);
  const sales = result.rows[0];

  return {
    today_sales: sales.today_sales || 0,
    yesterday_sales: sales.yesterday_sales || 0,
    today_growth: sales.yesterday_sales > 0
      ? (((sales.today_sales - sales.yesterday_sales) / sales.yesterday_sales) * 100).toFixed(2) + '%'
      : '100%',

    this_week_sales: sales.this_week_sales || 0,
    last_week_sales: sales.last_week_sales || 0,
    weekly_growth: sales.last_week_sales > 0
      ? (((sales.this_week_sales - sales.last_week_sales) / sales.last_week_sales) * 100).toFixed(2) + '%'
      : '100%',

    this_month_sales: sales.this_month_sales || 0,
    last_month_sales: sales.last_month_sales || 0,
    monthly_growth: sales.last_month_sales > 0
      ? (((sales.this_month_sales - sales.last_month_sales) / sales.last_month_sales) * 100).toFixed(2) + '%'
      : '100%',

    this_year_sales: sales.this_year_sales || 0,
    last_year_sales: sales.last_year_sales || 0,
    yearly_growth: sales.last_year_sales > 0
      ? (((sales.this_year_sales - sales.last_year_sales) / sales.last_year_sales) * 100).toFixed(2) + '%'
      : '100%',

    yoy_growth: sales.last_year_sales > 0
      ? (((sales.this_year_sales - sales.last_year_sales) / sales.last_year_sales) * 100).toFixed(2) + '%'
      : '100%',
  };
}


async function fetchTopCategories() {
  const categoryQuery = `
    SELECT 
      item_category, 
      COALESCE(SUM(total_item_value), 0) AS total_sales
    FROM order_items
    WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY item_category
    ORDER BY total_sales DESC
    LIMIT 5;
  `;

  const result = await pool.query(categoryQuery);
  return result.rows;
}

/**
 * GET Dashboard Summary (Sales + Top Categories)
 */
router.get('/dashboard/summary', async (req, res) => {
  try {
    const [salesData, topCategories] = await Promise.all([
      fetchSalesData(),
      fetchTopCategories()
    ]);

    res.json({
      sales: salesData,
      top_categories: topCategories
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching dashboard summary');
  }
});


// 🟢 1️⃣ Daily Sales Summary
router.get('/reports/daily-sales', async (req, res) => {
  try {
    const query = `
      SELECT 
          (SELECT COUNT(order_id) FROM orders WHERE DATE(created_at) = CURRENT_DATE) AS total_orders,
          COALESCE(SUM(b.total_amount), 0) AS total_sales,
          COALESCE(SUM(b.discount_value), 0) AS total_discounts,
          COALESCE(SUM(b.tax_value), 0) AS total_taxes,
          COALESCE(SUM(b.service_charge_value), 0) AS total_service_charges,
          COALESCE(SUM(b.packing_charge), 0) AS total_packing_charges,
          COALESCE(SUM(b.delivery_charge), 0) AS total_delivery_charges,
          COALESCE(SUM(b.other_charge), 0) AS total_other_charges,
          COALESCE(SUM(b.grand_total), 0) AS total_revenue
      FROM bills b
      WHERE DATE(b.bill_generated_at) = CURRENT_DATE;
    `;
    const { rows } = await pool.query(query);
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 🟢 2️⃣ Hourly Sales Report
router.get('/reports/hourly-sales', async (req, res) => {
  try {
    const query = `
     SELECT 
    TO_CHAR(DATE_TRUNC('hour', created_at), 'HH12 AM') || 
    ' - ' || 
    TO_CHAR(DATE_TRUNC('hour', created_at) + INTERVAL '1 hour', 'HH12 AM') AS hour_range,
    COUNT(order_id) AS total_orders,
    COALESCE(SUM(total), 0) AS total_sales
FROM orders
WHERE DATE(created_at) = CURRENT_DATE
GROUP BY hour_range
ORDER BY MIN(created_at);
    `;
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 🟢 3️⃣ Item-Wise Sales Report
router.get('/reports/item-wise-sales', async (req, res) => {
  try {
    const query = `
      SELECT 
          item_name,
          SUM(item_quantity) AS total_sold,
          SUM(total_item_value) AS total_revenue
      FROM order_items
      GROUP BY item_name
      ORDER BY total_sold DESC;
    `;
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 🟢 4️⃣ Category-Wise Sales Report
router.get('/reports/category-wise-sales', async (req, res) => {
  try {
    const query = `
      SELECT 
          item_category,
          SUM(item_quantity) AS total_sold,
          SUM(total_item_value) AS total_revenue
      FROM order_items
      GROUP BY item_category
      ORDER BY total_revenue DESC;
    `;
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 🟢 5️⃣ Payment Method Breakdown
router.get('/reports/payment-breakdown', async (req, res) => {
  try {
    const query = `
      SELECT 
          payment_method,
          COUNT(id) AS total_transactions,
          SUM(payment_amount) AS total_collected
      FROM payments
      WHERE DATE(payment_date) = CURRENT_DATE
      GROUP BY payment_method;
    `;
    const { rows } = await pool.query(query);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


router.get('/bills/print/:billno', async (req, res) => {
  try {
    const { billno } = req.params;

    // Get bill and order details
    const query = `
      SELECT 
        b.bill_number,
        b.table_no,
        b.pax,
        b.bill_generated_at,
        b.guestname,
        b.total_amount,
        b.discount_percentage,
        b.discount_value,
        b.tax_value,
        b.service_charge_percentage,
        b.service_charge_value,
        b.grand_total,
        json_agg(
          json_build_object(
            'item_name', oi.item_name,
            'quantity', oi.item_quantity,
            'price', oi.total_item_value,
            'tax', oi.item_tax
          )
        ) AS items
      FROM bills b
      LEFT JOIN orders o ON b.id = o.bill_id
      LEFT JOIN order_items oi ON o.order_id = oi.order_id
      WHERE b.bill_number = $1
      GROUP BY b.id
    `;

    const result = await pool.query(query, [billno]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Bill not found' });
    }

    const bill = result.rows[0];
    const formattedDate = new Date(bill.bill_generated_at).toLocaleDateString('en-GB');
    const formattedTime = new Date(bill.bill_generated_at).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });

    const formattedResponse = {
      business: {
        name: "My Business Name",
        address: "123 Business Street, City, Country",
        phone: "+123456789",
        email: "contact@business.com"
      },
      bill_header: {
        table: bill.table_no,
        pax: bill.pax,
        bill_number: bill.bill_number,
        date: formattedDate,
        time: formattedTime,
        guest_name: bill.guestname
      },
      items: bill.items.map(item => ({
        name: item.item_name,
        quantity: item.quantity,
        price: item.price,
        tax: item.tax
      })),
      totals: {
        total_amount: parseFloat(bill.total_amount),
        discount: {
          percent: bill.discount_percentage,
          value: parseFloat(bill.discount_value)
        },
        subtotal: parseFloat(bill.total_amount - bill.discount_value),
        tax: parseFloat(bill.tax_value),
        service_charge: {
          percent: bill.service_charge_percentage,
          value: parseFloat(bill.service_charge_value)
        },
        net_payable: parseFloat(bill.grand_total)
      },
      footer: "Thank you for your purchase! Visit Again!"
    };

    res.json(formattedResponse);
  } catch (err) {
    console.error('[ERROR] Fetching bill for print:', err.message);
    res.status(500).json({ error: 'Failed to fetch bill', details: err.message });
  }
});




module.exports = router;
