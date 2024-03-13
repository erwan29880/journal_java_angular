package fr.erwan.journal.journal.database.models;

public class ModeleFront {
    private String note;


    public ModeleFront() {
    }

    public ModeleFront(String note) {
        this.note = note;
    }

    public String getNote() {
        return this.note;
    }

    public void setNote(String note) {
        this.note = note;
    }

}
