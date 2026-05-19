const mongoose = require('mongoose');

const scoreSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: true },
  difficulty: { type: String, enum: ['EASY', 'MEDIUM', 'HARD'], required: true },
  team1Score: { type: Number, default: 0 },
  team2Score: { type: Number, default: 0 },
  winner: { type: Number },
}, { timestamps: true });

module.exports = mongoose.model('Score', scoreSchema);
