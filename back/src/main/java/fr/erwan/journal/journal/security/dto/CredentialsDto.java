package fr.erwan.journal.journal.security.dto;

/**
 * Vérification des infos de connection
*/
public class CredentialsDto {
    
    private String login;
    private char[] password;

    public CredentialsDto() {
        super();
    }

    public CredentialsDto(String login, char[] password) {
        this.login = login;
        this.password = password;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public char[] getPassword() {
        return password;
    }

    public void setPassword(char[] password) {
        this.password = password;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder().append(this.login).append(" - ").append(this.password);
        return sb.toString();
    }
}
