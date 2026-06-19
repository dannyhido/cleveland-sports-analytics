import { Routes } from '@angular/router';
export const routes: Routes = [
  { path: '', redirectTo: '/home', pathMatch: 'full' },
  
  { path: 'the-good', loadComponent: () => import('./features/the-good/the-good.component').then(m => m.TheGoodComponent) },
  { path: 'the-bad', loadComponent: () => import('./features/the-bad/the-bad.component').then(m => m.TheBadComponent) },
  { path: 'the-ugly', loadComponent: () => import('./features/the-ugly/the-ugly.component').then(m => m.TheUglyComponent) },
  { path: 'the-future', loadComponent: () => import('./features/the-future/the-future.component').then(m => m.TheFutureComponent) },
  { path: 'home', loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent) },
  { path: '**', redirectTo: '/home' }

];
