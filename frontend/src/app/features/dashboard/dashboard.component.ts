import { Component, OnInit, inject } from '@angular/core';
import { forkJoin, map, catchError, of } from 'rxjs';
import { ApiService } from '../../core/http/api.service';
import { TeamStatsResponse } from '../../core/models/sports-data.model';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [SharedModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {
  private apiService = inject(ApiService);

  // Component UI State variables
  public loading: boolean = true;
  public errorMessage: string | null = null;

  // Domain data structures initialized for our overview layouts
  public teamSnapshots: { [key: string]: TeamStatsResponse } = {};
  public aggregateWinProbabilities: number[] = [];
  public chartLabels: string[] = ['Browns', 'Cavaliers', 'Guardians'];

  ngOnInit(): void {
    this.loadAllRegionalSportsMetrics();
  }

  /**
   * Coordinates concurrent serverless network fetches across all three league targets.
   * Utilizes forkJoin to prevent rendering layout layout shifts.
   */
  private loadAllRegionalSportsMetrics(): void {
    this.loading = true;
    this.errorMessage = null;

    forkJoin({
      browns: this.apiService.getTeamStats('browns').pipe(catchError(err => of(null))),
      cavaliers: this.apiService.getTeamStats('cavaliers').pipe(catchError(err => of(null))),
      guardians: this.apiService.getTeamStats('guardians').pipe(catchError(err => of(null)))
    }).subscribe({
      next: (results) => {
        // Map successful responses into our snapshot lookup dictionary
        if (results.browns) this.teamSnapshots['BROWNS'] = results.browns;
        if (results.cavaliers) this.teamSnapshots['CAVALIERS'] = results.cavaliers;
        if (results.guardians) this.teamSnapshots['GUARDIANS'] = results.guardians;

        // Extract probabilities directly for our dynamic chart-card configuration
        this.aggregateWinProbabilities = [
          results.browns?.WinProbability ?? 0.50,
          results.cavaliers?.WinProbability ?? 0.50,
          results.guardians?.WinProbability ?? 0.50
        ];

        this.loading = false;
      },
      error: (err) => {
        this.errorMessage = 'Critical error orchestrating regional sports metrics.';
        this.loading = false;
      }
    });
  }

  /**
   * Pure formatting utility to resolve human-readable record indicators.
   */
  public formatRecord(teamKey: string): string {
    const data = this.teamSnapshots[teamKey];
    if (!data || !data.CurrentRecord) return 'N/A';
    return `${data.CurrentRecord.wins} - ${data.CurrentRecord.losses}`;
  }
}