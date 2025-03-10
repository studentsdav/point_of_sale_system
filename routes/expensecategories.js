const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Add a new expense category
router.post("/", async (req, res) => {
    const { category_name, description } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO expense_categories (category_name, description) 
             VALUES ($1, $2) RETURNING *`,
            [category_name, description]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding expense category:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all expense categories
router.get("/", async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM expense_categories ORDER BY created_at DESC");
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching expense categories:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get category by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("SELECT * FROM expense_categories WHERE category_id = $1", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Expense category not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching expense category:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update expense category
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { category_name, description } = req.body;

    try {
        const result = await db.query(
            `UPDATE expense_categories 
             SET category_name = $1, description = $2, created_at = CURRENT_TIMESTAMP
             WHERE category_id = $3 RETURNING *`,
            [category_name, description, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Expense category not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating expense category:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete expense category
router.delete("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query("DELETE FROM expense_categories WHERE category_id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Expense category not found" });
        }
        res.json({ message: "Expense category deleted successfully" });
    } catch (error) {
        console.error("Error deleting expense category:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
