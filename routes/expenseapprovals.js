const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Submit a new expense approval request
router.post("/", async (req, res) => {
    const { expense_id, approved_by, approval_status } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO expense_approvals (expense_id, approved_by, approval_status) VALUES ($1, $2, $3) RETURNING *`,
            [expense_id, approved_by, approval_status]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding expense approval:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all expense approvals
router.get("/", async (req, res) => {
    try {
        const result = await db.query(
            `SELECT ea.approval_id, e.name AS approver_name, ea.approval_status, ea.approval_date, ex.amount, ex.description
             FROM expense_approvals ea
             JOIN expenses ex ON ea.expense_id = ex.expense_id
             LEFT JOIN employees e ON ea.approved_by = e.employee_id
             ORDER BY ea.approval_date DESC`
        );
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching expense approvals:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get approval by expense ID
router.get("/expense/:expense_id", async (req, res) => {
    const { expense_id } = req.params;

    try {
        const result = await db.query(
            `SELECT * FROM expense_approvals WHERE expense_id = $1`,
            [expense_id]
        );
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching approval by expense ID:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get approval by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(
            `SELECT * FROM expense_approvals WHERE approval_id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Approval record not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching approval record:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update approval status
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { approval_status, approved_by } = req.body;

    try {
        const result = await db.query(
            `UPDATE expense_approvals SET approval_status = $1, approved_by = $2, approval_date = CURRENT_TIMESTAMP WHERE approval_id = $3 RETURNING *`,
            [approval_status, approved_by, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Approval record not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating approval status:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete an approval record
router.delete("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(
            `DELETE FROM expense_approvals WHERE approval_id = $1 RETURNING *`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Approval record not found" });
        }
        res.json({ message: "Expense approval record deleted successfully" });
    } catch (error) {
        console.error("Error deleting expense approval:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
