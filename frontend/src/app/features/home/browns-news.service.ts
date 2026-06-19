import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface BrownsArticle {
  headline: string;
  description: string;
  published: string;
  link: string;
}

interface ApiResponse {
  LatestNews: BrownsArticle[];
  ArticleCount: number;
  League: string;
  PK: string;
  SK: string;
  UpdatedTimestamp: string;
}

@Injectable({
  providedIn: 'root'
})
export class BrownsNewsService {
  private http = inject(HttpClient);
  // Your live AWS API Endpoint
  private apiUrl = 'https://ul9l90ngkj.execute-api.us-east-2.amazonaws.com/teams/BROWNS';

  getLatestNews(): Observable<BrownsArticle[]> {
    return this.http.get<ApiResponse>(this.apiUrl).pipe(
      // Extract just the array your template needs to loop through
      map(response => response.LatestNews || [])
    );
  }
}