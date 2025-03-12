const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Create a new benefit
router.post("/", async (req, res) => {
    const { employee_id, benefit_type, amount, effective_date } = req.body;

    if (!employee_id || !benefit_type || !amount || !effective_date) {
        return res.status(400).json({ error: "All fields are required" });
    }

    try {
        const result = await db.query(
            `INSERT INTO employee_benefits (employee_id, benefit_type, amount, effective_date) 
             VALUES ($1, $2, $3, $4) RETURNING *`,
            [employee_id, benefit_type, amount, effective_date]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error creating benefit:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all benefits
router.get("/", async (req, res) => {
    try {
        const result = await db.query(`SELECT * FROM employee_benefits ORDER BY effective_date DESC`);
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching benefits:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get a specific benefit by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(`SELECT * FROM employee_benefits WHERE benefit_id = $1`, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Benefit not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching benefit:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all benefits for a specific employee
router.get("/employee/:employee_id", async (req, res) => {
    const { employee_id } = req.params;

    try {
        const result = await db.query(`SELECT * FROM employee_benefits WHERE employee_id = $1 ORDER BY effective_date DESC`, [employee_id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "No benefits found for this employee" });
        }
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching employee benefits:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update a benefit
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { benefit_type, amount, effective_date } = req.body;

    try {
        const result = await db.query(
            `UPDATE employee_benefits 
             SET benefit_type = $1, amount = $2, effective_date = $3 
             WHERE benefit_id = $4 RETURNING *`,
            [benefit_type, amount, effective_date, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Benefit not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating benefit:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete a benefit
router.delete("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(`DELETE FROM employee_benefits WHERE benefit_id = $1 RETURNING *`, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Benefit not found" });
        }
        res.json({ message: "Benefit deleted successfully" });
    } catch (error) {
        console.error("Error deleting benefit:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
