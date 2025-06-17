const express = require('express');
const pool = require('../db'); // Database connection
const router = express.Router();

// CREATE Property
router.post('/', async (req, res) => {
  try {
    const {
      property_id,
      property_name,
      address,
      contact_number,
      email,
      business_hours,
      tax_reg_no,
      state,
      district,
      country,
      currency, is_saved
    } = req.body;

    const result = await pool.query(
      `INSERT INTO properties 
       (property_id, property_name, address, contact_number, email, business_hours, 
        tax_reg_no, state, district, country, currency, is_saved) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) 
       RETURNING *`,
      [
        property_id,
        property_name,
        address,
        contact_number,
        email,
        business_hours,
        tax_reg_no,
        state,
        district,
        country,
        currency,
        is_saved
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating property:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET All Properties
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM properties ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching properties:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET Property by ID
router.get('/:property_id', async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await pool.query('SELECT * FROM properties WHERE property_id = $1', [
      property_id,
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Property not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching property by ID:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE Property
router.put('/:property_id', async (req, res) => {
  try {
    const { property_id } = req.params;
    const {
      property_name,
      address,
      contact_number,
      email,
      business_hours,
      tax_reg_no,
      state,
      district,
      country,
      currency,
    } = req.body;

    const result = await pool.query(
      `UPDATE properties 
       SET property_name = $1, address = $2, contact_number = $3, email = $4, 
           business_hours = $5, tax_reg_no = $6, state = $7, district = $8, 
           country = $9, currency = $10, updated_at = NOW() 
       WHERE property_id = $11 
       RETURNING *`,
      [
        property_name,
        address,
        contact_number,
        email,
        business_hours,
        tax_reg_no,
        state,
        district,
        country,
        currency,
        property_id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Property not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error updating property:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// DELETE Property
router.delete('/:property_id', async (req, res) => {
  try {
    const { property_id } = req.params;

    const result = await pool.query('DELETE FROM properties WHERE property_id = $1 RETURNING *', [
      property_id,
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Property not found' });
    }

    res.status(204).send();
  } catch (err) {
    console.error('Error deleting property:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
