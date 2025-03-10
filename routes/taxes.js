const express = require("express");
const router = express.Router();
const db = require("../db"); // Ensure db.js is properly configured for PostgreSQL

// Create a new tax
router.post("/", async (req, res) => {
    const { tax_name, tax_rate, applicable_on } = req.body;

    if (!tax_name || !tax_rate || !applicable_on) {
        return res.status(400).json({ error: "All fields are required" });
    }

    try {
        const result = await db.query(
            `INSERT INTO taxes (tax_name, tax_rate, applicable_on) 
             VALUES ($1, $2, $3) RETURNING *`,
            [tax_name, tax_rate, applicable_on]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error("Error creating tax:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get all taxes
router.get("/", async (req, res) => {
    try {
        const result = await db.query(`SELECT * FROM taxes ORDER BY tax_name ASC`);
        res.json(result.rows);
    } catch (error) {
        console.error("Error fetching taxes:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Get a specific tax by ID
router.get("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(`SELECT * FROM taxes WHERE tax_id = $1`, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Tax not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error fetching tax:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Update a tax
router.put("/:id", async (req, res) => {
    const { id } = req.params;
    const { tax_name, tax_rate, applicable_on } = req.body;

    try {
        const result = await db.query(
            `UPDATE taxes 
             SET tax_name = $1, tax_rate = $2, applicable_on = $3 
             WHERE tax_id = $4 RETURNING *`,
            [tax_name, tax_rate, applicable_on, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Tax not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error("Error updating tax:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Delete a tax
router.delete("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const result = await db.query(`DELETE FROM taxes WHERE tax_id = $1 RETURNING *`, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Tax not found" });
        }
        res.json({ message: "Tax deleted successfully" });
    } catch (error) {
        console.error("Error deleting tax:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

module.exports = router;
