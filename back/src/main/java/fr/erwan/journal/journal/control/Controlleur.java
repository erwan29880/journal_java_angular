package fr.erwan.journal.journal.control;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import fr.erwan.journal.journal.database.models.MessageFront;
import fr.erwan.journal.journal.database.models.Modele;
import fr.erwan.journal.journal.database.models.ModeleFront;
import fr.erwan.journal.journal.database.service.ServiceImp;
import fr.erwan.journal.journal.security.UserAuthenticationProvider;
import fr.erwan.journal.journal.security.dto.TokenDto;
import fr.erwan.journal.journal.security.dto.TokenFront;
import fr.erwan.journal.journal.security.dto.UserDto;

@RequestMapping("/journal")
@RestController
public class Controlleur {
    
    @Autowired
    private ServiceImp service;

    @Autowired
    private UserAuthenticationProvider userAuthenticationProvider;

    private final String origine = "http://localhost:4200";
    private final String headersKey = "Authorization";
 

    /**
     * méthode de loggin, en accès authorisé
     * @param user {pseudo:String, password:String}
     * @return le token jwt ou une erreur
     */
    @PostMapping("/signin")
    @CrossOrigin(origins = {origine})
    public ResponseEntity<?> signIn(@AuthenticationPrincipal UserDto user) {
        try {
            user.setpassword(userAuthenticationProvider.createToken(user.getLogin()));
            return ResponseEntity.ok(new TokenDto(user.getpassword()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new MessageFront("bad credentials"));
        }
    }


    /**
     * méthode de vérification pour le token JWT venant du front-end
     * @return une réponse par défaut, et un code d'erreur géré par Spring security
     */
    @PostMapping("/jwt")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public ResponseEntity<MessageFront> checkJwt(@RequestBody TokenFront token) {
        boolean check = this.userAuthenticationProvider.validateToken2(token.getToken());
        return check ?
            ResponseEntity.ok(new MessageFront("ok")) :
            ResponseEntity.ok(new MessageFront("pasok"));
    }


    /**
     * récupérer toutes les données de la table
     * cette méthode n'est pas utilisée, la méthode avec pagination est utilisée à la place
     * @return toutes les données
     */
    @GetMapping("/all")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public List<Modele> findAll() {
        return service.findAll();
    }

    /**
     * retourner toutes les données selon une pagination
     * @param id le numéro de la page
     * @return quelques données selon la page et le nombre de données par page
     */
    @GetMapping("/all/page/{id}")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public List<Modele> findAllByPage(@PathVariable final int id) {
        return service.findAllByPage(id);
    }

    @GetMapping("/count")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public ResponseEntity<MessageFront> countAll() {
        return ResponseEntity.ok(new MessageFront(Long.toString(service.countAll())));
    }

    @GetMapping("/get/{id}")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public Modele findOne(@PathVariable final Long id) {
        return service.findOne(id);
    }

    @GetMapping("/next/{id}")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public Modele findNext(@PathVariable final Long id) {
        return service.findNext(id);
    }

    @GetMapping("/previous/{id}")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public Modele findBefore(@PathVariable final Long id) {
        return service.findPrevious(id);
    }

    @PostMapping("/save")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public ResponseEntity<MessageFront> save(@RequestBody ModeleFront mf) {
        return service.save(mf) ?
            ResponseEntity.ok(new MessageFront("message enregistré !")) :
            ResponseEntity.ok(new MessageFront("Problème d'enregistrement"));
    }

    @DeleteMapping("/delete/{id}")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public ResponseEntity<MessageFront> delete(@PathVariable final Long id) {
        Long i = service.delete(id);
        return i != 0L ?
            ResponseEntity.ok(new MessageFront("message supprimé !")) :
            ResponseEntity.ok(new MessageFront("Problème de suppression"));
    }

    @PutMapping("/update")
    @CrossOrigin(origins = {origine}, exposedHeaders = {headersKey})
    public ResponseEntity<MessageFront> update(@RequestBody Modele modele) {
        Modele m = service.update(modele);
        return service.isValid(m) ?
            ResponseEntity.ok(new MessageFront("message enregistré !")) :
            ResponseEntity.ok(new MessageFront("Problème d'enregistrement"));
    }
}
