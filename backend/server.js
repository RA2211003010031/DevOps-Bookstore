// require('dotenv').config();
// const express = require("express");
// const mongoose = require("mongoose");
// const cors = require("cors");

// const app = express();
// app.use(cors());
// app.use(express.json());

// app.get("/", (req, res) => {
//   res.send("Backend API is running!");
// });

// const PORT = process.env.PORT || 5000;
// const MONGO_URI = process.env.MONGO_URI;

// // MongoDB connection
// mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
//   .then(() => {
//     console.log("MongoDB Connected");
//     app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
//   })
//   .catch((err) => console.log("MongoDB connection error", err));

// server.js
require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const jwt = require("jsonwebtoken");

const app = express();

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;
const JWT_SECRET = process.env.JWT_SECRET;

app.use(cors());
app.use(express.json());

app.get('/api/books', async (req, res) => {
  try {
    const books = await Book.find(); // Fetch all books
    res.json(books);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching books', error: err.message });
  }
});

// Connect to MongoDB
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error("MongoDB connection error:", err));

// Sample User schema/model (for demo only)
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  name: String,
});

const User = mongoose.model("User", userSchema);

// JWT verification middleware
function verifyToken(req, res, next) {
  const bearerHeader = req.headers["authorization"];
  if (!bearerHeader) return res.status(403).json({ message: "No token provided" });

  const token = bearerHeader.split(" ")[1];
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ message: "Token is invalid" });
    req.user = decoded;
    next();
  });
}

// Login route (simplified, replace with real auth logic)
app.post("/api/auth/login", async (req, res) => {
  const { email, name } = req.body;

  // Find or create user for demo
  let user = await User.findOne({ email });
  if (!user) {
    user = new User({ email, name: name || "User" });
    await user.save();
  }

  const token = jwt.sign({ id: user._id, email: user.email }, JWT_SECRET, { expiresIn: "1h" });
  res.json({ token, user: { id: user._id, email: user.email, name: user.name } });
});

// Protected route example
app.get("/api/protected-data", verifyToken, (req, res) => {
  res.json({ secret: "This is protected data", user: req.user });
});

// Basic route test
app.get("/", (req, res) => {
  res.send("Backend API is running!");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
