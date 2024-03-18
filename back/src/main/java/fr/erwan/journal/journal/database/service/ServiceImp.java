package fr.erwan.journal.journal.database.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import fr.erwan.journal.journal.database.models.Modele;
import fr.erwan.journal.journal.database.models.ModeleFront;
import fr.erwan.journal.journal.database.utils.Escape;

import java.util.*;

@Service
public class ServiceImp {

    @Autowired
    private ServiceFactory repo;

    private final int nbItemsPerPage = 5;

    public List<Modele> findAll() {
        return repo.findAll();
    }

    public List<Modele> findAllByPage(int pageNumber) {
        List<Modele> modeles = new ArrayList<>();
        Pageable paging = PageRequest.of(pageNumber, nbItemsPerPage, Sort.by("id").descending());
        Page<Modele> m = repo.findAll(paging);
        if (!m.isEmpty()) modeles = m.getContent();
        modeles = Escape.invHtmlEscape(modeles);
        return modeles;
    }

    public Modele findOne(Long idi) {
        Long id = idi == null ? 0L : idi;
        Optional<Modele> modele = repo.findById(id);
        return modele.isPresent() ? Escape.invHtmlEscape(modele.get()) : new Modele();
    }

    public Modele findNext(Long idi) {
        Long id = idi == null ? 0L : idi;
        Long maxId = 0L;
        Optional<Modele> last = repo.findLast();
        if (last.isPresent()) {
            maxId = last.get().getId();
            if (maxId <= id) {
                Optional<Modele> first = repo.findFirst();
                id = first.isPresent() ? first.get().getId() : 1L;
            }
        } 
        Optional<Modele> modele = repo.findNext(id);
        return modele.isPresent() ? Escape.invHtmlEscape(modele.get()) : new Modele();
    }

    public Modele findPrevious(Long idi) {
        Long id = idi == null ? 0L : idi;
        Long minId = 0L;
        Optional<Modele> first = repo.findFirst();
        if (first.isPresent()) {
            minId = first.get().getId();
            if (minId >= id) {
                Optional<Modele> last = repo.findLast();
                id = last.isPresent() ? last.get().getId() : 1L;
            }
        } 
        Optional<Modele> modele = repo.findPrevious(id);
        return modele.isPresent() ? Escape.invHtmlEscape(modele.get()) : new Modele();
    }

    public long countAll() {
        return repo.count();
    }


    public boolean save(ModeleFront mf) {
        
        if (mf.getNote().length() <= 5) return false;
        Modele modele = new Modele(0L, Escape.htmlEscape(mf.getNote()));
        java.sql.Date date = new java.sql.Date(new java.util.Date().getTime());
        modele.setQuand(date);
        if (isValid(modele)) {
            this.repo.save(modele);
            return true;
        }
        return false;
    }

    public Modele update(Modele modele) {
        if (modele == null) return new Modele();
        return isValid(modele) ? repo.save(modele) : new Modele();
    }

    public Long delete(Long id) {
        if (id == null) return 0L;
        try {
            repo.deleteById(id);
            return id;
        } catch (Exception e) {
            return 0L;
        }
    }


    public boolean isValid(Modele modele) {
        return modele.getId() instanceof Long && modele.getNote() instanceof String && modele.getQuand() instanceof java.sql.Date;
    }

}
