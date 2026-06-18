import { Component, Input, ElementRef, ViewChild, AfterViewInit, OnChanges, SimpleChanges } from '@angular/core';
import { SharedModule } from '../../shared.module';

@Component({
  selector: 'app-chart-card',
  standalone: true,
  imports: [SharedModule],
  templateUrl: './chart-card.component.html',
  styleUrls: ['./chart-card.component.scss']
})
export class ChartCardComponent implements AfterViewInit, OnChanges {
  @Input() title: string = 'Analytics Trend';
  @Input() subtitle: string = 'Data visualization metric';
  @Input() loading: boolean = false;
  
  // High-level normalized data array passed down from feature dashboards
  @Input() dataPoints: number[] = [];
  @Input() labels: string[] = [];

  // References the specific canvas element in the DOM template securely
  @ViewChild('chartCanvas') chartCanvas!: ElementRef<HTMLCanvasElement>;
  
  private ctx!: CanvasRenderingContext2D | null;

  ngAfterViewInit(): void {
    this.initializeCanvasContext();
    this.renderCustomChartVisual();
  }

  ngOnChanges(changes: SimpleChanges): void {
    // If the team data changes (e.g. switching teams), re-draw the visualization elements
    if ((changes['dataPoints'] || changes['labels']) && !changes['dataPoints']?.isFirstChange()) {
      this.renderCustomChartVisual();
    }
  }

  private initializeCanvasContext(): void {
    if (this.chartCanvas) {
      this.ctx = this.chartCanvas.nativeElement.getContext('2d');
    }
  }

  /**
   * Lightweight rendering pipeline layout. 
   * Provides a baseline placeholder draw frame that scales dynamically before 
   * plugging in massive heavy external plotting engines.
   */
  private renderCustomChartVisual(): void {
    if (!this.ctx || this.dataPoints.length === 0) return;

    const canvas = this.chartCanvas.nativeElement;
    const width = canvas.width;
    const height = canvas.height;

    // Clear previous drawing frames cleanly
    this.ctx.clearRect(0, 0, width, height);

    // Draw baseline visual gradient structure indicator
    this.ctx.fillStyle = '#f5f5f5';
    this.ctx.fillRect(0, 0, width, height);

    // Simple line trace layout logic representing raw mathematical trend values
    this.ctx.beginPath();
    this.ctx.strokeStyle = '#3f51b5'; // Primary Material Indigo theme hex indicator
    this.ctx.lineWidth = 3;

    const margin = 20;
    const step = (width - margin * 2) / (this.dataPoints.length - 1 || 1);
    const maxVal = Math.max(...this.dataPoints, 1);

    this.dataPoints.forEach((val, index) => {
      const x = margin + index * step;
      const y = height - margin - ((val / maxVal) * (height - margin * 2));
      
      if (index === 0) {
        this.ctx?.moveTo(x, y);
      } else {
        this.ctx?.lineTo(x, y);
      }
    });

    this.ctx.stroke();
  }
}