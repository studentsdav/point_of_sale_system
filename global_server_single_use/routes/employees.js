const express = require('express');
const pool = require('../db'); // PostgreSQL connection
const router = express.Router();

// Create Employee
router.post('/', async (req, res) => {
    try {
        const { name, phone, email, country_code, position, base_salary, currency, hire_date } = req.body;

        const result = await pool.query(
            `INSERT INTO employees (name, phone, email, country_code, position, base_salary, currency, hire_date)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
            [name, phone, email, country_code, position, base_salary, currency, hire_date]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error adding employee:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get All Employees
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM employees ORDER BY created_at DESC');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching employees:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update Employee
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, phone, email, position, base_salary, currency } = req.body;

        const result = await pool.query(
            `UPDATE employees SET name = $1, phone = $2, email = $3, position = $4, base_salary = $5, currency = $6 
             WHERE employee_id = $7 RETURNING *`,
            [name, phone, email, position, base_salary, currency, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Employee not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error('Error updating employee:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete Employee
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM employees WHERE employee_id = $1', [id]);
        res.status(200).json({ message: 'Employee deleted successfully' });
    } catch (err) {
        console.error('Error deleting employee:', err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
