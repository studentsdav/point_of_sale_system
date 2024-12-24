const fs = require('fs');
const path = require('path');

// Get subdomain from command-line arguments
const subdomain = process.argv[2];
if (!subdomain) {
    console.error('Subdomain not provided!');
    process.exit(1);
}

// Path to config.json
const configPath = path.join(__dirname, 'config.json');

// Add subdomain configuration
const createSubdomainConfig = (subdomain) => {
    try {
        // Ensure config.json exists and is valid
        if (!fs.existsSync(configPath)) {
            fs.writeFileSync(configPath, JSON.stringify({}, null, 2), 'utf-8');
        }

        let config = {};
        const rawData = fs.readFileSync(configPath, 'utf-8');
        if (rawData.trim()) {
            config = JSON.parse(rawData);
        }

        // Check if the subdomain already exists
        if (config.clients && config.clients[subdomain]) {
            console.log(`Subdomain ${subdomain} already exists.`);
            return;
        }

        // Add new subdomain entry
        if (!config.clients) {
            config.clients = {};
        }

        config.clients[subdomain] = {
            user: `user_${subdomain}`,
            password: `password_${subdomain}`,
            database: `db_${subdomain}`,
            host: 'localhost',
            port: 5432,
        };

        // Write the updated config back to file
        fs.writeFileSync(configPath, JSON.stringify(config, null, 2), 'utf-8');
        console.log(`Subdomain configuration for ${subdomain} created successfully.`);
    } catch (err) {
        console.error('Error creating subdomain configuration:', err.message);
        process.exit(1);
    }
};

// Run the function
createSubdomainConfig(subdomain);
