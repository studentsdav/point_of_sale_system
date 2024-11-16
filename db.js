const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

module.exports = pool;



//start server//
//node server.js
//nodemon server.js

// for new project///
// git init
// git add .
// git commit -m "Initial commit with complete Flutter project"
// git remote add origin YOUR_GITHUB_REPO_URL
// git push -u origin main
// git push --set-upstream origin main
// for update///
// git add .
// git commit -m "Describe the changes or updates made"
// git push origin main





