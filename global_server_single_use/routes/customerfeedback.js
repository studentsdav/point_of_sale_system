const express = require('express');
const router = express.Router();
const pool = require('../db'); // PostgreSQL connection

// Add new feedback
router.post('/feedback', async (req, res) => {
    try {
        const { guest_id, rating, comments } = req.body;
        const result = await pool.query(
            'INSERT INTO customer_feedback (guest_id, rating, comments) VALUES ($1, $2, $3) RETURNING *',
            [guest_id, rating, comments]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while adding feedback' });
    }
});

// Get all feedback
router.get('/feedback', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM customer_feedback ORDER BY feedback_date DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching feedback' });
    }
});

// Get feedback by ID
router.get('/feedback/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT * FROM customer_feedback WHERE feedback_id = $1', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Feedback not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching feedback' });
    }
});

// Get feedback by guest ID
router.get('/feedback/guest/:guest_id', async (req, res) => {
    try {
        const { guest_id } = req.params;
        const result = await pool.query('SELECT * FROM customer_feedback WHERE guest_id = $1 ORDER BY feedback_date DESC', [guest_id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'No feedback found for this guest' });
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while fetching guest feedback' });
    }
});

// Update feedback by ID
router.put('/feedback/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { rating, comments } = req.body;
        const result = await pool.query(
            'UPDATE customer_feedback SET rating = $1, comments = $2, feedback_date = CURRENT_TIMESTAMP WHERE feedback_id = $3 RETURNING *',
            [rating, comments, id]
        );

        if (result.rows.length === 0) return res.status(404).json({ error: 'Feedback not found' });
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while updating feedback' });
    }
});

// Delete feedback by ID
router.delete('/feedback/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('DELETE FROM customer_feedback WHERE feedback_id = $1 RETURNING *', [id]);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Feedback not found' });
        res.json({ message: 'Feedback deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error while deleting feedback' });
    }
});

module.exports = router;
