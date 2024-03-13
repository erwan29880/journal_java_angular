import { Component, OnDestroy, OnInit } from '@angular/core';
import { ServiceService } from 'src/app/services/service.service';
import { Journal, Message } from 'src/app/modeles/modele';
import { FormControl, FormGroup, FormBuilder } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable, startWith, map, tap, combineLatest, Subscription } from 'rxjs';

@Component({
  selector: 'app-all',
  templateUrl: './all.component.html'
})
export class AllComponent implements OnInit, OnDestroy {
  
  nbMessagesPerPage: number = 5;
  message!: String;
  donnes$!: Observable<Journal[]>;
  page!: number;
  pageToAccess: number = 0;
  numerosPages: number[] = [];
  service1!: Subscription | undefined;

  constructor(private service: ServiceService, private route: Router, private formBuilder: FormBuilder, private router: ActivatedRoute){}

  ngOnInit(): void|null {
    this.paginate();
  }

  ngOnDestroy(): void {
      if (this.service1 !== undefined) this.service1.unsubscribe();
      this.page = 0;
  }

  paginate() {
    this.getObs();
    if (this.pageToAccess === 0) {
      const id: string | null = this.router.snapshot.paramMap.get("id");
      this.page = id === null ? 0 : parseInt(id);
    } else {
      this.page = this.pageToAccess;
      this.pageToAccess = 0;
    }
  
    this.service.getAll(this.page);
    this.getCountPages();
  }

  getObs() : void|null {
    try {
      this.donnes$ = this.service.getDatas();
    } catch (err) {
      return null;
    }
  }

  getCountPages() : void|null {
    try {
      this.service1 = this.service.getCountPages()?.subscribe(res => {
        // nombre d'items dans la table
        const i = parseInt(res.message);

        // nombre de pages à afficher
        let nb = i / this.nbMessagesPerPage;
        if (nb < 1) nb = 1;
        else if (nb - Math.floor(nb) >= 0) nb++;
        nb = Math.floor(nb);

        // incrément de début
        let inc = 1;
        this.numerosPages.push(inc);

        // afficher des points si il y a trop de nombres
        if (this.page + 1 > 4 && nb > 15) {
          inc = this.page - 1;
          this.numerosPages.push(0);
        } 

        // définir une fin de liste de pages à 15, et afficher des points le cas échéant
        const fin = inc + 15;
        for (let i = inc; i < fin ; i++) {
          if (i >= nb) break;
          this.numerosPages.push(i+1);
        }

        // affichage de points
        if (fin < nb - 3) this.numerosPages.push(0);
        
        // affichage de la dernière page si elle n'est pas prise en compte dans la boucle
        if (fin < nb - 1) this.numerosPages.push(nb - 1);
         
      });
    } catch (err) {
      return null;
    }
  }


  chargeItem(event: Event, id: number): void | null {
    try {
      this.route.navigate(['/', id]);
    } catch (err) {
      return null;
    }
  }

  changePage(event: Event, page: number) {
    this.numerosPages = [];
    this.pageToAccess = page - 1;
    this.paginate();
  }
}
