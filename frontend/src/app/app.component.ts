import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { NavComponent } from './shared/nav/nav.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NavComponent],
  template: `<app-nav></app-nav><main style="padding-top:64px;min-height:100vh"><router-outlet></router-outlet></main>`
})
export class AppComponent {}
