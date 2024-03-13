package fr.erwan.journal.journal.database.service;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import fr.erwan.journal.journal.database.models.Modele;

@Repository
public interface ServiceFactory extends JpaRepository<Modele, Long>{

    @Query(value = "SELECT * FROM journal j WHERE j.id > ?1 order by id limit 1", nativeQuery = true)
    Optional<Modele> findNext(Long id);

    @Query(value = "SELECT * FROM journal j WHERE j.id < ?1 order by id desc limit 1", nativeQuery = true)
    Optional<Modele> findPrevious(Long id); 

    @Query(value = "SELECT * FROM journal j order by j.id desc limit 1", nativeQuery = true)
    Optional<Modele> findLast(); 

    @Query(value = "SELECT * FROM journal j order by j.id asc limit 1", nativeQuery = true)
    Optional<Modele> findFirst(); 
}
