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
