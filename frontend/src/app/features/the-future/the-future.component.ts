import { Component } from '@angular/core';
 
@Component({
  selector: 'the-future',
  standalone: true,
  templateUrl: './the-future.component.html',
  styleUrl: './the-future.component.scss'
})
export class TheFutureComponent {
  // Swap in your real image path here
  imagePath = 'assets/shedure.jpg';
 
  // TODO: replace with verified 1st season stats
  headlineStats = [
    { label: 'Pass Yds', value: '0,000' },
    { label: 'TD', value: '00' },
    { label: 'Comp %', value: '00.0' }
  ];
}