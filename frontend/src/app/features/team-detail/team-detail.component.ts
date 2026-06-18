import { Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiService } from '../../core/http/api.service';
import { TeamStatsResponse } from '../../core/models/sports-data.model';
import { SharedModule } from '../../shared/shared.module';
import { StatMetricComponent } from '../../shared/components/stat-metric/stat-metric.component';
import { ChartCardComponent } from '../../shared/components/chart-card/chart-card.component';
import { switchMap, map, catchError, of, tap } from 'rxjs';

type TeamId = 'browns' | 'cavaliers' | 'guardians';

function isValidTeamId(id: string): id is TeamId {
  return ['browns', 'cavaliers', 'guardians'].includes(id);
}

@Component({
  selector: 'app-team-detail',
  standalone: true,
  imports: [SharedModule, StatMetricComponent, ChartCardComponent],
  templateUrl: './team-detail.component.html',
  styleUrls: ['./team-detail.component.scss']
})
export class TeamDetailComponent {

  private route = inject(ActivatedRoute);
  private apiService = inject(ApiService);

  public errorMessage: string | null = null;
  public teamId: TeamId | null = null;

  public teamData$ = this.route.paramMap.pipe(
    map(params => params.get('teamId') ?? ''),
    map(id => {
      if (!isValidTeamId(id)) {
        throw new Error('Invalid team id');
      }
      this.teamId = id;
      return id;
    }),
    switchMap(teamId =>
      this.apiService.getTeamStats(teamId).pipe(
        tap(() => this.errorMessage = null),
        catchError(err => {
          this.errorMessage = 'Failed to load team data';
          return of(null);
        })
      )
    )
  );

  public chartData: number[] = [];
  public chartLabels: string[] = [];
}