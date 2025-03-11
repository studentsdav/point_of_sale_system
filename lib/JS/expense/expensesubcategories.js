const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Add a new expense subcategory
router.post("/", async (req, res) => {
    const { category_id, subcategory_name } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO expense_subcategories (category_id, subcategory_name) VALUES ($1, $2) RETURNING *`,
            [category_id, subcategory_name]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error adding expense subcategory:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all expense subcategories
router.get("/", async (req, res) => {
    try {
        const result = await db.query(
            `SELECT es.subcategory_id, es.subcategory_name, ec.category_name 
             FROM expense_subcategories es
             JOIN expense_categories ec ON es.category_id = ec.category_id
             ORDER BY ec.category_name, es.subcategory_name`
        );
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching expense subcategories:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get subcategories by category ID
router.get("/category/:category_id", async (req, res) => {
    const { category_id } = req.params;

    try {
        const result = await db.query(
            `SELECT * FROM expense_subcategories WHERE category_id = $1 ORDER BY subcategory_name`,
            [category_id]
        );
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching subcategories by category:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get expense subcategory by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query(
            `SELECT * FROM expense_subcategories WHERE subcategory_id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Subcategory not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching expense subcategory:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update an expense subcategory
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { category_id, subcategory_name } = req.body;

    try {
        const result = await db.query(
            `UPDATE expense_subcategories SET category_id = $1, subcategory_name = $2 WHERE subcategory_id = $3 RETURNING *`,
            [category_id, subcategory_name, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Subcategory not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating expense subcategory:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete an expense subcategory
router.delete("/:id", async (req, res) => {
    const { id } = req.params;
    try {
        const result = await db.query(
            `DELETE FROM expense_subcategories WHERE subcategory_id = $1 RETURNING *`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Subcategory not found" });
        }
        res.json({ message: "Expense subcategory deleted successfully" });
    } catch (error) {
        console.error("Error deleting expense subcategory:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
