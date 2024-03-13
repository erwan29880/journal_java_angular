package fr.erwan.journal.journal.security;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Utilisé par AuthentificationService
 */
@Configuration
public class PasswordConfig {
    
    /**
	* cryptage du mot de passe avec BCrypt
	* @return le mot de passe encodé
	*/
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
