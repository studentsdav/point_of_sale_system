const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Create a new account
router.post("/", async (req, res) => {
    const { account_name, account_type, balance } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO accounts (account_name, account_type, balance) VALUES ($1, $2, $3) RETURNING *`,
            [account_name, account_type, balance || 0.00]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error creating account:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all accounts
router.get("/", async (req, res) => {
    try {
        const result = await db.query(`SELECT * FROM accounts ORDER BY account_name ASC`);
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching accounts:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get account by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(`SELECT * FROM accounts WHERE account_id = $1`, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Account not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching account:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update account details
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { account_name, account_type } = req.body;

    try {
        const result = await db.query(
            `UPDATE accounts SET account_name = $1, account_type = $2 WHERE account_id = $3 RETURNING *`,
            [account_name, account_type, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Account not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating account:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete an account
router.delete("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(`DELETE FROM accounts WHERE account_id = $1 RETURNING *`, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Account not found" });
        }
        res.json({ message: "Account deleted successfully" });
    } catch (error) {
        console.error("Error deleting account:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update account balance (Deposit/Withdraw)
router.patch("/:id/balance", async (req, res) => {
    const { id } = req.params;
    const { amount } = req.body;

    if (!amount || isNaN(amount)) {
        return res.status(400).json({ error: "Invalid amount" });
    }

    try {
        const result = await db.query(
            `UPDATE accounts SET balance = balance + $1 WHERE account_id = $2 RETURNING *`,
            [amount, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Account not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating balance:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
