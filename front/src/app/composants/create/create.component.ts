import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, FormBuilder } from '@angular/forms';
import { ServiceService } from 'src/app/services/service.service';
import { Message, Journal } from 'src/app/modeles/modele';
import { Observable, pipe } from 'rxjs';

@Component({
  selector: 'app-create',
  templateUrl: './create.component.html'
})
export class CreateComponent implements OnInit{
  
  id: number = 0;
  note!: FormGroup;
  quand: Date = new Date();
  message!: string;

  constructor(private service: ServiceService, private formBuilder: FormBuilder){}

  ngOnInit(): void {
    this.initForm();
  }

  initForm() {
    this.note = this.formBuilder.group({ note : new FormControl("") });
  }

  onSubmit(): void | null {
    if (this.note.value.note == null) return null;
    const res: Observable<Message> | null = this.service.save(new Journal(this.id, this.note.value.note, this.quand));
    if (res != null) {
      res.subscribe(e => this.message = e["message"]);
    }
  }
}
