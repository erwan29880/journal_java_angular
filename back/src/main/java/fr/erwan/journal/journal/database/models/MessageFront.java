package fr.erwan.journal.journal.database.models;

/**
 * Message à envoyer au frond-end avec l'entity manager
 */
public class MessageFront {
    private String message;

    public MessageFront() {}

    public MessageFront(String mess) {
        this.message = mess;
    }

    public String getMessage() {
        return this.message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
