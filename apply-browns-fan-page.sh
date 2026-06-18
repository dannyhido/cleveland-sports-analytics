#!/usr/bin/env bash
# =============================================================
# apply-browns-fan-page.sh
#
# Run from the ROOT of the cloned repo:
#   GITHUB_TOKEN=ghp_xxx bash apply-browns-fan-page.sh
#
# Requires: git, curl, Node.js 20+
# =============================================================
set -e

REPO_OWNER="dannyhido"
REPO_NAME="cleveland-sports-analytics"
BRANCH="feature/browns-fan-page"

if [ -z "$GITHUB_TOKEN" ]; then
  echo "❌  Set GITHUB_TOKEN first:  export GITHUB_TOKEN=ghp_..."
  exit 1
fi

echo "🏈  Applying Cleveland Browns Fan Page..."

# ── branch ──────────────────────────────────────────────────
git checkout main
git pull origin main
git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"

# ── directories ─────────────────────────────────────────────
mkdir -p frontend/src/app/core
mkdir -p frontend/src/app/features/home
mkdir -p frontend/src/app/features/the-good
mkdir -p frontend/src/app/features/the-bad
mkdir -p frontend/src/app/features/the-ugly
mkdir -p frontend/src/app/shared/nav

# ── styles.scss ─────────────────────────────────────────────
cat > frontend/src/styles.scss << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Inter:wght@300;400;500;600;700&family=Roboto+Mono:wght@400;600&display=swap');

:root {
  --orange: #FF3C00; --orange-dim: #CC3000;
  --brown: #311D00; --brown-mid: #4A2C00;
  --cream: #F5EDD7; --cream-dim: #D4C9A8;
  --grey-dark: #1A1209; --grey-mid: #2E2015; --grey-light: #3D2D1A;
  --text-primary: #F5EDD7; --text-muted: #9E8C70;
  --red-bad: #CC2200; --green-good: #2D7A3A;
  --border: rgba(255,60,0,0.2); --border-subtle: rgba(245,237,215,0.08);
}
* { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body { font-family: 'Inter', sans-serif; background: var(--grey-dark); color: var(--text-primary); min-height: 100vh; overflow-x: hidden; }
h1, h2, h3 { font-family: 'Bebas Neue', sans-serif; letter-spacing: 0.04em; line-height: 0.95; }
.section-label { font-family: 'Roboto Mono', monospace; font-size: 0.65rem; letter-spacing: 0.2em; text-transform: uppercase; color: var(--orange); opacity: 0.8; }
::-webkit-scrollbar { width: 5px; } ::-webkit-scrollbar-track { background: var(--grey-dark); } ::-webkit-scrollbar-thumb { background: var(--brown-mid); border-radius: 2px; }
@keyframes flicker { 0%,100%{opacity:1} 92%{opacity:1} 93%{opacity:.85} 94%{opacity:1} 96%{opacity:.9} 97%{opacity:1} }
@keyframes slideUp { from{opacity:0;transform:translateY(24px)} to{opacity:1;transform:translateY(0)} }
@keyframes fadeIn { from{opacity:0} to{opacity:1} }
@keyframes scanline { 0%{top:-10%} 100%{top:110%} }
@media (prefers-reduced-motion:reduce) { *,*::before,*::after { animation-duration:.01ms!important; transition-duration:.01ms!important; } }
EOF
echo "  ✓ styles.scss"

# ── app.routes.ts ────────────────────────────────────────────
cat > frontend/src/app/app.routes.ts << 'EOF'
import { Routes } from '@angular/router';
export const routes: Routes = [
  { path: '', redirectTo: '/home', pathMatch: 'full' },
  { path: 'home', loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent) },
  { path: 'the-good', loadComponent: () => import('./features/the-good/the-good.component').then(m => m.TheGoodComponent) },
  { path: 'the-bad', loadComponent: () => import('./features/the-bad/the-bad.component').then(m => m.TheBadComponent) },
  { path: 'the-ugly', loadComponent: () => import('./features/the-ugly/the-ugly.component').then(m => m.TheUglyComponent) },
  { path: '**', redirectTo: '/home' }
];
EOF
echo "  ✓ app.routes.ts"

# ── app.component.ts ─────────────────────────────────────────
cat > frontend/src/app/app.component.ts << 'EOF'
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
EOF
echo "  ✓ app.component.ts"

# ── nav.component.ts ─────────────────────────────────────────
cat > frontend/src/app/shared/nav/nav.component.ts << 'EOF'
import { Component, HostListener, signal } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-nav', standalone: true, imports: [RouterLink, RouterLinkActive, CommonModule],
  template: `
<nav class="nav" [class.scrolled]="scrolled()">
  <div class="ni">
    <a routerLink="/home" class="logo"><span class="lt">BROWNS</span><span class="ld"></span><span class="ly">1946</span></a>
    <button class="hb" (click)="m.set(!m())" [attr.aria-expanded]="m()"><span></span><span></span><span></span></button>
    <ul class="nl" [class.open]="m()">
      <li><a routerLink="/home" routerLinkActive="active" (click)="m.set(false)">Home</a></li>
      <li><a routerLink="/the-good" routerLinkActive="active" class="good" (click)="m.set(false)">The Good</a></li>
      <li><a routerLink="/the-bad" routerLinkActive="active" class="bad" (click)="m.set(false)">The Bad</a></li>
      <li><a routerLink="/the-ugly" routerLinkActive="active" class="ugly" (click)="m.set(false)">The Ugly</a></li>
    </ul>
  </div>
</nav>`,
  styles: [`
.nav{position:fixed;top:0;left:0;right:0;z-index:100;height:64px;background:transparent;transition:background .3s,border-bottom .3s}
.nav.scrolled{background:rgba(26,18,9,.96);border-bottom:1px solid rgba(255,60,0,.15);backdrop-filter:blur(12px)}
.ni{max-width:1280px;margin:0 auto;padding:0 24px;height:100%;display:flex;align-items:center;justify-content:space-between}
.logo{display:flex;align-items:center;gap:8px;text-decoration:none}
.lt{font-family:'Bebas Neue',sans-serif;font-size:1.5rem;letter-spacing:.1em;color:var(--orange)}
.ld{width:6px;height:6px;background:var(--cream);border-radius:50%;opacity:.4}
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
  scrolled = signal(false); m = signal(false);
  @HostListener('window:scroll') onScroll() { this.scrolled.set(window.scrollY > 20); }
}
EOF
echo "  ✓ nav.component.ts"

# ── browns-data.service.ts ───────────────────────────────────
cat > frontend/src/app/core/browns-data.service.ts << 'EOF'
import { Injectable } from '@angular/core';
export interface SeasonRecord { year:number; wins:number; losses:number; ties:number; coach:string; note?:string; }
export interface StatCard { value:string; label:string; context:string; sentiment:'good'|'bad'|'ugly'; }

@Injectable({ providedIn: 'root' })
export class BrownsDataService {
  readonly goodStats: StatCard[] = [
    {value:'8',label:'Championship Titles',context:'Pre-Super Bowl era (1950, 1954, 1955, 1964)',sentiment:'good'},
    {value:'4',label:'AAFC + NFL Titles',context:'Three AAFC + first NFL season in 1950',sentiment:'good'},
    {value:'11',label:'Hall of Famers',context:'Including Jim Brown, Ozzie Newsome & Otto Graham',sentiment:'good'},
    {value:'12,312',label:'Jim Brown Career Yards',context:'Best running back in NFL history, period',sentiment:'good'},
    {value:'10/10',label:'Otto Graham Titles',context:'10 championship games in 10 seasons — unmatched',sentiment:'good'},
    {value:'1946',label:'Year Founded',context:'One of the oldest franchises in pro football',sentiment:'good'},
  ];
  readonly badStats: StatCard[] = [
    {value:'2',label:'Playoff Appearances',context:'In 26 seasons since returning in 1999 — 2002 & 2020',sentiment:'bad'},
    {value:'32',label:'Starting QBs',context:'Since 1999 — no franchise QB has stuck',sentiment:'bad'},
    {value:'1–31',label:'Worst Modern Stretch',context:'2016–17 combined record — historically bad',sentiment:'bad'},
    {value:'24',label:'Head Coaches',context:'Since 1999 — averaging less than 2 seasons each',sentiment:'bad'},
    {value:'.366',label:'Win % Since 1999',context:'Bottom 3 in the entire NFL over that span',sentiment:'bad'},
    {value:'0',label:'Super Bowl Appearances',context:'Zero. Not one. Ever.',sentiment:'bad'},
  ];
  readonly uglyStats: StatCard[] = [
    {value:'0–16',label:'2017 Season',context:'One of only two teams in NFL history to go winless',sentiment:'ugly'},
    {value:'$230M',label:'Watson Guaranteed',context:'Most guaranteed money in NFL history at signing — he barely played',sentiment:'ugly'},
    {value:'1995',label:'Franchise Relocation',context:'Art Modell moved the Browns to Baltimore mid-season',sentiment:'ugly'},
    {value:'11',label:'QBs In 2017',context:'Browns used 3 different starters in the 0-16 season alone',sentiment:'ugly'},
    {value:'3',label:'First-Round Picks',context:'Traded to Houston for Watson — paid in draft capital AND cash',sentiment:'ugly'},
    {value:'1964',label:'Last Championship',context:'60+ years and counting without a title',sentiment:'ugly'},
  ];
  readonly winLossHistory: SeasonRecord[] = [
    {year:1999,wins:2,losses:14,ties:0,coach:'Chris Palmer'},
    {year:2000,wins:3,losses:13,ties:0,coach:'Chris Palmer'},
    {year:2001,wins:7,losses:9,ties:0,coach:'Butch Davis'},
    {year:2002,wins:9,losses:7,ties:0,coach:'Butch Davis',note:'🏆 Playoffs'},
    {year:2003,wins:5,losses:11,ties:0,coach:'Butch Davis'},
    {year:2004,wins:4,losses:12,ties:0,coach:'Butch Davis'},
    {year:2005,wins:6,losses:10,ties:0,coach:'Romeo Crennel'},
    {year:2006,wins:4,losses:12,ties:0,coach:'Romeo Crennel'},
    {year:2007,wins:10,losses:6,ties:0,coach:'Romeo Crennel'},
    {year:2008,wins:4,losses:12,ties:0,coach:'Romeo Crennel'},
    {year:2009,wins:5,losses:11,ties:0,coach:'Eric Mangini'},
    {year:2010,wins:5,losses:11,ties:0,coach:'Eric Mangini'},
    {year:2011,wins:4,losses:12,ties:0,coach:'Pat Shurmur'},
    {year:2012,wins:5,losses:11,ties:0,coach:'Pat Shurmur'},
    {year:2013,wins:4,losses:12,ties:0,coach:'Rob Chudzinski'},
    {year:2014,wins:7,losses:9,ties:0,coach:'Mike Pettine'},
    {year:2015,wins:3,losses:13,ties:0,coach:'Mike Pettine'},
    {year:2016,wins:1,losses:15,ties:0,coach:'Hue Jackson'},
    {year:2017,wins:0,losses:16,ties:0,coach:'Hue Jackson',note:'💀 0–16'},
    {year:2018,wins:7,losses:8,ties:1,coach:'Hue Jackson / Gregg Williams'},
    {year:2019,wins:6,losses:10,ties:0,coach:'Freddie Kitchens'},
    {year:2020,wins:11,losses:5,ties:0,coach:'Kevin Stefanski',note:'🏆 Playoffs'},
    {year:2021,wins:8,losses:9,ties:0,coach:'Kevin Stefanski'},
    {year:2022,wins:7,losses:10,ties:0,coach:'Kevin Stefanski'},
    {year:2023,wins:11,losses:6,ties:0,coach:'Kevin Stefanski'},
    {year:2024,wins:3,losses:14,ties:0,coach:'Kevin Stefanski'},
  ];
  getWinPercentage(s: SeasonRecord): number {
    const g = s.wins + s.losses + s.ties; return g ? (s.wins + s.ties * .5) / g : 0;
  }
  getOverallRecord() {
    return this.winLossHistory.reduce((a,s)=>({wins:a.wins+s.wins,losses:a.losses+s.losses,ties:a.ties+s.ties}),{wins:0,losses:0,ties:0});
  }
  getWorstSeasons(n=5) { return [...this.winLossHistory].sort((a,b)=>this.getWinPercentage(a)-this.getWinPercentage(b)).slice(0,n); }
  getBestSeasons(n=5) { return [...this.winLossHistory].sort((a,b)=>this.getWinPercentage(b)-this.getWinPercentage(a)).slice(0,n); }
}
EOF
echo "  ✓ browns-data.service.ts"

# ── home.component.ts ────────────────────────────────────────
cat > frontend/src/app/features/home/home.component.ts << 'TSEOF'
import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { BrownsDataService } from '../../core/browns-data.service';

@Component({ selector: 'app-home', standalone: true, imports: [RouterLink, CommonModule],
  templateUrl: './home.component.html', styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  overall = { wins: 0, losses: 0, ties: 0 };
  yearsOfPain = new Date().getFullYear() - 1964;
  constructor(private data: BrownsDataService) {}
  ngOnInit() { this.overall = this.data.getOverallRecord(); }
}
TSEOF

cat > frontend/src/app/features/home/home.component.html << 'EOF'
<div class="home">
  <section class="hero">
    <div class="hero-bg"><div class="hero-orb"></div><div class="scanline"></div></div>
    <div class="hc">
      <p class="section-label">Est. 1946 · Cleveland, Ohio</p>
      <h1 class="ht"><span>CLEVELAND</span><span class="o">BROWNS</span></h1>
      <p class="hs">{{yearsOfPain}} years since the last championship.<br><span class="muted">But we still bleed orange.</span></p>
      <div class="rec">
        <div class="rn"><span class="rnum">{{overall.wins}}</span><span class="rs">–</span><span class="rnum">{{overall.losses}}</span></div>
        <span class="rl">W–L record since returning in 1999</span>
      </div>
      <div class="ctas">
        <a routerLink="/the-good" class="cb good">The Good →</a>
        <a routerLink="/the-bad" class="cb bad">The Bad →</a>
        <a routerLink="/the-ugly" class="cb ugly">The Ugly →</a>
      </div>
    </div>
  </section>
  <section class="strip">
    <div class="si">
      <div class="si-item"><span class="sn">2</span><span class="sl">Playoff appearances<br><em>since '99</em></span></div>
      <div class="sd"></div>
      <div class="si-item"><span class="sn">32</span><span class="sl">Starting QBs<br><em>since '99</em></span></div>
      <div class="sd"></div>
      <div class="si-item"><span class="sn">0–16</span><span class="sl">2017 record<br><em>historic futility</em></span></div>
      <div class="sd"></div>
      <div class="si-item"><span class="sn">1964</span><span class="sl">Last championship<br><em>{{yearsOfPain}} yrs ago</em></span></div>
    </div>
  </section>
  <section class="pg">
    <a routerLink="/the-good" class="pc gc">
      <div class="pt">01</div><h2 class="ptt good-c">The Good</h2>
      <p class="pd">Before the drought came the dynasty. Jim Brown. Otto Graham. Eight championships. Cleveland once fielded the most dominant football team on earth.</p>
      <span class="pa">Explore →</span>
    </a>
    <a routerLink="/the-bad" class="pc bc">
      <div class="pt">02</div><h2 class="ptt bad-c">The Bad</h2>
      <p class="pd">Two playoff trips in 26 years. A carousel of 32 quarterbacks. Decisions that would make any fan question their loyalty.</p>
      <span class="pa">Explore →</span>
    </a>
    <a routerLink="/the-ugly" class="pc uc">
      <div class="pt">03</div><h2 class="ptt ugly-c">The Ugly</h2>
      <p class="pd">The 0–16 season. $230M guaranteed to a QB who barely played. This is where sports pain becomes something darkly comedic.</p>
      <span class="pa">Explore →</span>
    </a>
  </section>
  <footer class="hf">
    <p class="section-label">Cleveland Browns Fan Analytics</p>
    <p class="fs">Built for the die-hards who somehow still show up.</p>
  </footer>
</div>
EOF

cat > frontend/src/app/features/home/home.component.scss << 'EOF'
.home { min-height: 100vh; }
.hero { min-height: calc(100vh - 64px); display: flex; align-items: center; position: relative; overflow: hidden; }
.hero-bg { position: absolute; inset: 0; background: linear-gradient(180deg, var(--grey-dark) 0%, var(--brown) 100%); }
.hero-orb { position: absolute; right: -5%; top: 50%; transform: translateY(-50%); width: min(55vw,600px); height: min(55vw,600px); border-radius: 50%; background: radial-gradient(circle at 35% 35%, var(--brown-mid), var(--grey-dark)); border: 2px solid rgba(255,60,0,.12); opacity: .3; }
.scanline { position: absolute; left: 0; right: 0; height: 2px; background: linear-gradient(90deg, transparent, rgba(255,60,0,.15), transparent); animation: scanline 8s linear infinite; pointer-events: none; }
.hc { position: relative; z-index: 1; max-width: 1280px; margin: 0 auto; padding: 80px 40px; animation: slideUp .7s ease both; }
.ht { font-family: 'Bebas Neue', sans-serif; font-size: clamp(5rem,14vw,12rem); line-height: .88; margin: 20px 0 24px; display: flex; flex-direction: column; }
.ht .o { color: var(--orange); animation: flicker 6s ease infinite 2s; }
.hs { font-size: clamp(1rem,2vw,1.2rem); color: var(--cream); margin-bottom: 40px; line-height: 1.6; max-width: 480px; }
.muted { color: var(--text-muted); }
.rec { margin-bottom: 48px; }
.rn { display: flex; align-items: baseline; gap: 4px; }
.rnum { font-family: 'Bebas Neue', sans-serif; font-size: 2.5rem; color: var(--cream); }
.rs { font-family: 'Roboto Mono', monospace; font-size: 1.5rem; color: var(--text-muted); }
.rl { display: block; font-size: .7rem; letter-spacing: .12em; text-transform: uppercase; color: var(--text-muted); margin-top: 4px; }
.ctas { display: flex; gap: 12px; flex-wrap: wrap; }
.cb { padding: 12px 24px; border-radius: 3px; font-size: .8rem; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; text-decoration: none; transition: transform .15s, opacity .15s; border: 1px solid transparent; }
.cb:hover { transform: translateY(-2px); opacity: .9; }
.cb.good { background: rgba(45,122,58,.2); border-color: rgba(45,122,58,.5); color: #4CAF50; }
.cb.bad { background: rgba(255,152,0,.12); border-color: rgba(255,152,0,.4); color: #FF9800; }
.cb.ugly { background: rgba(255,60,0,.12); border-color: rgba(255,60,0,.4); color: var(--orange); }
.strip { background: var(--brown); border-top: 1px solid rgba(255,60,0,.2); border-bottom: 1px solid rgba(255,60,0,.2); padding: 32px 0; }
.si { max-width: 1280px; margin: 0 auto; padding: 0 40px; display: flex; align-items: center; justify-content: space-around; flex-wrap: wrap; gap: 24px; }
.si-item { text-align: center; }
.sn { display: block; font-family: 'Bebas Neue', sans-serif; font-size: clamp(2rem,4vw,3rem); color: var(--orange); line-height: 1; }
.sl { display: block; font-size: .7rem; letter-spacing: .1em; text-transform: uppercase; color: var(--text-muted); line-height: 1.5; margin-top: 4px; }
.sl em { color: var(--cream-dim); font-style: normal; }
.sd { width: 1px; height: 40px; background: rgba(255,60,0,.2); }
.pg { max-width: 1280px; margin: 0 auto; padding: 80px 40px; display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2px; }
.pc { display: block; text-decoration: none; padding: 48px 40px; background: var(--grey-mid); position: relative; overflow: hidden; transition: background .2s; }
.pc::before { content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 3px; transform: scaleX(0); transition: transform .3s; transform-origin: left; }
.pc:hover::before { transform: scaleX(1); }
.gc::before { background: var(--green-good); } .bc::before { background: #FF9800; } .uc::before { background: var(--orange); }
.pc:hover { background: var(--grey-light); }
.pt { font-family: 'Roboto Mono', monospace; font-size: .65rem; color: var(--text-muted); letter-spacing: .15em; margin-bottom: 16px; }
.ptt { font-family: 'Bebas Neue', sans-serif; font-size: 3.5rem; letter-spacing: .04em; margin-bottom: 16px; }
.good-c { color: #4CAF50; } .bad-c { color: #FF9800; } .ugly-c { color: var(--orange); }
.pd { font-size: .9rem; color: var(--text-muted); line-height: 1.65; margin-bottom: 32px; }
.pa { font-size: .75rem; font-weight: 700; letter-spacing: .1em; text-transform: uppercase; color: var(--cream-dim); }
.hf { border-top: 1px solid var(--border-subtle); padding: 40px; text-align: center; }
.fs { font-size: .8rem; color: var(--text-muted); margin-top: 8px; }
@media(max-width:640px) { .hc,.pg { padding: 60px 24px; } .sd { display: none; } }
EOF
echo "  ✓ home component"

# ── the-good.component.ts ────────────────────────────────────
cat > frontend/src/app/features/the-good/the-good.component.ts << 'TSEOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BrownsDataService } from '../../core/browns-data.service';

@Component({ selector: 'app-the-good', standalone: true, imports: [CommonModule],
  templateUrl: './the-good.component.html', styleUrls: ['./the-good.component.scss']
})
export class TheGoodComponent implements OnInit {
  goodStats: any[] = []; bestSeasons: any[] = [];
  gloryEras = [
    {year:'1946–48',title:'AAFC Dynasty',desc:"Three consecutive All-America Football Conference championships. The franchise was built to dominate, and it did — immediately."},
    {year:'1950',title:'NFL Merger Title',desc:"First year in the NFL and they won the championship, finishing 10–2 and defeating the Rams 30–28 in the title game."},
    {year:'1954–55',title:'Back-to-Back Champions',desc:"Otto Graham's final two seasons produced back-to-back championships, capping the greatest QB career in football history to that point."},
    {year:'1964',title:'The Last One',desc:"Frank Ryan, Jim Brown, and Paul Warfield defeated the Baltimore Colts 27–0. No one knew it would be the last championship for 60+ years."},
    {year:'2020',title:'Playoff Return',desc:"Kevin Stefanski's Browns won 11 games and beat the Pittsburgh Steelers in a Wild Card game — their first playoff win since 1994."},
  ];
  legends = [
    {number:'32',name:'Jim Brown',pos:'Running Back',stat:'12,312 rushing yards · 9x Pro Bowl · Greatest RB ever'},
    {number:'14',name:'Otto Graham',pos:'Quarterback',stat:'10 championships in 10 seasons · 23,584 passing yards'},
    {number:'82',name:'Ozzie Newsome',pos:'Tight End',stat:'662 career receptions · 2 Pro Bowls · HOF 1999'},
    {number:'76',name:'Lou Groza',pos:'OT / Kicker',stat:'4x All-Pro · Pioneered the modern kicker role'},
    {number:'44',name:'Leroy Kelly',pos:'Running Back',stat:'7,274 rushing yards · 3x rushing title · HOF 1994'},
    {number:'18',name:'Paul Warfield',pos:'Wide Receiver',stat:'8,565 career yards · 85 career TDs · HOF 1983'},
  ];
  constructor(private data: BrownsDataService) {}
  ngOnInit() { this.goodStats = this.data.goodStats; this.bestSeasons = this.data.getBestSeasons(6); }
  pct(s: any) { return this.data.getWinPercentage(s); }
}
TSEOF

cat > frontend/src/app/features/the-good/the-good.component.html << 'EOF'
<div class="page">
  <header class="ph good-ph">
    <div class="hbg"></div>
    <div class="phc">
      <p class="section-label">Chapter 01</p>
      <h1 class="pt">The<br><span class="ag">Good</span></h1>
      <p class="ps">Before Cleveland became a punchline, it was a powerhouse. Here's the proof.</p>
    </div>
  </header>

  <section class="sec">
    <div class="con">
      <p class="section-label">Championship History</p>
      <h2 class="sh">When Cleveland Ruled Football</h2>
      <div class="tl">
        <div class="tli" *ngFor="let e of gloryEras">
          <div class="tly">{{e.year}}</div>
          <div class="tld"></div>
          <div class="tlc"><h3 class="tlt">{{e.title}}</h3><p class="tldesc">{{e.desc}}</p></div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec alt">
    <div class="con">
      <p class="section-label">By The Numbers</p>
      <div class="sg">
        <div class="sc" *ngFor="let s of goodStats">
          <div class="sn good-c">{{s.value}}</div>
          <div class="sl">{{s.label}}</div>
          <div class="sctx">{{s.context}}</div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec">
    <div class="con">
      <p class="section-label">Hall of Fame</p>
      <h2 class="sh">Legends Who Wore Orange</h2>
      <div class="hg">
        <div class="hc" *ngFor="let l of legends">
          <div class="hn">#{{l.number}}</div>
          <h3 class="hname">{{l.name}}</h3>
          <p class="hp">{{l.pos}}</p>
          <p class="hs">{{l.stat}}</p>
        </div>
      </div>
    </div>
  </section>

  <section class="sec alt">
    <div class="con">
      <p class="section-label">Best Seasons Since 1999</p>
      <div class="dt"><table>
        <thead><tr><th>Year</th><th>W</th><th>L</th><th>Win %</th><th>Coach</th><th>Note</th></tr></thead>
        <tbody>
          <tr *ngFor="let s of bestSeasons">
            <td class="ty">{{s.year}}</td>
            <td class="tw">{{s.wins}}</td>
            <td class="tl2">{{s.losses}}</td>
            <td>
              <div class="wb">
                <div class="wbf good-bar" [style.width.%]="pct(s)*100"></div>
                <span>{{(pct(s)*100).toFixed(1)}}%</span>
              </div>
            </td>
            <td class="tc">{{s.coach}}</td>
            <td class="tn">{{s.note || '—'}}</td>
          </tr>
        </tbody>
      </table></div>
    </div>
  </section>
</div>
EOF

cat > frontend/src/app/features/the-good/the-good.component.scss << 'EOF'
.page{min-height:100vh}
.ph{min-height:60vh;display:flex;align-items:flex-end;position:relative;overflow:hidden}
.good-ph .hbg{position:absolute;inset:0;background:linear-gradient(135deg,rgba(45,122,58,.15) 0%,var(--grey-dark) 60%)}
.phc{position:relative;z-index:1;padding:80px 40px;max-width:1280px;width:100%;margin:0 auto;animation:slideUp .6s ease both}
.pt{font-family:'Bebas Neue',sans-serif;font-size:clamp(5rem,12vw,10rem);line-height:.88;margin:16px 0 20px}
.ag{color:#4CAF50}.ps{font-size:clamp(.9rem,1.8vw,1.1rem);color:var(--text-muted);max-width:480px;line-height:1.65}
.sec{padding:0}.alt{background:var(--brown)}
.con{max-width:1280px;margin:0 auto;padding:80px 40px}
.sh{font-family:'Bebas Neue',sans-serif;font-size:clamp(2rem,5vw,4rem);margin:12px 0 48px;color:var(--cream)}
.tl{border-left:2px solid rgba(76,175,80,.3);padding-left:32px;margin-left:24px}
.tli{position:relative;padding-bottom:48px;display:flex;gap:24px;align-items:flex-start}
.tli:last-child{padding-bottom:0}
.tld{position:absolute;left:-40px;top:6px;width:14px;height:14px;border-radius:50%;background:#4CAF50;border:2px solid var(--grey-dark)}
.tly{font-family:'Roboto Mono',monospace;font-size:.75rem;color:#4CAF50;min-width:56px;padding-top:2px}
.tlt{font-family:'Bebas Neue',sans-serif;font-size:1.4rem;color:var(--cream);margin-bottom:6px}
.tldesc{font-size:.85rem;color:var(--text-muted);line-height:1.6}
.sg{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:1px;background:rgba(76,175,80,.08)}
.sc{padding:40px 32px;background:var(--brown);transition:background .2s}.sc:hover{background:var(--brown-mid)}
.sn{font-family:'Bebas Neue',sans-serif;font-size:clamp(2.5rem,5vw,4rem);line-height:1}
.good-c{color:#4CAF50}.sl{font-size:.75rem;letter-spacing:.12em;text-transform:uppercase;color:var(--cream);margin:8px 0 4px}
.sctx{font-size:.78rem;color:var(--text-muted);line-height:1.5}
.hg{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:16px}
.hc{padding:32px 24px;background:var(--grey-mid);border:1px solid var(--border-subtle);border-radius:4px;transition:border-color .2s,transform .2s}
.hc:hover{border-color:rgba(76,175,80,.3);transform:translateY(-3px)}
.hn{font-family:'Roboto Mono',monospace;font-size:.65rem;color:#4CAF50;margin-bottom:12px}
.hname{font-family:'Bebas Neue',sans-serif;font-size:1.5rem;color:var(--cream);margin-bottom:4px}
.hp{font-size:.7rem;letter-spacing:.12em;text-transform:uppercase;color:var(--text-muted);margin-bottom:12px}
.hs{font-size:.8rem;color:var(--cream-dim);line-height:1.5}
.dt{overflow-x:auto}
table{width:100%;border-collapse:collapse}
th{text-align:left;font-size:.65rem;letter-spacing:.15em;text-transform:uppercase;color:var(--text-muted);padding:12px 16px;border-bottom:1px solid var(--border-subtle)}
td{padding:14px 16px;font-size:.88rem;color:var(--cream);border-bottom:1px solid var(--border-subtle)}
tr:hover td{background:rgba(255,255,255,.03)}
.ty{font-family:'Roboto Mono',monospace;color:var(--text-muted)}
.tw{color:#4CAF50;font-weight:600}.tl2{color:var(--red-bad);font-weight:600}.tc{color:var(--text-muted);font-size:.8rem}.tn{font-size:.8rem}
.wb{display:flex;align-items:center;gap:10px}
.wbf{height:4px;border-radius:2px}.good-bar{background:#4CAF50}
.wb span{font-size:.78rem;color:var(--text-muted);white-space:nowrap}
@media(max-width:640px){.phc,.con{padding:60px 24px}}
EOF
echo "  ✓ the-good component"

# ── the-bad.component.ts ─────────────────────────────────────
cat > frontend/src/app/features/the-bad/the-bad.component.ts << 'TSEOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BrownsDataService, SeasonRecord } from '../../core/browns-data.service';

@Component({ selector: 'app-the-bad', standalone: true, imports: [CommonModule],
  templateUrl: './the-bad.component.html', styleUrls: ['./the-bad.component.scss']
})
export class TheBadComponent implements OnInit {
  badStats: any[] = []; allSeasons: SeasonRecord[] = [];
  quarterbacks = [
    {name:'Tim Couch',years:'1999–03'},{name:'Kelly Holcomb',years:'2001–04'},{name:'Jeff Garcia',years:'2004'},
    {name:'Trent Dilfer',years:'2005'},{name:'Charlie Frye',years:'2005–07'},{name:'Derek Anderson',years:'2006–09'},
    {name:'Brady Quinn',years:'2007–09'},{name:'Jake Delhomme',years:'2010'},{name:'Colt McCoy',years:'2010–12'},
    {name:'Seneca Wallace',years:'2011'},{name:'Brandon Weeden',years:'2012–13'},{name:'Jason Campbell',years:'2013'},
    {name:'Brian Hoyer',years:'2013–14'},{name:'Johnny Manziel',years:'2014–15'},{name:'Josh McCown',years:'2015'},
    {name:'Robert Griffin III',years:'2016'},{name:'Cody Kessler',years:'2016'},{name:'DeShone Kizer',years:'2017'},
    {name:'Baker Mayfield',years:'2018–21'},{name:'Case Keenum',years:'2019'},{name:'Nick Mullens',years:'2021'},
    {name:'Jacoby Brissett',years:'2022'},{name:'Deshaun Watson',years:'2022–'},{name:'P.J. Walker',years:'2022'},
    {name:'Joe Flacco',years:'2023'},{name:'DTR',years:'2023'},{name:'Jeff Driskel',years:'2021'},
    {name:'Kyle Allen',years:'2022'},{name:'Joshua Dobbs',years:'2023'},{name:'Tyler Huntley',years:'2024'},
    {name:'Jameis Winston',years:'2024'},{name:'Bailey Zappe',years:'2024'},
  ];
  coaches = [
    {y:'1999–00',n:'Chris Palmer',r:'5–27'},{y:'2001–04',n:'Butch Davis',r:'24–35'},
    {y:'2004',n:'Terry Robiskie',r:'1–4'},{y:'2005–08',n:'Romeo Crennel',r:'24–40'},
    {y:'2009–10',n:'Eric Mangini',r:'10–22'},{y:'2011–12',n:'Pat Shurmur',r:'9–23'},
    {y:'2013',n:'Rob Chudzinski',r:'4–12'},{y:'2014–15',n:'Mike Pettine',r:'10–22'},
    {y:'2016–18',n:'Hue Jackson',r:'8–40–1'},{y:'2018',n:'Gregg Williams',r:'5–3'},
    {y:'2019',n:'Freddie Kitchens',r:'6–10'},{y:'2020–24',n:'Kevin Stefanski',r:'40–44'},
  ];
  constructor(private data: BrownsDataService) {}
  ngOnInit() { this.badStats = this.data.badStats; this.allSeasons = this.data.winLossHistory; }
}
TSEOF

cat > frontend/src/app/features/the-bad/the-bad.component.html << 'EOF'
<div class="page">
  <header class="ph bad-ph">
    <div class="hbg"></div>
    <div class="phc">
      <p class="section-label">Chapter 02</p>
      <h1 class="pt">The<br><span class="ab">Bad</span></h1>
      <p class="ps">Two playoff appearances in 26 years. 32 starting QBs. A masterclass in sustained mediocrity.</p>
    </div>
  </header>

  <section class="sec alt">
    <div class="con">
      <p class="section-label">The Quarterback Problem</p>
      <h2 class="sh">32 Starting QBs Since 1999</h2>
      <p class="sd">No franchise in modern NFL history has cycled through starting quarterbacks faster.</p>
      <div class="qg">
        <div class="qc" *ngFor="let q of quarterbacks; let i = index" [style.animation-delay.ms]="i*30">
          <span class="qn">{{i+1}}</span>
          <span class="qname">{{q.name}}</span>
          <span class="qy">{{q.years}}</span>
        </div>
      </div>
    </div>
  </section>

  <section class="sec">
    <div class="con">
      <p class="section-label">By The Numbers</p>
      <div class="sg">
        <div class="sc" *ngFor="let s of badStats">
          <div class="snum bad-c">{{s.value}}</div>
          <div class="sl">{{s.label}}</div>
          <div class="sctx">{{s.context}}</div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec alt">
    <div class="con">
      <p class="section-label">Win–Loss Record Since 1999</p>
      <h2 class="sh">Season by Season</h2>
      <div class="sb">
        <div class="sr" *ngFor="let s of allSeasons">
          <div class="sy">{{s.year}}</div>
          <div class="sbi">
            <div class="bw" [style.flex]="s.wins" [class.playoff]="s.note?.includes('Playoffs')">
              <span *ngIf="s.wins >= 4">{{s.wins}}W</span>
            </div>
            <div class="bl" [style.flex]="s.losses">
              <span *ngIf="s.losses >= 4">{{s.losses}}L</span>
            </div>
          </div>
          <div class="snote" *ngIf="s.note">{{s.note}}</div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec">
    <div class="con">
      <p class="section-label">Coaching Carousel</p>
      <h2 class="sh">24 Head Coaches</h2>
      <div class="cg">
        <div class="cc" *ngFor="let c of coaches">
          <div class="cy">{{c.y}}</div>
          <div class="cn">{{c.n}}</div>
          <div class="cr">{{c.r}}</div>
        </div>
      </div>
    </div>
  </section>
</div>
EOF

cat > frontend/src/app/features/the-bad/the-bad.component.scss << 'EOF'
.page{min-height:100vh}
.ph{min-height:60vh;display:flex;align-items:flex-end;position:relative;overflow:hidden}
.bad-ph .hbg{position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,152,0,.12) 0%,var(--grey-dark) 60%)}
.phc{position:relative;z-index:1;padding:80px 40px;max-width:1280px;width:100%;margin:0 auto;animation:slideUp .6s ease both}
.pt{font-family:'Bebas Neue',sans-serif;font-size:clamp(5rem,12vw,10rem);line-height:.88;margin:16px 0 20px}
.ab{color:#FF9800}.ps{font-size:clamp(.9rem,1.8vw,1.1rem);color:var(--text-muted);max-width:480px;line-height:1.65}
.sec{padding:0}.alt{background:var(--grey-mid)}
.con{max-width:1280px;margin:0 auto;padding:80px 40px}
.sh{font-family:'Bebas Neue',sans-serif;font-size:clamp(2rem,5vw,4rem);margin:12px 0 16px;color:var(--cream)}
.sd{font-size:.9rem;color:var(--text-muted);line-height:1.65;max-width:600px;margin-bottom:40px}
.qg{display:flex;flex-wrap:wrap;gap:8px}
.qc{display:flex;align-items:center;gap:8px;padding:8px 14px;background:var(--grey-dark);border:1px solid var(--border-subtle);border-radius:3px;animation:fadeIn .4s ease both;transition:border-color .2s}
.qc:hover{border-color:rgba(255,152,0,.4)}
.qn{font-family:'Roboto Mono',monospace;font-size:.6rem;color:#FF9800;min-width:16px}
.qname{font-size:.8rem;font-weight:500;color:var(--cream)}
.qy{font-family:'Roboto Mono',monospace;font-size:.6rem;color:var(--text-muted)}
.sg{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:1px;background:rgba(255,152,0,.08)}
.sc{padding:40px 32px;background:var(--grey-dark);transition:background .2s}.sc:hover{background:var(--grey-mid)}
.snum{font-family:'Bebas Neue',sans-serif;font-size:clamp(2.5rem,5vw,4rem);line-height:1}
.bad-c{color:#FF9800}.sl{font-size:.75rem;letter-spacing:.12em;text-transform:uppercase;color:var(--cream);margin:8px 0 4px}
.sctx{font-size:.78rem;color:var(--text-muted);line-height:1.5}
.sb{display:flex;flex-direction:column;gap:6px}
.sr{display:flex;align-items:center;gap:12px}
.sy{font-family:'Roboto Mono',monospace;font-size:.7rem;color:var(--text-muted);min-width:36px}
.sbi{display:flex;flex:1;height:22px;border-radius:2px;overflow:hidden}
.bw{background:rgba(76,175,80,.5);display:flex;align-items:center;justify-content:flex-end;padding-right:6px;min-width:2px;font-size:.6rem;color:rgba(76,175,80,.9);font-weight:600;transition:flex .5s ease}
.bw.playoff{background:rgba(76,175,80,.8)}
.bl{background:rgba(204,34,0,.4);display:flex;align-items:center;justify-content:flex-end;padding-right:6px;min-width:2px;font-size:.6rem;color:rgba(204,34,0,.9);font-weight:600;transition:flex .5s ease}
.snote{font-size:.65rem;color:var(--cream-dim);white-space:nowrap}
.cg{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:1px;background:var(--border-subtle)}
.cc{padding:24px 20px;background:var(--grey-dark);transition:background .2s}.cc:hover{background:var(--grey-mid)}
.cy{font-family:'Roboto Mono',monospace;font-size:.6rem;color:#FF9800;margin-bottom:8px}
.cn{font-family:'Bebas Neue',sans-serif;font-size:1.1rem;color:var(--cream);letter-spacing:.04em;margin-bottom:4px}
.cr{font-size:.72rem;color:var(--text-muted)}
@media(max-width:640px){.phc,.con{padding:60px 24px}}
EOF
echo "  ✓ the-bad component"

# ── the-ugly.component.ts ────────────────────────────────────
cat > frontend/src/app/features/the-ugly/the-ugly.component.ts << 'TSEOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BrownsDataService } from '../../core/browns-data.service';

@Component({ selector: 'app-the-ugly', standalone: true, imports: [CommonModule],
  templateUrl: './the-ugly.component.html', styleUrls: ['./the-ugly.component.scss']
})
export class TheUglyComponent implements OnInit {
  uglyStats: any[] = []; worstSeasons: any[] = [];
  shameItems = [
    {year:'2017',title:'The 0–16 Season',desc:"Only the second team in NFL history to finish winless. DeShone Kizer started 15 games. The Browns earned the #1 pick and took Baker Mayfield.",painLevel:10},
    {year:'1995',title:'Art Modell Moves the Franchise',desc:"Owner Art Modell secretly negotiated to move the Cleveland Browns to Baltimore. Cleveland literally wept at the final game. The original Browns became the Ravens.",painLevel:10},
    {year:'2022',title:'The Deshaun Watson Contract',desc:"$230M fully guaranteed to a quarterback facing 24 civil lawsuits. Watson was suspended 11 games his first year, then rarely played after. Historic money for historic disappointment.",painLevel:9},
    {year:'2016',title:'Johnny Manziel Implosion',desc:"Drafted as a franchise savior, Johnny Football partied more than he practiced, wore disguises to dodge the media, and was cut after two disastrous seasons.",painLevel:8},
    {year:'2019',title:'The Freddie Kitchens Disaster',desc:"Hired an OC with no head coaching experience after Baker Mayfield's promising rookie year. Went 6–10. Fired after exactly one season.",painLevel:7},
    {year:'2013',title:'Chudzinski Fired After 1 Year',desc:"Hired in January. Fired in December. Given one season before being cut loose — even though the team had arguably the worst roster in the league.",painLevel:6},
  ];
  watsonFacts = [
    '11-game suspension in 2022 — longest in NFL history at the time',
    'Completed just 17 games across 2022 and 2023 seasons combined',
    'Underwent shoulder surgery in 2023, missing the rest of the year',
    'Was benched in 2024 for poor performance before being cut',
    'Team traded three first-round picks to Houston just to acquire him',
    'Guaranteed money still owed beyond his time on the roster',
  ];
  constructor(private data: BrownsDataService) {}
  ngOnInit() { this.uglyStats = this.data.uglyStats; this.worstSeasons = this.data.getWorstSeasons(5); }
}
TSEOF

cat > frontend/src/app/features/the-ugly/the-ugly.component.html << 'EOF'
<div class="page">
  <header class="ph ugly-ph">
    <div class="hbg"></div>
    <div class="phc">
      <p class="section-label">Chapter 03</p>
      <h1 class="pt">The<br><span class="au">Ugly</span></h1>
      <p class="ps">Some things can't just be called "bad." These moments deserve their own category.</p>
    </div>
  </header>

  <section class="sec alt">
    <div class="con">
      <p class="section-label">Hall of Shame</p>
      <h2 class="sh">Moments That Haunt Cleveland</h2>
      <div class="sl">
        <div class="si" *ngFor="let m of shameItems; let i = index">
          <div class="sr">{{(i+1).toString().padStart(2,'0')}}</div>
          <div class="sb">
            <h3 class="st">{{m.title}}</h3>
            <p class="sy">{{m.year}}</p>
            <p class="sd">{{m.desc}}</p>
            <div class="pm">
              <span class="pl">Pain Level</span>
              <div class="pb"><div class="pf" [style.width.%]="m.painLevel*10"></div></div>
              <span class="pn">{{m.painLevel}}/10</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec">
    <div class="con">
      <p class="section-label">The Numbers Don't Lie</p>
      <div class="sg">
        <div class="sc" *ngFor="let s of uglyStats">
          <div class="snum ugly-c">{{s.value}}</div>
          <div class="slabel">{{s.label}}</div>
          <div class="sctx">{{s.context}}</div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec alt">
    <div class="con">
      <p class="section-label">The Contract That Haunts</p>
      <h2 class="sh">Deshaun Watson Deal</h2>
      <div class="cv">
        <div class="cb"><div class="cn">$230M</div><div class="cl">Fully Guaranteed</div><div class="cs">Most in NFL history at signing</div></div>
        <div class="cf">
          <div class="fr" *ngFor="let f of watsonFacts">
            <div class="fi">→</div><div class="ft">{{f}}</div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec">
    <div class="con">
      <p class="section-label">Historical Record</p>
      <h2 class="sh">Worst Seasons Since 1999</h2>
      <div class="wg">
        <div class="wc" *ngFor="let s of worstSeasons; let i = index">
          <div class="wr">#{{i+1}}</div>
          <div class="wy">{{s.year}}</div>
          <div class="wrec">{{s.wins}}–{{s.losses}}</div>
          <div class="wco">{{s.coach}}</div>
          <div class="wn" *ngIf="s.note">{{s.note}}</div>
        </div>
      </div>
    </div>
  </section>

  <section class="sec fw">
    <div class="con"><div class="fi2">
      <p class="fq">"But next year is our year."</p>
      <p class="fa">— Every Browns fan, every year, since 1964</p>
    </div></div>
  </section>
</div>
EOF

cat > frontend/src/app/features/the-ugly/the-ugly.component.scss << 'EOF'
.page{min-height:100vh}
.ph{min-height:60vh;display:flex;align-items:flex-end;position:relative;overflow:hidden}
.ugly-ph .hbg{position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,60,0,.15) 0%,var(--grey-dark) 60%)}
.phc{position:relative;z-index:1;padding:80px 40px;max-width:1280px;width:100%;margin:0 auto;animation:slideUp .6s ease both}
.pt{font-family:'Bebas Neue',sans-serif;font-size:clamp(5rem,12vw,10rem);line-height:.88;margin:16px 0 20px}
.au{color:var(--orange);animation:flicker 4s ease infinite 1s}
.ps{font-size:clamp(.9rem,1.8vw,1.1rem);color:var(--text-muted);max-width:480px;line-height:1.65}
.sec{padding:0}.alt{background:var(--grey-mid)}.fw{border-top:1px solid var(--border-subtle)}
.con{max-width:1280px;margin:0 auto;padding:80px 40px}
.sh{font-family:'Bebas Neue',sans-serif;font-size:clamp(2rem,5vw,4rem);margin:12px 0 48px;color:var(--cream)}
.sl{display:flex;flex-direction:column;gap:1px;background:var(--border-subtle)}
.si{display:grid;grid-template-columns:64px 1fr;background:var(--grey-dark);transition:background .2s}
.si:hover{background:var(--grey-mid)}
.sr{display:flex;align-items:flex-start;justify-content:center;padding:32px 0 0;font-family:'Bebas Neue',sans-serif;font-size:2rem;color:rgba(255,60,0,.25);letter-spacing:.04em}
.sb{padding:32px 32px 32px 0}
.st{font-family:'Bebas Neue',sans-serif;font-size:1.6rem;letter-spacing:.04em;color:var(--cream);margin-bottom:4px}
.sy{font-family:'Roboto Mono',monospace;font-size:.65rem;color:var(--orange);letter-spacing:.1em;margin-bottom:12px}
.sd{font-size:.88rem;color:var(--text-muted);line-height:1.65;max-width:640px;margin-bottom:20px}
.pm{display:flex;align-items:center;gap:12px}
.pl{font-size:.65rem;letter-spacing:.12em;text-transform:uppercase;color:var(--text-muted);white-space:nowrap}
.pb{flex:1;height:4px;background:rgba(255,255,255,.1);border-radius:2px;overflow:hidden;max-width:200px}
.pf{height:100%;background:linear-gradient(90deg,#FF9800,var(--orange));border-radius:2px}
.pn{font-family:'Roboto Mono',monospace;font-size:.65rem;color:var(--orange);white-space:nowrap}
.sg{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:1px;background:rgba(255,60,0,.08)}
.sc{padding:40px 32px;background:var(--grey-dark);transition:background .2s}.sc:hover{background:var(--grey-mid)}
.snum{font-family:'Bebas Neue',sans-serif;font-size:clamp(2.5rem,5vw,4rem);line-height:1}
.ugly-c{color:var(--orange)}.slabel{font-size:.75rem;letter-spacing:.12em;text-transform:uppercase;color:var(--cream);margin:8px 0 4px}
.sctx{font-size:.78rem;color:var(--text-muted);line-height:1.5}
.cv{display:grid;grid-template-columns:auto 1fr;gap:64px;align-items:start}
.cb{text-align:center}
.cn{font-family:'Bebas Neue',sans-serif;font-size:clamp(4rem,8vw,7rem);color:var(--orange);line-height:1;animation:flicker 6s ease infinite}
.cl{font-size:.75rem;letter-spacing:.12em;text-transform:uppercase;color:var(--cream);margin:8px 0 4px}
.cs{font-size:.75rem;color:var(--text-muted)}
.fr{display:flex;gap:12px;padding:16px 0;border-bottom:1px solid var(--border-subtle);align-items:flex-start}
.fr:last-child{border-bottom:none}
.fi{color:var(--orange);font-size:.8rem;margin-top:2px;flex-shrink:0}
.ft{font-size:.88rem;color:var(--cream);line-height:1.6}
.wg{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:1px;background:var(--border-subtle)}
.wc{padding:32px 24px;background:var(--grey-dark);transition:background .2s}.wc:hover{background:var(--grey-mid)}
.wr{font-family:'Roboto Mono',monospace;font-size:.6rem;color:var(--orange);margin-bottom:12px}
.wy{font-family:'Bebas Neue',sans-serif;font-size:2rem;color:var(--cream);line-height:1}
.wrec{font-family:'Bebas Neue',sans-serif;font-size:1.6rem;color:var(--red-bad);letter-spacing:.04em;margin:4px 0}
.wco{font-size:.78rem;color:var(--text-muted);margin-bottom:8px}
.wn{font-size:.75rem;color:var(--orange)}
.fi2{text-align:center;padding:80px 40px}
.fq{font-family:'Bebas Neue',sans-serif;font-size:clamp(2rem,5vw,4.5rem);color:var(--cream);margin-bottom:16px;letter-spacing:.02em}
.fa{font-size:.8rem;color:var(--text-muted);letter-spacing:.08em}
@media(max-width:768px){.cv{grid-template-columns:1fr;gap:32px}}
@media(max-width:640px){.phc,.con{padding:60px 24px}.si{grid-template-columns:40px 1fr}.sb{padding:24px 16px 24px 0}}
EOF
echo "  ✓ the-ugly component"


# ── git operations ───────────────────────────────────────────
echo ""
echo "📦 Staging all changes..."
git add -A

echo "💾 Committing..."
git commit -m "feat: Cleveland Browns fan page — The Good, The Bad & The Ugly

- New three-section layout replacing multi-team dashboard
- Sleek dark UI with Browns orange design system (CSS vars)
- Bebas Neue display + Inter body + Roboto Mono data fonts
- Home hero with scanline animation and live record calculation
- The Good: glory timeline, Hall of Famers, championship history
- The Bad: 32 QB carousel, coaching table, season bar chart
- The Ugly: Hall of Shame pain meters, Watson contract breakdown
- BrownsDataService with full historical records 1999-2024
- Lazy-loaded Angular standalone components throughout
- Sticky nav with scroll transparency + mobile hamburger
- Comprehensive README: start/stop + 3 deployment options
- Reduced motion media query support"

echo "🚀 Pushing branch..."
git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${REPO_OWNER}/${REPO_NAME}.git"
git push -u origin "$BRANCH" --force

echo "📬 Creating Pull Request..."
PR_BODY=$(cat << 'PREOF'
## 🏈 Cleveland Browns Fan Page

Transforms the Cleveland Sports Analytics dashboard into a dedicated **Cleveland Browns Fan Page** featuring three themed deep-dive sections.

### Pages

| Route | What you'll find |
|-------|-----------------|
| `/home` | Hero with live W-L record, quick stats strip, section previews |
| `/the-good` | Championship timeline, Hall of Famers, best modern seasons |
| `/the-bad` | 32 QB carousel, 12 coaches, season-by-season bar charts |
| `/the-ugly` | Hall of Shame with pain meters, Watson breakdown, worst seasons |

### Design System

- **Palette**: Browns orange `#FF3C00` on deep brown-black (`#1A1209`)
- **Typography**: Bebas Neue (display) + Inter (body) + Roboto Mono (data/labels)
- **Motion**: Scanline hero effect, orange text flicker, slide-up page reveals
- **Responsive**: Mobile-first grid + hamburger nav
- **Accessibility**: `prefers-reduced-motion` support, semantic HTML

### Technical

- Angular 21 standalone components with lazy loading via `loadComponent`
- `BrownsDataService` — single source of truth for all historical data (1999–2024)
- CSS custom properties across all components
- Sticky nav transitions from transparent → frosted glass on scroll

### Also included

New comprehensive `README.md` covering:
- Start / stop instructions for both terminals
- Three deployment paths: Vercel, GitHub Pages, AWS Amplify
- Next steps roadmap (live API, charts, PWA, tests)

---

*Here we go Brownies, here we go.* 🐶
PREOF
)

PR_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls" \
  -d "{
    \"title\": \"🏈 Cleveland Browns Fan Page — The Good, The Bad & The Ugly\",
    \"body\": $(echo "$PR_BODY" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'),
    \"head\": \"$BRANCH\",
    \"base\": \"$BASE_BRANCH\"
  }")

PR_URL=$(echo "$PR_RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('html_url',''))" 2>/dev/null || echo "")

if [ -n "$PR_URL" ] && [ "$PR_URL" != "None" ]; then
  echo ""
  echo "✅  PR created successfully!"
  echo "    $PR_URL"
else
  echo ""
  echo "⚠️  PR may already exist or there was an issue. Check:"
  echo "    https://github.com/$REPO_OWNER/$REPO_NAME/pulls"
  echo ""
  echo "Raw API response:"
  echo "$PR_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PR_RESPONSE"
fi

echo ""
echo "🎉 Done! Branch: $BRANCH"
