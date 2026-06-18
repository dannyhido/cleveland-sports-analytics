const TEAMS = {
  browns: {
    PK: 'TEAM#BROWNS',
    League: 'NFL',
    CurrentRecord: { wins: 11, losses: 6 },
    RecentGames: [
      { opponent: 'Steelers', score: '24-17', result: 'W' },
      { opponent: 'Ravens', score: '14-20', result: 'L' },
      { opponent: 'Bengals', score: '31-10', result: 'W' },
    ],
    WinProbability: 0.62,
  },
  cavaliers: {
    PK: 'TEAM#CAVALIERS',
    League: 'NBA',
    CurrentRecord: { wins: 52, losses: 30 },
    RecentGames: [
      { opponent: 'Knicks', score: '112-105', result: 'W' },
      { opponent: 'Celtics', score: '98-110', result: 'L' },
      { opponent: 'Bucks', score: '115-108', result: 'W' },
    ],
    WinProbability: 0.58,
  },
  guardians: {
    PK: 'TEAM#GUARDIANS',
    League: 'MLB',
    CurrentRecord: { wins: 92, losses: 70 },
    RecentGames: [
      { opponent: 'Yankees', score: '5-3', result: 'W' },
      { opponent: 'White Sox', score: '2-4', result: 'L' },
      { opponent: 'Tigers', score: '6-1', result: 'W' },
    ],
    WinProbability: 0.49,
  },
};

function teamStats(teamId) {
  const team = TEAMS[teamId.toLowerCase()];
  if (!team) return null;

  return {
    ...team,
    UpdatedTimestamp: new Date().toISOString(),
  };
}

function prediction(teamId) {
  const team = TEAMS[teamId.toLowerCase()];
  if (!team) return null;

  const winProbability = team.WinProbability;
  return {
    teamId: teamId.toUpperCase(),
    lastModelRun: new Date().toISOString(),
    winProbability,
    modelMetrics: {
      algorithm: 'XGBoost-Classifier',
      confidenceScore: 0.84,
      factors: [
        { factor: 'Home Field Advantage', impact: 'Positive' },
        {
          factor: 'Recent Form (Last 5 Games)',
          impact: team.CurrentRecord.wins > team.CurrentRecord.losses ? 'Positive' : 'Negative',
        },
        { factor: 'Roster Health Index', impact: winProbability > 0.5 ? 'Positive' : 'Neutral' },
      ],
    },
  };
}

module.exports = { teamStats, prediction, TEAMS };
