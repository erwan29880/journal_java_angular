import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, FormBuilder } from '@angular/forms';
import { ServiceService } from 'src/app/services/service.service';
import { PseudoPwd } from 'src/app/modeles/modele';

@Component({
  selector: 'app-conn',
  templateUrl: './conn.component.html'
})
export class ConnComponent implements OnInit{

  connection!: FormGroup;
  pseudoPwd!: PseudoPwd;
  message!: String;

  constructor(private formBuilder: FormBuilder, private service: ServiceService){
  }

  ngOnInit(): void {
    this.connection = this.formBuilder.group({
      login : new FormControl(""),
      password: new FormControl("")
    })
  }

  onSubmit() : void|null{
    try {
      this.pseudoPwd = this.connection.value;
      this.service.checkPseudoPwd(this.pseudoPwd);
      this.service.getCheck().subscribe(res => {
        
        if (res) {
          this.message = "Connecté";
        } else {
          this.message = "Bad credentials";
        }
      });
    } catch (err) {
      return null;
    }
  }

}
