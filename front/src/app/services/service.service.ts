import { Injectable } from '@angular/core';
import { Observable, BehaviorSubject, tap, map, pipe, delay } from 'rxjs';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Journal, Options, Message, PseudoPwd, TokenDto } from '../modeles/modele';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class ServiceService {

  private url: String = "http://localhost:8080/journal";
  private _data = new BehaviorSubject<Journal[]>([]);
  private _data$ = this._data.asObservable();
  private _check = new BehaviorSubject<boolean>(false);
  private _check$ = this._check.asObservable();
  private peremption: number = 50000000;

  constructor(private http: HttpClient, private router: Router) {}

  getDatas() : Observable<Journal[]> {
    return this._data$;
  }

  setDatas(val: Journal[]) {
    this._data.next(val);
  }


  getAll(page: number) {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return;
  
      this.http.get<Journal[]>(this.url + "/all/page/" + page.toString(), {headers: header?.headers}).pipe(
        tap(res => this._data.next(res))
      ).subscribe();
    } catch(err) {
      return;
    }
  }

  getCountPages() {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return;
  
      return this.http.get<Message>(this.url + "/count", {headers: header?.headers});
    } catch(err) {
      return;
    }
  }

  getNext(id: number) {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return;
      return this.http.get<Journal>(this.url + "/next/" + id.toString() , {headers: header?.headers});
    } catch(err) {
      return;
    }
  }

  getPrevious(id: number) {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return;
      return this.http.get<Journal>(this.url + "/previous/" + id.toString() , {headers: header?.headers});
    } catch(err) {
      return;
    }
  }

  getById(id: number) : Observable<Journal>|null {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return null;

      return this.http.get<Journal>(this.url + "/get/"+ id.toString(), {headers: header?.headers});;
    } catch(err) {
      return null;
    }
  }

  save(note: Journal ) : Observable<Message>|null {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return null;
      return this.http.post<Message>(this.url + "/save", note, {headers: header?.headers});
    } catch (err) {
      return null;
    }
  }

  delete(id: number) : Observable<Message>|null {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return null;
  
      return this.http.delete<Message>(this.url + "/delete/" + id.toString(), {headers: header?.headers});
    } catch (err) {
      return null;
    }
  }

  update(note: Journal) : Observable<Message>|null {
    try {
      const header = this.setOptions();
      if (header?.headers === null) return null;
  
      return this.http.put<Message>(this.url + "/update", note, {headers: header?.headers});
    } catch (err) {
      return null;
    }
  }



  logout() {
    try {
      const check: string|null = sessionStorage.getItem("check");
      const jwtToken: string|null = sessionStorage.getItem("jwt");
      if (check !== null) {
        sessionStorage.removeItem("check");
      }
      if (jwtToken!== null) {
        sessionStorage.removeItem("jwt");
      }
    } catch (err) {}
    this.router.navigate(['/']);
  }

  // headers for jwt
  setOptions(): Options|null {
    try {
      const jwtToken: string|null = sessionStorage.getItem("jwt");
      if (jwtToken === null) {
        return {headers : null};
      }
      
      const headers =  new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': jwtToken 
      });
      return {headers : headers};
    } catch (err) {
      return null;
    }
  }



  checkPseudoPwd(obj: PseudoPwd) : void {
    try {
      this.http.post<TokenDto>(this.url + "/signin", obj, {observe: "response"})
      .subscribe(res => {
        const jwt : string|undefined = res.body?.token;
        if (jwt !== undefined) {
          this._check.next(true);
          this.setCheckInSessionStorage(jwt);
        } else {
          this._check.next(false);
          this.logout();
        }
      });
    } catch (err) {
      this._check.next(false);
    }
  }

    // mettre les tokens dans le sessionStorage
    setCheckInSessionStorage(jwt: string) : void|null {
      try {
        const expirateAt: string = (new Date().getTime() + this.peremption).toString()
        sessionStorage.setItem("jwt", jwt);
        sessionStorage.setItem("check",  expirateAt);
      } catch (err) {
        return null;
      }
    }
  
  
    // Authguard
    getCheckAuthGard() : Observable<boolean> {
      try {
        this.checkSessionStorage();
      } catch (err) {}
      return this._check$;
    }
  
    getCheck() : Observable<boolean> {
      return this._check$;
    }
  
    checkSessionStorage() {
      try {
        // vérification durée du token
        const now = new Date().getTime();
        const test: string|null = sessionStorage.getItem("check");
        if (test !== null) {
          if (parseInt(test) < now) {
            sessionStorage.removeItem("check");
            this._check.next(false);
            return;
          }
        }
    
        // vérification token Jwt
        const jwtToken: string|null  = sessionStorage.getItem("jwt");
        if (jwtToken === null) {
          this._check.next(false);
          return;
        }
        this.http.post<Message>(this.url + "/jwt", new TokenDto(jwtToken))
        .subscribe(res => {
          if (res.message === "ok") {
            this._check.next(true);
          } else {
            this._check.next(false);
          }
        })
        return;
      } catch (err) {
        return;
      }
    }
}

