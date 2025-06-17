const express = require('express');
const pool = require('./db'); // Dynamic database loader
const http = require('http');
const socketIo = require('socket.io');
const userLoginRoute = require('./routes/userLogin');
const billConfig = require('./routes/billConfig');
const propertyRoutes = require('./routes/propertyRoutes');
const outletRoutes = require('./routes/outlet');
const tableRoutes = require('./routes/tableconfigs');
const billRoutes = require('./routes/billing');
const categoriesRoutes = require('./routes/categories');
const dateConfigRoutes = require('./routes/dateConfig');
const guestRecordRoutes = require('./routes/guestRecord');
const happyHourConfigRoutes = require('./routes/happyHourConfig');
const itemRoutes = require('./routes/item');
const inventoryRoutes = require('./routes/inventory');
const kotconfigsRoutes = require('./routes/kotConfig');
const ordersRoutes = require('./routes/order');
const paymentRoutes = require('./routes/payments');
const printerRoutes = require('./routes/printers');
const reservationRoutes = require('./routes/reservation');
const servicechargeRoutes = require('./routes/servicecharge_config');
const packingchargeRoutes = require('./routes/packingcharge_config');
const platformfeesRoutes = require('./routes/platformfees');
const discountRoutes = require('./routes/discount');
const deliverychargeRoutes = require('./routes/deliverycharge');
const subcategoriesRoutes = require('./routes/subcategories');
const taxconfigRoutes = require('./routes/tax_config');
const userpermissionsRoutes = require('./routes/user_permissions');
const waitersRoutes = require('./routes/waiterMaster');
const app = express();
const server = require('http').createServer(app);

const PORT = process.env.PORT || 3000;

// Initialize Socket.io with CORS configuration
const io = socketIo(server, {
  cors: {
    origin: "http://localhost:3000", // Replace with your Flutter app's URL
    methods: ["GET", "POST"],
  },
});


// Middleware for JSON parsing
app.use(express.json());

// Listen for PostgreSQL notifications
async function listenForNotifications() {
  try {
    const client = await pool.connect();
    await client.query('LISTEN table_update'); // Ensure this matches your DB trigger name

    // Handle PostgreSQL notifications
    client.on('notification', (msg) => {
      const payload = msg.payload;
      console.log('Received notification:', payload);

      // Emit the notification to all connected clients
      io.emit('table_update', payload);
    });

    console.log('Listening for PostgreSQL notifications...');
  } catch (err) {
    console.error('Error listening for notifications:', err.message);
  }
}

listenForNotifications();

// Socket.io connection to handle real-time notifications
io.on('connection', (socket) => {
  console.log('A client connected');

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});


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
app.use('/api/packingcharge', packingchargeRoutes);
app.use('/api/discounts', discountRoutes);
app.use('/api/deliverycharges', deliverychargeRoutes);
app.use('/api/platformfees', platformfeesRoutes);
app.use('/api/subcategories', subcategoriesRoutes);
app.use('/api/taxconfig', taxconfigRoutes);
app.use('/api/userpermissions', userpermissionsRoutes);
app.use('/api/waiters', waitersRoutes);


// Root route
app.get('/', (req, res) => {
  res.send('Welcome to the Client Point of Sale System API!');
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something went wrong!');
});

// Start the server
// Start the server
server.listen(PORT, () => {
  const address = server.address();
  const hostname = require('os').hostname();
  const protocol = "http";

  console.log(`Client server running at ${protocol}://${hostname}:${address.port}`);
});
