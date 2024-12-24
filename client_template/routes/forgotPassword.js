const express = require('express');
const pool = require('../db');

const router = express.Router();

// Forgot password route
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    const result = await pool.query('SELECT * FROM user_login WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Email not found' });
    }

    res.json({ message: 'Password reset link sent to your email' });
  } catch (err) {
    console.error('Error sending reset password email:', err.message);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
