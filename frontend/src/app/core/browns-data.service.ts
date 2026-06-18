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
