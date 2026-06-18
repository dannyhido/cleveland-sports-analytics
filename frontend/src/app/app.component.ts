import { Component, inject } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { SharedModule } from './shared/shared.module';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterModule, SharedModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  private router = inject(Router);

  // Structural navigation link descriptors mapped directly to our application routing table
  public navItems = [
    { label: 'Overview Dashboard', route: '/dashboard', icon: 'dashboard' },
    { label: 'Cleveland Browns', route: '/team/browns', icon: 'sports_football' },
    { label: 'Cleveland Cavaliers', route: '/team/cavaliers', icon: 'sports_basketball' },
    { label: 'Cleveland Guardians', route: '/team/guardians', icon: 'sports_baseball' },
    { label: 'ML Predictions', route: '/predictions', icon: 'psychology' }
  ];

  /**
   * Evaluates if a navigation link matches the current browser location 
   * to apply active theme highlights.
   */
  public isRouteActive(routeUrl: string): boolean {
    return this.router.url === routeUrl;
  }
}