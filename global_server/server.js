const express = require('express');
const propertyRoutes = require('./routes/propertyRoutes');
const reviewroutes = require('./routes/reviewRoutes');
const { globalPool } = require('./db');
const app = express();
const PORT = 3000;

app.use(express.json());
app.use('/api/properties', propertyRoutes);
app.use('/api/review', reviewroutes);

app.get('/', (req, res) => {
  res.send('Welcome to the Global Server!');
});

// globalPool.query('SELECT NOW()', (err, res) => {
//   if (err) {
//     console.error('Database connection failed:', err.message);
//   } else {
//     console.log('Database connection successful:', res.rows[0]);
//   }
//   globalPool.end(); // Close the connection
// });

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something went wrong!');
});


app.listen(PORT, () => {
  console.log(`Global server running at http://global.localhost:${PORT}`);
});
