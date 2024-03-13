package fr.erwan.journal.journal.security.dto;

/**
 * Gestion du token
 */
public class TokenDto {
    
    private String token;
    
        public TokenDto(){}

        public TokenDto(String token) {
            this.token = token;
        }

    public String getToken() {
        return this.token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
