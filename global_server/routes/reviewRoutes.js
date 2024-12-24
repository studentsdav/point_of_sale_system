const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const express = require('express');
const router = express.Router();
const { globalPool } = require('../db');

// Approve Property (or Review Entity) and Create Subdomain Configuration
router.post('/approve/:entityId', async (req, res) => {
  const { entityId } = req.params;

  try {
    // Update the entity status to 'approved' in the database
    const result = await globalPool.query(
      `UPDATE properties SET status = $1, updated_at = NOW() WHERE property_id = $2 RETURNING *`,
      ['approved', entityId]
    );

    const entity = result.rows[0];
    if (!entity) {
      return res.status(404).json({ success: false, message: 'Entity not found or already approved.' });
    }

    // Generate a subdomain for the approved entity
    const subdomain = `${entity.property_name.toLowerCase().replace(/\s+/g, '')}.localhost`;

    // Call the createSubdomainConfig.js script
    exec(`node ../createSubdomainConfig.js ${subdomain}`, (err, stdout, stderr) => {
      if (err) {
        console.error(`Error creating subdomain config: ${err.message}`);
        return res.status(500).json({ success: false, message: 'Error creating subdomain configuration.' });
      }

      console.log(stdout);

      // Send a success response
      res.status(200).json({
        success: true,
        message: `Entity approved and subdomain created: ${subdomain}`,
        subdomain: subdomain,
        entity: entity,
      });
    });
  } catch (err) {
    console.error('Error approving entity:', err.message);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
});

module.exports = router;
