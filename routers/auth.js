const express = require("express");
const jwt = require("jsonwebtoken");
const router = express.Router();

router.post("/login", (req, res) => {
  const { email } = req.body;
  // In real case, verify user credentials from DB

  // For demo, create token with email
  const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: "1h" });
  res.json({ token });
});

router.get("/protected", (req, res) => {
  // Middleware added later to verify token
  res.send("This route is protected");
});

module.exports = router;