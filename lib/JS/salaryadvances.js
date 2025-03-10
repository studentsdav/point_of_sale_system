const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly set up for PostgreSQL

// Add a new salary advance
router.post("/", async (req, res) => {
    const { employee_id, amount, payment_method_id, advance_date, repaid } = req.body;
    try {
        const result = await db.query(
            `INSERT INTO salary_advances (employee_id, amount, payment_method_id, advance_date, repaid) 
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [employee_id, amount, payment_method_id, advance_date, repaid]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding salary advance:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all salary advances
router.get("/", async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM salary_advances ORDER BY created_at DESC");
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching salary advances:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get salary advance by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("SELECT * FROM salary_advances WHERE advance_id = $1", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Salary advance not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching salary advance:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update a salary advance
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { amount, payment_method_id, advance_date, repaid } = req.body;
    try {
        const result = await db.query(
            `UPDATE salary_advances 
             SET amount = $1, payment_method_id = $2, advance_date = $3, repaid = $4, created_at = CURRENT_TIMESTAMP
             WHERE advance_id = $5 RETURNING *`,
            [amount, payment_method_id, advance_date, repaid, id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Salary advance not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating salary advance:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete a salary advance
router.delete("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("DELETE FROM salary_advances WHERE advance_id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Salary advance not found" });
        }
        res.json({ message: "Salary advance deleted successfully" });
    } catch (error) {
        console.error("Error deleting salary advance:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
