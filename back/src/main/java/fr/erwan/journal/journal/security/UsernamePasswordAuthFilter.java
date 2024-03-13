package fr.erwan.journal.journal.security;

import java.io.IOException;

import com.fasterxml.jackson.databind.ObjectMapper;

import fr.erwan.journal.journal.security.dto.CredentialsDto;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.HttpMethod;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * vérification lors du signIn
 */
public class UsernamePasswordAuthFilter extends OncePerRequestFilter {
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final UserAuthenticationProvider userAuthenticationProvider;

    private final String login = "superman";

    public UsernamePasswordAuthFilter(UserAuthenticationProvider userAuthenticationProvider) {
        this.userAuthenticationProvider = userAuthenticationProvider;
    }

    /**
     * vérification lors du signIn
     */
    @Override
    protected void doFilterInternal(
            HttpServletRequest req,
            HttpServletResponse res,
            FilterChain filterChain) throws ServletException, IOException {
            
        if ("/journal/signin".equals(req.getServletPath()) && HttpMethod.POST.matches(req.getMethod())) {
            CredentialsDto credentialsDto = new CredentialsDto();
            
            // si le login ne correspond pas, créer un char creadientals.password bidon pour ne pas valider l'authentification
            try {
                credentialsDto = MAPPER.readValue(req.getInputStream(), CredentialsDto.class);
                if (credentialsDto.getLogin().equals(this.login) == false) {
                    char[] fake = {'a'};
                    credentialsDto.setPassword(fake);
                } else {
                }
            } catch (Exception e) {
                throw e;
            }

            // validation du couple login/password
            try {
                SecurityContextHolder
                    .getContext()
                    .setAuthentication(userAuthenticationProvider.validateCredentials(credentialsDto));

                } catch (RuntimeException e) {
                    SecurityContextHolder
                    .clearContext();
                    throw e;
                }
            }
        filterChain.doFilter(req, res);
    }
}
