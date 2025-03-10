const express = require('express');
const pool = require('../db'); // PostgreSQL connection
const router = express.Router();

// Add Attendance Record
router.post('/', async (req, res) => {
    try {
        const { employee_id, work_date, shift_start, shift_end, status, biometric_entry, biometric_exit } = req.body;

        const result = await pool.query(
            `INSERT INTO attendance (employee_id, work_date, shift_start, shift_end, status, biometric_entry, biometric_exit)
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [employee_id, work_date, shift_start, shift_end, status, biometric_entry, biometric_exit]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error adding attendance:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Get All Attendance Records
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM attendance ORDER BY work_date DESC');
        res.status(200).json(result.rows);
    } catch (err) {
        console.error('Error fetching attendance records:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Update Attendance Record
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { shift_start, shift_end, status, biometric_entry, biometric_exit } = req.body;

        const result = await pool.query(
            `UPDATE attendance SET shift_start = $1, shift_end = $2, status = $3, biometric_entry = $4, biometric_exit = $5
             WHERE attendance_id = $6 RETURNING *`,
            [shift_start, shift_end, status, biometric_entry, biometric_exit, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Attendance record not found' });
        }

        res.status(200).json(result.rows[0]);
    } catch (err) {
        console.error('Error updating attendance:', err.message);
        res.status(500).json({ error: err.message });
    }
});

// Delete Attendance Record
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM attendance WHERE attendance_id = $1', [id]);
        res.status(200).json({ message: 'Attendance record deleted successfully' });
    } catch (err) {
        console.error('Error deleting attendance:', err.message);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
