import { Component, OnInit, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'the-future',
  standalone: true,
  imports: [], // Make sure HttpClientModule/provideHttpClient() is configured in your app config!
  templateUrl: './the-future.component.html',
  styleUrl: './the-future.component.scss'
})
export class TheFutureComponent implements OnInit {
  private http = inject(HttpClient);
  
  imagePath = 'assets/shedure.jpg';
  isLoading = true;

  // The counter starts displayValue at 0 and counts up to 'value'
  headlineStats = [
    { label: 'Pass Yds', value: 0, displayValue: 0 },
    { label: 'TD', value: 0, displayValue: 0 },
    { label: 'Comp %', value: 0, displayValue: 0 }
  ];

  ngOnInit() {
    this.fetchLiveStats();
  }

  fetchLiveStats() {
    // Replace this with your actual AWS API Gateway Invoke URL
    const apiUrl = 'https://ul9l90ngkj.execute-api.us-east-2.amazonaws.com/shedeurStats';

    this.http.get<any>(apiUrl).subscribe({
      next: (data) => {
        // Parse ESPN's deep JSON payload structure safely
        const passingCategory = data?.categories?.find((cat: any) => cat.name === 'passing');
        
        // Find specific target metrics from ESPN's array
        const yards = passingCategory?.stats?.find((s: any) => s.name === 'passingYards')?.value ?? 1400;
        const tds = passingCategory?.stats?.find((s: any) => s.name === 'passingTouchdowns')?.value ?? 7;
        const compPct = passingCategory?.stats?.find((s: any) => s.name === 'completionPercentage')?.value ?? 56.6;

        // Assign the fresh real-time values to the targets
        this.headlineStats[0].value = yards;
        this.headlineStats[1].value = tds;
        this.headlineStats[2].value = compPct;

        this.isLoading = false;
        this.animateStats(); // Run your counter animation now that data has arrived!
      },
      error: (err) => {
        console.error('Could not fetch data from Lambda:', err);
        // Fallback gracefully so the animation doesn't break if your backend is offline
        this.headlineStats[0].value = 1400;
        this.headlineStats[1].value = 7;
        this.headlineStats[2].value = 56.6;
        
        this.isLoading = false;
        this.animateStats();
      }
    });
  }

  animateStats() {
    this.headlineStats.forEach(stat => {
      const duration = 1200;
      const steps = 60;
      const increment = stat.value / steps;

      let current = 0;
      let i = 0;

      const timer = setInterval(() => {
        i++;
        current += increment;

        if (i >= steps) {
          stat.displayValue = stat.value;
          clearInterval(timer);
        } else {
          stat.displayValue =
            typeof stat.value === 'number' && stat.value % 1 !== 0
              ? parseFloat(current.toFixed(1))
              : Math.floor(current);
        }
      }, duration / steps);
    });
  }
}