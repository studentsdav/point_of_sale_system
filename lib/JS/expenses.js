const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Add a new expense
router.post("/", async (req, res) => {
    const { category_id, employee_id, vendor_id, payment_method_id, amount, description, expense_date } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO expenses (category_id, employee_id, vendor_id, payment_method_id, amount, description, expense_date) 
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [category_id, employee_id, vendor_id, payment_method_id, amount, description, expense_date]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding expense:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all expenses
router.get("/", async (req, res) => {
    try {
        const result = await db.query(
            `SELECT e.*, 
                    ec.category_name, 
                    emp.employee_name, 
                    v.vendor_name, 
                    pm.method_name 
             FROM expenses e
             LEFT JOIN expense_categories ec ON e.category_id = ec.category_id
             LEFT JOIN employees emp ON e.employee_id = emp.employee_id
             LEFT JOIN vendors v ON e.vendor_id = v.vendor_id
             LEFT JOIN payment_methods pm ON e.payment_method_id = pm.method_id
             ORDER BY e.expense_date DESC`
        );
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching expenses:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get expense by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query(
            `SELECT e.*, 
                    ec.category_name, 
                    emp.employee_name, 
                    v.vendor_name, 
                    pm.method_name 
             FROM expenses e
             LEFT JOIN expense_categories ec ON e.category_id = ec.category_id
             LEFT JOIN employees emp ON e.employee_id = emp.employee_id
             LEFT JOIN vendors v ON e.vendor_id = v.vendor_id
             LEFT JOIN payment_methods pm ON e.payment_method_id = pm.method_id
             WHERE e.expense_id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Expense not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching expense:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update expense
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { category_id, employee_id, vendor_id, payment_method_id, amount, description, expense_date } = req.body;

    try {
        const result = await db.query(
            `UPDATE expenses 
             SET category_id = $1, employee_id = $2, vendor_id = $3, 
                 payment_method_id = $4, amount = $5, description = $6, expense_date = $7, created_at = CURRENT_TIMESTAMP
             WHERE expense_id = $8 RETURNING *`,
            [category_id, employee_id, vendor_id, payment_method_id, amount, description, expense_date, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Expense not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating expense:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete expense
router.delete("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("DELETE FROM expenses WHERE expense_id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Expense not found" });
        }
        res.json({ message: "Expense deleted successfully" });
    } catch (error) {
        console.error("Error deleting expense:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
