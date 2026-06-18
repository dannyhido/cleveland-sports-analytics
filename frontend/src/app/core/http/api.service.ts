import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError, of } from 'rxjs';
import { catchError, shareReplay } from 'rxjs/operators';
import { TeamStatsResponse, PredictionResponse } from '../models/sports-data.model';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private http = inject(HttpClient);
  private readonly baseUrl = environment.apiUrl;

  /**
   * Normalize team IDs to match AWS backend (BROWNS, CAVALIERS, GUARDIANS)
   */
  private normalizeTeamId(teamId: string): string {
    return teamId.toUpperCase();
  }

  /**
   * Fetch team stats from AWS API Gateway
   */
  getTeamStats(teamId: 'browns' | 'cavaliers' | 'guardians'): Observable<TeamStatsResponse> {

    const normalizedId = this.normalizeTeamId(teamId);

    return this.http
      .get<TeamStatsResponse>(`${this.baseUrl}/teams/${normalizedId}`)
      .pipe(
        shareReplay(1),
        catchError((error: HttpErrorResponse) => {
          console.warn(`[ApiService] API failed for ${teamId}. Using mock fallback.`);
          return of(this.getMockTeamStats(teamId));
        })
      );
  }

  /**
   * Fetch ML prediction data from AWS API Gateway
   */
  getPredictionData(teamId: 'browns' | 'cavaliers' | 'guardians'): Observable<PredictionResponse> {

    const normalizedId = this.normalizeTeamId(teamId);

    return this.http
      .get<PredictionResponse>(`${this.baseUrl}/predictions/${normalizedId}`)
      .pipe(
        catchError((error: HttpErrorResponse) => {
          console.warn(`[ApiService] Prediction API failed for ${teamId}. Using mock fallback.`);
          return of(this.getMockPredictionData(teamId));
        })
      );
  }

  /**
   * MOCK: Team stats fallback (only used if AWS fails)
   */
  private getMockTeamStats(teamId: string): TeamStatsResponse {
    const isBrowns = teamId === 'browns';
    const isCavs = teamId === 'cavaliers';

    return {
      PK: `TEAM#${teamId.toUpperCase()}`,
      UpdatedTimestamp: new Date().toISOString(),
      League: isBrowns ? 'NFL' : isCavs ? 'NBA' : 'MLB',
      CurrentRecord: isBrowns
        ? { wins: 11, losses: 6 }
        : isCavs
        ? { wins: 52, losses: 30 }
        : { wins: 92, losses: 70 },
      RecentGames: [
        { opponent: 'Team A', score: '24-17', result: 'W' },
        { opponent: 'Team B', score: '14-20', result: 'L' },
        { opponent: 'Team C', score: '31-10', result: 'W' }
      ],
      WinProbability: isBrowns ? 0.62 : isCavs ? 0.58 : 0.49
    };
  }

  /**
   * MOCK: Prediction fallback
   */
  private getMockPredictionData(teamId: string): PredictionResponse {
    const probability =
      teamId === 'browns'
        ? 0.62
        : teamId === 'cavaliers'
        ? 0.58
        : 0.49;

    return {
      teamId: teamId.toUpperCase(),
      lastModelRun: new Date().toISOString(),
      winProbability: probability,
      modelMetrics: {
        algorithm: 'XGBoost-Classifier',
        confidenceScore: 0.84,
        factors: [
          { factor: 'Home Field Advantage', impact: 'Positive' },
          { factor: 'Roster Health Index', impact: 'Positive' },
          { factor: 'Opponent History', impact: 'Neutral' }
        ]
      }
    };
  }
}