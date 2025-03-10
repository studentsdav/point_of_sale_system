const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Add a new salary record
router.post("/", async (req, res) => {
    const { employee_id, base_salary, present_days, absent_days, overtime_hours,
        underworked_hours, commission_earned, tips_earned, advance_deduction,
        payment_method_id, salary_month } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO salaries (
                employee_id, base_salary, present_days, absent_days, overtime_hours, underworked_hours, 
                commission_earned, tips_earned, advance_deduction, payment_method_id, salary_month
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *`,
            [employee_id, base_salary, present_days, absent_days, overtime_hours, underworked_hours,
                commission_earned, tips_earned, advance_deduction, payment_method_id, salary_month]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding salary:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all salary records
router.get("/", async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM salaries ORDER BY salary_month DESC");
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching salaries:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get salary record by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("SELECT * FROM salaries WHERE salary_id = $1", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Salary record not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching salary record:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get salary for a specific employee
router.get("/employee/:employee_id", async (req, res) => {
    const { employee_id } = req.params;
    try {
        const result = await db.query("SELECT * FROM salaries WHERE employee_id = $1 ORDER BY salary_month DESC", [employee_id]);
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching employee salary records:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update salary record
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { base_salary, present_days, absent_days, overtime_hours, underworked_hours,
        commission_earned, tips_earned, advance_deduction, payment_method_id, salary_month } = req.body;

    try {
        const result = await db.query(
            `UPDATE salaries 
             SET base_salary = $1, present_days = $2, absent_days = $3, overtime_hours = $4, 
                 underworked_hours = $5, commission_earned = $6, tips_earned = $7, 
                 advance_deduction = $8, payment_method_id = $9, salary_month = $10, 
                 payment_date = CURRENT_TIMESTAMP
             WHERE salary_id = $11 RETURNING *`,
            [base_salary, present_days, absent_days, overtime_hours, underworked_hours,
                commission_earned, tips_earned, advance_deduction, payment_method_id, salary_month, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Salary record not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating salary record:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete salary record
router.delete("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("DELETE FROM salaries WHERE salary_id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Salary record not found" });
        }
        res.json({ message: "Salary record deleted successfully" });
    } catch (error) {
        console.error("Error deleting salary record:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
