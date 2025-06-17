const express = require('express');
const pool = require('../db'); // Replace with your database connection file

const router = express.Router();

// READ - Get required fields for all items
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT item_id, item_name, category, price, tax_rate, tag, discountable FROM items`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching items:', err.message);
    res.status(500).json({ error: err.message });
  }
});


// CREATE - Insert a new item
router.post('/', async (req, res) => {
  try {
    const {
      item_code,
      item_name,
      category,
      brand,
      subcategory_id,
      outlet,
      description,
      price,
      tax_rate,
      discount_percentage,
      stock_quantity,
      reorder_level,
      is_active,
      on_sale,
      happy_hour,
      discountable,
      property_id,
      tag
    } = req.body;

    const result = await pool.query(
      `INSERT INTO items 
       (item_code, item_name, category, brand, subcategory_id, outlet, description, price, tax_rate, discount_percentage, 
        stock_quantity, reorder_level, is_active, on_sale, happy_hour, discountable, property_id, tag) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) 
       RETURNING *`,
      [
        item_code,
        item_name,
        category,
        brand,
        subcategory_id,
        outlet,
        description,
        price,
        tax_rate,
        discount_percentage,
        stock_quantity,
        reorder_level,
        is_active,
        on_sale,
        happy_hour,
        discountable,
        property_id,
        tag
      ]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating item:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get all items
router.get('/allitems/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM items');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching items:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - Get an item by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM items WHERE item_id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Item not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error fetching item with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE - Edit an item by ID
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      item_code,
      item_name,
      category,
      brand,
      subcategory_id,
      outlet,
      description,
      price,
      tax_rate,
      discount_percentage,
      stock_quantity,
      reorder_level,
      is_active,
      on_sale,
      happy_hour,
      discountable,
      property_id
    } = req.body;

    const result = await pool.query(
      `UPDATE items 
       SET item_code = $1, item_name = $2, category = $3, brand = $4, subcategory_id = $5, outlet = $6, 
           description = $7, price = $8, tax_rate = $9, discount_percentage = $10, stock_quantity = $11, reorder_level = $12, 
           is_active = $13, on_sale = $14, happy_hour = $15, discountable = $16, property_id = $17, updated_at = NOW() 
       WHERE item_id = $18 
       RETURNING *`,
      [
        item_code,
        item_name,
        category,
        brand,
        subcategory_id,
        outlet,
        description,
        price,
        tax_rate,
        discount_percentage,
        stock_quantity,
        reorder_level,
        is_active,
        on_sale,
        happy_hour,
        discountable,
        property_id,
        id
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Item not found' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error(`Error updating item with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

// DELETE - Remove an item by ID
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM items WHERE item_id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Item not found' });
    }
    res.status(204).end();
  } catch (err) {
    console.error(`Error deleting item with ID ${id}:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
