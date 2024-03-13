import { LOCALE_ID, NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { ConnComponent } from './composants/conn/conn.component';
import { AllComponent } from './composants/all/all.component';
import { CreateComponent } from './composants/create/create.component';
import { IdComponent } from './composants/id/id.component';
import { ReactiveFormsModule } from '@angular/forms';
import { registerLocaleData } from '@angular/common';
import * as fr from '@angular/common/locales/fr';
import { ErreurComponent } from './erreur/erreur.component';


@NgModule({
  declarations: [
    AppComponent,
    ConnComponent,
    AllComponent,
    CreateComponent,
    IdComponent,
    ErreurComponent
    ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule, 
    ReactiveFormsModule
  ],
  providers: [
    { provide: LOCALE_ID, useValue: 'fr-FR'}
  ],
  bootstrap: [AppComponent]
})
export class AppModule {
  constructor() {
    registerLocaleData(fr.default);
  }
 }
