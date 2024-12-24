const fs = require('fs');
const path = require('path');

const subdomain = process.argv[2];
if (!subdomain) {
    console.error('Subdomain not provided!');
    process.exit(1);
}

const setupClientServer = (subdomain) => {
    const clientDir = path.join(__dirname, `clients/${subdomain}`);
    if (!fs.existsSync(clientDir)) fs.mkdirSync(clientDir, { recursive: true });

    const templateDir = path.join(__dirname, 'client_template');
    fs.cpSync(templateDir, clientDir, { recursive: true });

    console.log(`Client server created for ${subdomain}`);
};

setupClientServer(subdomain);
