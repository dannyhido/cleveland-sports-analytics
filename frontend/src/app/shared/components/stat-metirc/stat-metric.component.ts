import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';

@Component({
  selector: 'app-stat-metric',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatIconModule,
    MatTooltipModule
  ],
  templateUrl: './stat-metric.component.html',
  styleUrls: ['./stat-metric.component.scss']
})
export class StatMetricComponent {
  @Input() label = '';
  @Input() value = '';
  @Input() description = '';
  @Input() trend: 'Positive' | 'Negative' | 'Neutral' = 'Neutral';

  get trendClass(): string {
    return `trend-${this.trend.toLowerCase()}`;
  }

  get trendIcon(): string {
    switch (this.trend) {
      case 'Positive': return 'trending_up';
      case 'Negative': return 'trending_down';
      default: return 'trending_flat';
    }
  }
}