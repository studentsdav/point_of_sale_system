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


//node server.js
//nodemon server.js


// Explanation of Commands:
// git checkout main: Ensures you're on the main branch (adjust if you want to use master or another branch).
// git add .: Stages all the files in your project for commit.
// git commit -m "message": Commits the staged files with a message.
// git pull origin main: Pushes the commit to the main branch on GitHub.
 //git init
 //git add .
//git commit -m "Initial commit with complete Flutter project"
// /git remote add origin YOUR_GITHUB_REPO_URL
// /git push -u origin main
// git push --set-upstream origin main


