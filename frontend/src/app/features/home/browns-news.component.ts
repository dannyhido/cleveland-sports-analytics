import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Observable, catchError, of } from 'rxjs';
import { BrownsNewsService, BrownsArticle } from './browns-news.service';

@Component({
  selector: 'app-browns-news',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './browns-news.component.html',
  styleUrls: ['./browns-news.component.scss']
})
export class BrownsNewsComponent implements OnInit {
  private newsService = inject(BrownsNewsService);
  
  news$!: Observable<BrownsArticle[]>;
  errorMessage: string | null = null;

  ngOnInit(): void {
    this.news$ = this.newsService.getLatestNews().pipe(
      catchError(err => {
        console.error('API Stream Error:', err);
        this.errorMessage = 'Failed to load the latest analytics stream. Check CORS settings.';
        return of([]);
      })
    );
  }
}