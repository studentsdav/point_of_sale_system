const express = require('express');
const pool = require('./db'); // Database connection module
const userLoginRoute = require('./routes/userLogin');
const userRegistrationRoute = require('./routes/userRegistration');
const itemMasterRoute = require('./routes/itemMaster');
const forgotPasswordRoute = require('./routes/forgotPassword');
const waiterMasterRoute = require('./routes/waiterMaster');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json()); // Middleware for JSON parsing

// Use the routes
app.use('/api', userLoginRoute);
app.use('/api', userRegistrationRoute);
app.use('/api', itemMasterRoute);
app.use('/api', forgotPasswordRoute);
app.use('/api', waiterMasterRoute);

// Root route
app.get('/', (req, res) => {
  res.send('Welcome to the Point of Sale System API!');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

// const express = require('express');
// const pool = require('./db'); // Database connection module

// const app = express();
// const PORT = process.env.PORT || 3000;

// app.use(express.json()); // Middleware for JSON parsing

// // Root route
// app.get('/', (req, res) => {
//   res.send('Welcome to the User API!');
// });

// // Route to check database connection
// app.get('/api/db-status.json', async (req, res) => {
//   try {
//     await pool.query('SELECT 1'); // Test query
//     res.json({ connected: true });
//   } catch (err) {
//     console.error('Database connection error:', err.message);
//     res.json({ connected: false });
//   }
// });

// // GET /api/users or /api/users.json - Get all users
// app.get(['/api/users.json'], async (req, res) => {
//   try {
//     const result = await pool.query('SELECT * FROM user_login');
//     res.json(result.rows);
//   } catch (err) {
//     console.error('Error fetching users:', err.message);
//     res.status(500).json({ error: err.message });
//   }
// });

// // GET /api/users/:id or /api/users/:id.json - Get a user by ID
// app.get(['/api/users/:id.json'], async (req, res) => {
//   try {
//     const { id } = req.params;
//     const result = await pool.query('SELECT * FROM user_login WHERE user_id = $1', [id]);
//     if (result.rows.length === 0) {
//       return res.status(404).json({ message: 'User not found' });
//     }
//     res.json(result.rows[0]);
//   } catch (err) {
//     console.error(`Error fetching user with ID ${req.params.id}:`, err.message);
//     res.status(500).json({ error: err.message });
//   }
// });

// // POST /api/users - Create a new user
// app.post('/api/users', async (req, res) => {
//   try {
//     const { username, password_hash, dob, mobile, email, outlet, property_id, role } = req.body;
//     const result = await pool.query(
//       `INSERT INTO user_login 
//        (username, password_hash, dob, mobile, email, outlet, property_id, role) 
//        VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
//       [username, password_hash, dob, mobile, email, outlet, property_id, role]
//     );
//     res.status(201).json(result.rows[0]);
//   } catch (err) {
//     console.error('Error creating user:', err.message);
//     res.status(500).json({ error: err.message });
//   }
// });

// // PUT /api/users/:id - Update a user by ID
// app.put('/api/users/:id', async (req, res) => {
//   try {
//     const { id } = req.params;
//     const { username, password_hash, dob, mobile, email, outlet, property_id, role, status } =
//       req.body;
//     const result = await pool.query(
//       `UPDATE user_login 
//        SET username = $1, password_hash = $2, dob = $3, mobile = $4, email = $5, 
//            outlet = $6, property_id = $7, role = $8, status = $9, updated_at = NOW() 
//        WHERE user_id = $10 RETURNING *`,
//       [username, password_hash, dob, mobile, email, outlet, property_id, role, status, id]
//     );
//     if (result.rows.length === 0) {
//       return res.status(404).json({ message: 'User not found' });
//     }
//     res.json(result.rows[0]);
//   } catch (err) {
//     console.error(`Error updating user with ID ${req.params.id}:`, err.message);
//     res.status(500).json({ error: err.message });
//   }
// });

// // DELETE /api/users/:id - Delete a user by ID
// app.delete('/api/users/:id', async (req, res) => {
//   try {
//     const { id } = req.params;
//     const result = await pool.query('DELETE FROM user_login WHERE user_id = $1 RETURNING *', [id]);
//     if (result.rows.length === 0) {
//       return res.status(404).json({ message: 'User not found' });
//     }
//     res.status(204).end();
//   } catch (err) {
//     console.error(`Error deleting user with ID ${req.params.id}:`, err.message);
//     res.status(500).json({ error: err.message });
//   }
// });

// // Start the server
// app.listen(PORT, () => {
//   console.log(`Server running on http://localhost:${PORT}`);
// });
