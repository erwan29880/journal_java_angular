import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot } from '@angular/router';
import { ServiceService } from './service.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuardService implements CanActivate {

  check: boolean = false;

  constructor(private service: ServiceService, private router: Router) {
  }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot) {
    this.service.getCheckAuthGard().subscribe(res => {
      this.check = res;
    });
    if (!this.check) {
      this.router.navigate(['/']);
      return false;
    }
    return true;
  }
}
