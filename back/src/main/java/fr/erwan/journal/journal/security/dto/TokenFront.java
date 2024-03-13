package fr.erwan.journal.journal.security.dto;

/**
 * récupérer le token du front
 */
public class TokenFront {
    private String token;

    public TokenFront() {     
    }
    
    public String getToken() {
        return this.token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    @Override 
    public String toString() {
        return this.token;
    }
}
