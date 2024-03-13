import { HttpHeaders } from "@angular/common/http";

// modèle principal
export class Journal {
    id!: number;
    note!: string;
    quand!: Date;

    constructor(id: number, note: string, quand: Date) {
        this.id = id;
        this.note = note;
        this.quand = quand;
    }
} 

// headers pour jwt
export class Options {
    headers!: HttpHeaders|null;
}

// message du back-end
export class Message {
    message!: string;
}

// pour signin
export class PseudoPwd {
    login!: String;
    password!: String;
}

// classe pour jwt
export class TokenDto {
    token!: string;

    constructor(token: string) {
        this.token = token;
    }
}
