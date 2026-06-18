import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiService } from '../../core/http/api.service';
import { TeamStatsResponse } from '../../core/models/sports-data.model';
import { SharedModule } from '../../shared/shared.module';
import { StatMetricComponent } from '../../shared/components/stat-metirc/stat-metric.component';
import { ChartCardComponent } from '../../shared/components/chart-card/chart-card.component';

@Component({
  selector: 'app-team-detail',
  standalone: true,
  imports: [SharedModule, StatMetricComponent, ChartCardComponent],
  templateUrl: './team-detail.component.html',
  styleUrls: ['./team-detail.component.scss']
})
export class TeamDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private apiService = inject(ApiService);

  public loading: boolean = true;
  public errorMessage: string | null = null;
  public teamData: TeamStatsResponse | null = null;
  public teamId: string = '';

  // Chart data bindings
  public chartData: number[] = [];
  public chartLabels: string[] = [];

  ngOnInit(): void {
    // Watch the active URL parameters for modifications
    this.route.paramMap.subscribe(params => {
      const id = params.get('teamId');
      if (id) {
        this.teamId = id.toUpperCase();
        this.loadSpecificTeamMetrics(id as 'browns' | 'cavaliers' | 'guardians');
      }
    });
  }

  private loadSpecificTeamMetrics(id: 'browns' | 'cavaliers' | 'guardians'): void {
    this.loading = true;
    this.errorMessage = null;

    this.apiService.getTeamStats(id).subscribe({
      next: (data) => {
        this.teamData = data;
        
        // Populate historical metrics for our reusable line graph component
        // Pulling historical data or generating trend steps from our records
        this.chartData = data.RecentGames?.map((_, idx) => (data.CurrentRecord?.wins || 5) - idx) || [5, 6, 7];
        this.chartLabels = data.RecentGames?.map(g => g.opponent) || ['Game 1', 'Game 2', 'Game 3'];
        
        this.loading = false;
      },
      error: () => {
        this.errorMessage = `Could not load analytic datasets for the Cleveland ${this.teamId}.`;
        this.loading = false;
      }
    });
  }
}