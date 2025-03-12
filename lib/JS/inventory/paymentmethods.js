const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Add a new payment method
router.post("/", async (req, res) => {
    const { method_name, description } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO payment_methods (method_name, description) VALUES ($1, $2) RETURNING *`,
            [method_name, description]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding payment method:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all payment methods
router.get("/", async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM payment_methods ORDER BY method_name ASC");
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching payment methods:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get payment method by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("SELECT * FROM payment_methods WHERE method_id = $1", [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Payment method not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching payment method:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update payment method
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { method_name, description } = req.body;

    try {
        const result = await db.query(
            `UPDATE payment_methods SET method_name = $1, description = $2 WHERE method_id = $3 RETURNING *`,
            [method_name, description, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Payment method not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating payment method:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete payment method
router.delete("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("DELETE FROM payment_methods WHERE method_id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Payment method not found" });
        }
        res.json({ message: "Payment method deleted successfully" });
    } catch (error) {
        console.error("Error deleting payment method:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
