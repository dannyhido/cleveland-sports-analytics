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
