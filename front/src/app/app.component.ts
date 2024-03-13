import { Component } from '@angular/core';
import { ServiceService } from './services/service.service';
import { Router } from '@angular/router';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  title = 'journal';

  constructor(private route: Router, private service: ServiceService) {}

  goToIndex() {
    this.route.navigate(['/']);
  }

  goToAll() {
    this.route.navigate(['/all'])
  }

  goToForm() {
    this.route.navigate(['/create']);
  }

  logout() {
    this.service.logout();
  }
}
