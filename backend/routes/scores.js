const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Score = require('../models/Score');
const User = require('../models/User');

const auth = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ message: 'No token' });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ message: 'Invalid token' });
  }
};

// Save game score
router.post('/', auth, async (req, res) => {
  try {
    const { difficulty, team1Score, team2Score, winner } = req.body;
    const user = await User.findById(req.user.id);

    const score = await Score.create({
      userId: req.user.id,
      name: user.name,
      difficulty,
      team1Score,
      team2Score,
      winner,
    });

    if (winner) await User.findByIdAndUpdate(req.user.id, { $inc: { wins: 1, stars: 1 } });

    res.status(201).json(score);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get leaderboard
router.get('/leaderboard', async (req, res) => {
  try {
    const users = await User.find().sort({ wins: -1, stars: -1 }).limit(10).select('name wins stars');
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
