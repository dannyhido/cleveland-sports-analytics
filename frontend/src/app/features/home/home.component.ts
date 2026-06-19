import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { BrownsDataService } from '../../core/browns-data.service';
// 1. Import the news component class here
import { BrownsNewsComponent } from './browns-news.component'; 

@Component({
   selector: 'app-home', 
   standalone: true, 
   // 2. Add BrownsNewsComponent right here into your imports array!
   imports: [RouterLink, CommonModule, BrownsNewsComponent], 
   templateUrl: './home.component.html', 
   styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  overall = { wins: 0, losses: 0, ties: 0 };
  yearsOfPain = new Date().getFullYear() - 1964;

  constructor(private data: BrownsDataService) {}

  ngOnInit() { 
    this.overall = this.data.getOverallRecord(); 
  }
}