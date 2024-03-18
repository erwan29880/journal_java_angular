package fr.erwan.journal.journal.database.utils;

import java.util.ArrayList;
import java.util.TreeMap;
import java.util.Map;
import java.util.List;

import fr.erwan.journal.journal.database.models.Modele;

public class Escape {
    
    private static Map<String, String> map = new TreeMap<>();

    static{
        map.put("<", "&lt;");
        map.put(">", "&gt;");
        map.put("\'", "&#39;");
        map.put("\"", "&quot;");
    }

    public Escape() {}

    public static String htmlEscape(String s) {
        if (s.indexOf("&") != -1 ) s = s.replaceAll("&", "&amp;");
        if (s.indexOf("<script>") != -1 ) s = s.replaceAll("<script>", "");
        if (s.indexOf("</script>") != -1 ) s = s.replaceAll("</script>", "");
        
        for (String k: map.keySet()) {
            if (s.indexOf(k) != -1 ) s = s.replaceAll(k, map.get(k));
        }

        return s;
    }

    public static String invHtmlEscape(String s) {
        for (Map.Entry<String, String> es: map.entrySet()) {
            if (s.indexOf(es.getValue()) != -1) {
                s = s.replaceAll(es.getValue(), es.getKey());
                System.out.println(s);
            }

            if (s.indexOf("&amp;") != -1) s = s.replaceAll("&amp;", "&");
        } 
        return s;
    }

    public static Modele invHtmlEscape(Modele m) {
        String s = m.getNote();
        s = invHtmlEscape(s);
        m.setNote(s);
        return m;
    }

    public static List<Modele> invHtmlEscape(List<Modele> mods) {
        List<Modele> modeles = new ArrayList<>(mods);
        for (int i = 0; i < modeles.size() ; i++) {
            Modele m = invHtmlEscape(modeles.get(i));
            modeles.set(i, m);
            System.out.println(m);
        }
        return modeles;
    }
}
