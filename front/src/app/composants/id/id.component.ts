import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormControl, FormGroup, FormBuilder } from '@angular/forms';
import { ServiceService } from 'src/app/services/service.service';
import { Journal, Message } from 'src/app/modeles/modele';
import { Subscribable, Subscription } from 'rxjs';

@Component({
  selector: 'app-id',
  templateUrl: './id.component.html'
})
export class IdComponent implements OnInit, OnDestroy{

  data!: Journal;
  infos!: FormGroup;
  itemId!: number;
  newData!: Journal;
  message!: string;
  check: boolean = false;
  service1!: Subscription|undefined;

  constructor(private service: ServiceService, private route: ActivatedRoute, private formBuilder: FormBuilder, private router: Router){}

  ngOnInit(): void {
    this.initForm();
  }

  ngOnDestroy(): void {
      this.unsusc();
  }

  unsusc(): void {
    if (this.service1 != undefined) this.service1.unsubscribe();
  }

  initForm() : void|null {
    
    const id: string | null = this.route.snapshot.paramMap.get("id");
    if (id == null) {
      this.router.navigate(['erreur']);
      return null;
    }
    this.itemId = parseInt(id);
    

    this.service1 = this.service.getById(this.itemId)?.subscribe(res => {
      this.infos = this.formBuilder.group({
        note : new FormControl(res.note)
        });  
      this.data = res;
    });
  }

  onSubmit() : void|null{
    const note = this.infos.value.note;
    if (note == null || note == undefined || note.length < 10) return null;
    const journal: Journal = new Journal(this.data.id, note, this.data.quand);
    try {
      this.service.update(journal)?.subscribe(res => {
        if (res == null) this.message = "problème d'appel serveur";
        else {
          this.message = res.message;
          this.check = true;
        }
      });
    } catch (err) {
      this.message = "problème d'appel serveur";
    }
  }

  rafraichir() {
    this.check = false;
    this.initForm();
  }

  delete(e: Event, id: number) {
    this.service.delete(id)?.subscribe(mess => {
      if (mess == null) this.message = "problème serveur de suppression";
      else if (mess.message == "Problème de suppression") this.message = mess.message;
      else this.router.navigate(['all']);
    });
  }



  getNext(event: Event, id: number) {
    this.unsusc();
    this.service1 = this.service.getNext(id)?.subscribe(res => {
      this.infos = this.formBuilder.group({
        note : new FormControl(res.note)
        });  
      this.data = res;
    });
  }

  getPrevious(event: Event, id: number) {
    this.unsusc();
    this.service1 = this.service.getPrevious(id)?.subscribe(res => {
      this.infos = this.formBuilder.group({
        note : new FormControl(res.note)
        });  
      this.data = res;
    });
  }

}