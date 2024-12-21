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
//for new packages
//npm install dotenv
//for latest version
//npx npm-check-updates -u
//latest version
//npm install
//list
//npm list
//single packages
//npm install express@latest







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
// git commit -m "order modify/bill modify"
// git push origin main //

// //global
// git config --global user.email "your-email@example.com"
// git config --global user.name "Your Name"

// //this repository only
// git config user.email "your-email@example.com"
// git config user.name "Your Name"



