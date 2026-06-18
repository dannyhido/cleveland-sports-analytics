const express = require('express');
const cors = require('cors');
const { teamStats, prediction } = require('./mock-data');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'cleveland-sports-local-api' });
});

app.get('/teams/:teamId', (req, res) => {
  const data = teamStats(req.params.teamId);
  if (!data) {
    return res.status(404).json({ error: `Team '${req.params.teamId}' not found.` });
  }
  res.json(data);
});

app.get('/predictions/:teamId', (req, res) => {
  const data = prediction(req.params.teamId);
  if (!data) {
    return res.status(404).json({ error: `Predictions for '${req.params.teamId}' not found.` });
  }
  res.json(data);
});

app.listen(PORT, () => {
  console.log(`Local API running at http://localhost:${PORT}`);
  console.log('  GET /teams/{browns|cavaliers|guardians}');
  console.log('  GET /predictions/{browns|cavaliers|guardians}');
});
