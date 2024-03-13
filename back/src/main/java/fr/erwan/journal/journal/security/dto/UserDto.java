package fr.erwan.journal.journal.security.dto;

/**
 * objet user
 */
public class UserDto {
    private String login;
    private String password;

    public UserDto() {
        super();
    }

    public UserDto(String login, String password) {
        this.login = login;
        this.password = password;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getpassword() {
        return password;
    }

    public void setpassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return this.login + " - " + this.password;
    }
}
