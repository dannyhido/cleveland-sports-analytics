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
