export interface TeamRecord {
  wins: number;
  losses: number;
}

export interface RecentGame {
  opponent: string;
  score: string;
  result: 'W' | 'L';
}

export interface TeamStatsResponse {
  PK: string;
  UpdatedTimestamp: string;
  League: 'NFL' | 'NBA' | 'MLB';
  CurrentRecord: TeamRecord;
  RecentGames: RecentGame[];
  WinProbability: number;
}

export interface ModelFactor {
  factor: string;
  impact: 'Positive' | 'Negative' | 'Neutral';
}

export interface ModelMetrics {
  algorithm: string;
  confidenceScore: number;
  factors: ModelFactor[];
}

export interface PredictionResponse {
  teamId: string;
  lastModelRun: string;
  winProbability: number;
  modelMetrics: ModelMetrics;
}