import { Routes } from '@angular/router';

export const routes: Routes = [
  // 1. Default Route - Redirects instantly to the main overview dashboard panel
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full'
  },

  // 2. Main Analytics Dashboard Feature (Lazy Loaded)
  {
    path: 'dashboard',
    loadComponent: () => 
      import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent),
    title: 'Cleveland Sports Hub - Overview'
  },

  // 3. Dynamic Individual Team Analytic View Feature (Lazy Loaded)
  // Handles /team/browns, /team/cavaliers, /team/guardians via route parameter tokens
  {
    path: 'team/:teamId',
    loadComponent: () => 
      import('./features/team-detail/team-detail.component').then(m => m.TeamDetailComponent),
    title: 'Cleveland Sports Hub - Team Analytics'
  },

  // 4. ML Matchup Predictions Feature (Lazy Loaded)
  {
    path: 'predictions',
    loadComponent: () => 
      import('./features/predictions/predictions.component').then(m => m.PredictionsComponent),
    title: 'Cleveland Sports Hub - Predictive Machine Learning'
  },

  // 5. Wildcard Fallback Route - Handles 404 navigation gracefully
  {
    path: '**',
    redirectTo: 'dashboard'
  }
];