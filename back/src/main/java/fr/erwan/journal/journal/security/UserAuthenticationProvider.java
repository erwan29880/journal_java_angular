package fr.erwan.journal.journal.security;

import java.util.Base64;
import java.util.Collections;
import java.util.Date;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;

import fr.erwan.journal.journal.security.dto.CredentialsDto;
import fr.erwan.journal.journal.security.dto.UserDto;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import jakarta.annotation.PostConstruct;

/**
 * Création du token jwt
 * vérification du token
 */
@Component
public class UserAuthenticationProvider {
    
    // dans applications.properties
    @Value("${application.pwd}")
    private String secretKey;

    @Value("${application.expireAt}")
    private long expireAt;

    private final AuthenticationService authenticationService;

    public UserAuthenticationProvider(AuthenticationService authenticationService) {
        this.authenticationService = authenticationService;
    }


    /**
     * this is to avoid having the raw secret key available in the JVM
     */
    @PostConstruct
    protected void init() {
        this.secretKey = Base64.getEncoder().encodeToString(this.secretKey.getBytes());
    }

    /**
     * Création du token
     * @param login vient du front
     * @return le token jwt
     */
    public String createToken(String login) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + this.expireAt); // 1 hour

        Algorithm algorithm = Algorithm.HMAC256(this.secretKey);
        return JWT.create()
            .withIssuer(login)
            .withIssuedAt(now)
            .withExpiresAt(validity)
            .sign(algorithm);
    }

    /**
     * validation du token
     * @param token vient du front
     * @return une authentication
     */
    public Authentication validateToken(String token) {
        
        Algorithm algorithm = Algorithm.HMAC256(this.secretKey);
        JWTVerifier verifier = JWT.require(algorithm).build();
        DecodedJWT decoded = verifier.verify(token);

        // check time validity
        long expiresAt = decoded.getExpiresAt().getTime();
        long now = new Date().getTime();
        
        if (expiresAt < now) {
            return new UsernamePasswordAuthenticationToken(new UserDto(), Collections.emptyList());
        }
       
        UserDto user = authenticationService.findByLogin(decoded.getIssuer());
        return new UsernamePasswordAuthenticationToken(user, null, Collections.emptyList());
    }


    /**
     * méthode de vérification du token
     * @param token jwt
     * @return true ou false
     */
    public boolean validateToken2(String token) {
        String TokenSplitted = token;
        Algorithm algorithm = Algorithm.HMAC256(this.secretKey);
        JWTVerifier verifier = JWT.require(algorithm).build();
        DecodedJWT decoded = verifier.verify(TokenSplitted);

        // check time validity
        long expiresAt = decoded.getExpiresAt().getTime();
        long now = new Date().getTime();
        
        if (expiresAt < now) {
            return false;
        }
        
        if (TokenSplitted.matches(decoded.getToken())) {
            return true;
        }

        return false;
    }


    /**
     * vérification des credentials
     * @param credentialsDto un objet credentialDto
     * @return une autentication
     */
    public Authentication validateCredentials(CredentialsDto credentialsDto) {
        UserDto user = authenticationService.authenticate(credentialsDto);
        return new UsernamePasswordAuthenticationToken(user, null, Collections.emptyList());
    }
}
