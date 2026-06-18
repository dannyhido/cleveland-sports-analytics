import { RenderMode, ServerRoute } from '@angular/ssr';

export const serverRoutes: ServerRoute[] = [
  { path: '', renderMode: RenderMode.Prerender },
  { path: 'dashboard', renderMode: RenderMode.Prerender },
  { path: 'predictions', renderMode: RenderMode.Prerender },
  {
    path: 'team/:teamId',
    renderMode: RenderMode.Prerender,
    getPrerenderParams: async () => [
      { teamId: 'browns' },
      { teamId: 'cavaliers' },
      { teamId: 'guardians' },
    ],
  },
  { path: '**', renderMode: RenderMode.Prerender },
];
