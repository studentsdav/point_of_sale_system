const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Add a new earning record
router.post("/", async (req, res) => {
    const { employee_id, earning_type, amount, order_id } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO staff_earnings (employee_id, earning_type, amount, order_id) 
             VALUES ($1, $2, $3, $4) RETURNING *`,
            [employee_id, earning_type, amount, order_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding staff earning:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all earnings
router.get("/", async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM staff_earnings ORDER BY created_at DESC");
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching earnings:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get earning record by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("SELECT * FROM staff_earnings WHERE earning_id = $1", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Earning record not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching earning record:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get earnings for a specific employee
router.get("/employee/:employee_id", async (req, res) => {
    const { employee_id } = req.params;
    try {
        const result = await db.query("SELECT * FROM staff_earnings WHERE employee_id = $1 ORDER BY created_at DESC", [employee_id]);
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching employee earnings:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update earning record
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { earning_type, amount, order_id } = req.body;

    try {
        const result = await db.query(
            `UPDATE staff_earnings 
             SET earning_type = $1, amount = $2, order_id = $3, created_at = CURRENT_TIMESTAMP
             WHERE earning_id = $4 RETURNING *`,
            [earning_type, amount, order_id, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Earning record not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating earning record:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete earning record
router.delete("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("DELETE FROM staff_earnings WHERE earning_id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Earning record not found" });
        }
        res.json({ message: "Earning record deleted successfully" });
    } catch (error) {
        console.error("Error deleting earning record:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
