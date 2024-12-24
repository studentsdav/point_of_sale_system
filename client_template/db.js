const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Path to the configuration file
const configPath = path.join(__dirname, '../global_server/config.json');

// Function to dynamically load the client database configuration
const getClientDbConfig = (subdomain) => {
  const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

  if (!config.clients[subdomain]) {
    throw new Error(`No configuration found for subdomain: ${subdomain}`);
  }

  return new Pool(config.clients[subdomain]);
};

module.exports = getClientDbConfig;




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
// git commit -m "order modify/bill modify"
// git push origin main //



