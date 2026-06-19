import { Component, HostListener, signal } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-nav', standalone: true, imports: [RouterLink, RouterLinkActive, CommonModule],
  template: `
<nav class="nav" [class.scrolled]="scrolled()">
  <div class="ni">
    <div class="logo"><span class="lt">BROWNS</span><span class="ld"></span><span class="ly">1946</span></div>    <button class="hb" (click)="m.set(!m())" [attr.aria-expanded]="m()"><span></span><span></span><span></span></button>
    <ul class="nl" [class.open]="m()">
      <li><a routerLink="/home" routerLinkActive="active" (click)="m.set(false)">Home</a></li>
      <li><a routerLink="/the-good" routerLinkActive="active" class="good" (click)="m.set(false)">The Good</a></li>
      <li><a routerLink="/the-bad" routerLinkActive="active" class="bad" (click)="m.set(false)">The Bad</a></li>
      <li><a routerLink="/the-ugly" routerLinkActive="active" class="ugly" (click)="m.set(false)">The Ugly</a></li>
      <li><a routerLink="/the-future" routerLinkActive="active" class="ugly" (click)="m.set(false)">The Future</a></li>
    </ul>
  </div>
</nav>`,
  styles: [`
.nav{position:fixed;top:0;left:0;right:0;z-index:100;height:64px;background:transparent;transition:background .3s,border-bottom .3s}
.nav.scrolled{background:rgba(0, 0, 0, 0.96);border-bottom:1px solid rgba(255,60,0,.15);backdrop-filter:blur(12px)}
.ni{max-width:1280px;margin:0 auto;padding:0 24px;height:100%;display:flex;align-items:center;justify-content:space-between}
.logo{display:flex;align-items:center;gap:8px;text-decoration:none}
.lt{font-family:'Bebas Neue',sans-serif;font-size:1.5rem;letter-spacing:.1em;color: #FF3C00 !important;}.ld{width:6px;height:6px;background:var(--cream);border-radius:50%;opacity:.4}
.ly{font-family:'Roboto Mono',monospace;font-size:.65rem;color:var(--text-muted);letter-spacing:.1em}
.nl{display:flex;list-style:none;gap:2px}
.nl a{display:block;padding:8px 16px;text-decoration:none;font-size:.8rem;font-weight:600;letter-spacing:.1em;text-transform:uppercase;color:var(--text-muted);border-radius:3px;transition:color .2s,background .2s}
.nl a:hover,.nl a.active{color:var(--cream);background:rgba(245,237,215,.06)}
.nl a.good.active{color:#4CAF50} .nl a.bad.active{color:#FF9800} .nl a.ugly.active{color:var(--orange)}
.hb{display:none;flex-direction:column;gap:5px;background:none;border:none;cursor:pointer;padding:8px}
.hb span{display:block;width:22px;height:2px;background:var(--cream);transition:transform .2s}
@media(max-width:640px){
  .hb{display:flex}
  .nl{display:none;position:fixed;top:64px;left:0;right:0;background:rgba(26,18,9,.98);flex-direction:column;padding:16px 24px 24px;border-bottom:1px solid var(--border);gap:4px}
  .nl.open{display:flex} .nl a{padding:12px 16px;font-size:.9rem}
}`]
})
export class NavComponent {
  scrolled = signal(false); 
  m = signal(false); // Controls mobile menu menu state

  @HostListener('window:scroll') 
  onScroll() { 
    this.scrolled.set(window.scrollY > 20); 
  }

  // FIXED: Cleaner state handler for updating the menu signal
  toggleMenu() {
    this.m.update(currentState => !currentState);
  }
}
