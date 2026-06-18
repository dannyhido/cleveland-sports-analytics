import { RenderMode, ServerRoute } from '@angular/ssr';

export const serverRoutes: ServerRoute[] = [
  { path: '', renderMode: RenderMode.Prerender },
  { path: 'home', renderMode: RenderMode.Prerender },
  { path: 'the-good', renderMode: RenderMode.Prerender },
  { path: 'the-bad', renderMode: RenderMode.Prerender },
  { path: 'the-ugly', renderMode: RenderMode.Prerender },
  { path: '**', renderMode: RenderMode.Server },
];
