package fr.erwan.journal.journal.database.models;

import jakarta.persistence.*;
import lombok.*;
import java.sql.Date;

@Getter 
@Setter
@Builder
@Entity
@Table(name = "journal")
public class Modele {
    
    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name="note")
    private String note;

    @Column(name = "quand")
    private Date quand;


    public Modele() {
    }

    public Modele(String note) {
        this.note = note;
    }

    public Modele(Long id, String note) {
        this.id = id;
        this.note = note;
    }


    public Modele(Long id, String note, Date quand) {
        this.id = id;
        this.note = note;
        this.quand = quand;
    }


    @Override 
    public String toString() {
        return new StringBuilder().append(this.id).append(", ").append(this.note).append(", ").append(this.quand).toString();
    }
}
