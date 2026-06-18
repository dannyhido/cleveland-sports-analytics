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
   * Fetches real-time team stats for the requested Cleveland franchise.
   * Leverages shareReplay(1) to cache the stream and prevent redundant duplicate network requests.
   */
  getTeamStats(teamId: 'browns' | 'cavaliers' | 'guardians'): Observable<TeamStatsResponse> {
    return this.http.get<TeamStatsResponse>(`${this.baseUrl}/teams/${teamId}`).pipe(
      shareReplay(1),
      catchError((error: HttpErrorResponse) => {
        console.warn(`[ApiService] Live endpoint failed. Falling back to local mock data for: ${teamId}`);
        return of(this.getMockTeamStats(teamId));
      })
    );
  }

  /**
   * Retrieves specific ML model confidence and prediction metrics for upcoming matchups.
   */
  getPredictionData(teamId: 'browns' | 'cavaliers' | 'guardians'): Observable<PredictionResponse> {
    return this.http.get<PredictionResponse>(`${this.baseUrl}/predictions/${teamId}`).pipe(
      catchError((error: HttpErrorResponse) => {
        console.warn(`[ApiService] Live endpoint failed. Falling back to local mock predictions for: ${teamId}`);
        return of(this.getMockPredictionData(teamId));
      })
    );
  }

  /**
   * Local Mock Data Generator for Team Stats MVP Testing
   */
  private getMockTeamStats(teamId: string): TeamStatsResponse {
    const isBrowns = teamId === 'browns';
    const isCavs = teamId === 'cavaliers';
    
    return {
      PK: `TEAM#${teamId.toUpperCase()}`,
      UpdatedTimestamp: new Date().toISOString(),
      League: isBrowns ? 'NFL' : isCavs ? 'NBA' : 'MLB',
      CurrentRecord: isBrowns ? { wins: 11, losses: 6 } : isCavs ? { wins: 52, losses: 30 } : { wins: 92, losses: 70 },
      RecentGames: [
        { opponent: isBrowns ? 'Steelers' : isCavs ? 'Knicks' : 'Yankees', score: '24-17', result: 'W' },
        { opponent: isBrowns ? 'Ravens' : isCavs ? 'Celtics' : 'White Sox', score: '14-20', result: 'L' },
        { opponent: isBrowns ? 'Bengals' : isCavs ? 'Bucks' : 'Tigers', score: '31-10', result: 'W' }
      ],
      WinProbability: isBrowns ? 0.62 : isCavs ? 0.58 : 0.49
    };
  }

  /**
   * Local Mock Data Generator for ML Predictions MVP Testing
   */
  private getMockPredictionData(teamId: string): PredictionResponse {
    const probability = teamId === 'browns' ? 0.62 : teamId === 'cavaliers' ? 0.58 : 0.49;
    return {
      teamId: teamId.toUpperCase(),
      lastModelRun: new Date().toISOString(),
      winProbability: probability,
      modelMetrics: {
        algorithm: 'XGBoost-Classifier',
        confidenceScore: 0.84,
        factors: [
          { factor: 'Home Field Advantage', impact: 'Positive' },
          { factor: 'Roster Health Index', impact: probability > 0.5 ? 'Positive' : 'Neutral' },
          { factor: 'Opponent Head-to-Head History', impact: probability < 0.5 ? 'Negative' : 'Positive' }
        ]
      }
    };
  }
}