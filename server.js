const express = require('express');
const pool = require('./db'); // Database connection module
const userLoginRoute = require('./routes/userLogin');
const billConfig = require('./routes/billConfig');
const propertyRoutes = require('./routes/propertyRoutes');
const outletRoutes = require('./routes/outlet');
const tableRoutes = require('./routes/tableconfigs');
const billRoutes = require('./routes/billing');
const categoriesRoutes =  require('./routes/categories');
const dateConfigRoutes =  require('./routes/dateConfig');
const guestRecordRoutes =  require('./routes/guestRecord');
const happyHourConfigRoutes =  require('./routes/happyHourConfig');
const itemRoutes =  require('./routes/item');
const inventoryRoutes =  require('./routes/inventory');
const kotconfigsRoutes =  require('./routes/kotConfig');
const ordersRoutes =  require('./routes/order');
const paymentRoutes =  require('./routes/payments');
const printerRoutes =  require('./routes/printers');
const reservationRoutes =  require('./routes/reservation');
const servicechargeRoutes =  require('./routes/servicecharge_config');
const subcategoriesRoutes =  require('./routes/subcategories');
const taxconfigRoutes =  require('./routes/tax_config');
const userpermissionsRoutes =  require('./routes/user_permissions');
const waitersRoutes =  require('./routes/waiterMaster');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); // Middleware for JSON parsing

// Use the routes
app.use('/api/users', userLoginRoute);
app.use('/api/bill-config', billConfig);
app.use('/api/properties', propertyRoutes);
app.use('/api', outletRoutes);
app.use('/api/table-config', tableRoutes);
app.use('/api/bill', billRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/date_config', dateConfigRoutes);
app.use('/api/guest_record', guestRecordRoutes);
app.use('/api/happy-hour-config', happyHourConfigRoutes);
app.use('/api/items', itemRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/kotconfigs', kotconfigsRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/printer', printerRoutes);
app.use('/api/reservation', reservationRoutes);
app.use('/api/servicecharge', servicechargeRoutes);
app.use('/api/subcategories', subcategoriesRoutes);
app.use('/api/taxconfig', taxconfigRoutes);
app.use('/api/userpermissions', userpermissionsRoutes);
app.use('/api/waiters', waitersRoutes);


// Root route
app.get('/', (req, res) => {
  res.send('Welcome to the Point of Sale System API!');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
