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
// # Create a tag for the release (replace "v1.0.0" with your release version)
// git tag -a v1.0.0 -m "First stable release"

// # Push the tag to GitHub
// git push origin v1.0.0
//npm install express
//npm install -g nodemon





// for new project repo///
// git init
// git add .
// git commit -m "Initial commit with complete Flutter project"
// git remote add origin YOUR_GITHUB_REPO_URL
// git push -u origin main
// git push --set-upstream origin main
// for update///
// git pull origin main
// git add .
// git commit -m "notification issue resolved"
// git push origin main //



