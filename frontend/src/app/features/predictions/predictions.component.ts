import { Component, OnInit, inject } from '@angular/core';
import { forkJoin, catchError, of } from 'rxjs';
import { ApiService } from '../../core/http/api.service';
import { PredictionResponse } from '../../core/models/sports-data.model';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-predictions',
  standalone: true,
  imports: [SharedModule],
  templateUrl: './predictions.component.html',
  styleUrls: ['./predictions.component.scss']
})
export class PredictionsComponent implements OnInit {
  private apiService = inject(ApiService);

  public loading: boolean = true;
  public errorMessage: string | null = null;
  
  // Array tracking all parsed predictive models returning from the AWS backend
  public modelPredictions: PredictionResponse[] = [];

  // Table columns definition configuration for our Angular Material metrics matrix
  public displayedColumns: string[] = ['factor', 'impact'];

  ngOnInit(): void {
    this.loadAllAlgorithmicPredictions();
  }

  /**
   * Concurrently pulls downstream analytical ML weights from serverless partitions.
   */
  private loadAllAlgorithmicPredictions(): void {
    this.loading = true;
    this.errorMessage = null;

    forkJoin({
      browns: this.apiService.getPredictionData('browns').pipe(catchError(() => of(null))),
      cavaliers: this.apiService.getPredictionData('cavaliers').pipe(catchError(() => of(null))),
      guardians: this.apiService.getPredictionData('guardians').pipe(catchError(() => of(null)))
    }).subscribe({
      next: (results) => {
        const models: PredictionResponse[] = [];
        if (results.browns) models.push(results.browns);
        if (results.cavaliers) models.push(results.cavaliers);
        if (results.guardians) models.push(results.guardians);

        this.modelPredictions = models;
        this.loading = false;
      },
      error: (err) => {
        this.errorMessage = 'Failed to parse ML modeling parameters out of cloud compute zones.';
        this.loading = false;
      }
    });
  }

  /**
   * Helper utility calculating semantic coloring configurations for percentage outputs.
   */
  public getProbabilityColor(probability: number): string {
    if (probability >= 0.60) return '#4caf50'; // Confident Advantage
    if (probability <= 0.40) return '#f44336'; // Disadvantage
    return '#ff9800'; // Toss-up Variance
  }
}