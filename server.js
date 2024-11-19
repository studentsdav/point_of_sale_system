const express = require('express');
const pool = require('./db'); // Database connection module
const userLoginRoute = require('./routes/userLogin');
const billConfig = require('./routes/billConfig');
const userRegistrationRoute = require('./routes/userRegistration');
const itemMasterRoute = require('./routes/itemMaster');
const forgotPasswordRoute = require('./routes/forgotPassword');
const waiterMasterRoute = require('./routes/waiterMaster');
const propertyRoutes = require('./routes/propertyRoutes');
const outletRoutes = require('./routes/outlet');
const tableRoutes = require('./routes/tableconfigs');



const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); // Middleware for JSON parsing

// Use the routes
app.use('/api', userLoginRoute);
app.use('/api/bill-config', billConfig);
app.use('/api', userRegistrationRoute);
app.use('/api', itemMasterRoute);
app.use('/api', forgotPasswordRoute);
app.use('/api', waiterMasterRoute);
app.use('/api', propertyRoutes);
app.use('/api', outletRoutes);
app.use('/api', tableRoutes);

// Root route
app.get('/', (req, res) => {
  res.send('Welcome to the Point of Sale System API!');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
