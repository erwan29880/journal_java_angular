import { NgModule } from '@angular/core';
import { RouterModule, Routes, CanActivate } from '@angular/router';
import { ConnComponent } from './composants/conn/conn.component';
import { CreateComponent } from './composants/create/create.component';
import { AllComponent } from './composants/all/all.component';
import { IdComponent } from './composants/id/id.component';
import { ErreurComponent } from './erreur/erreur.component';
import { AuthGuardService as AuthGuard } from './services/auth-guard.service';


const routes: Routes = [
  {path: "", component: ConnComponent},
  {path: "create", component: CreateComponent, canActivate: [AuthGuard] },
  {path: "all/:id", component: AllComponent },
  {path: "all", component: AllComponent, canActivate: [AuthGuard] },
  {path: "erreur", component: ErreurComponent},
  {path: ":id", component: IdComponent, canActivate: [AuthGuard] },
  {path: "**", component: ConnComponent}
];


@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
