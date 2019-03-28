package fr.cnes.icode.c.language;

import fr.cnes.icode.services.languages.ILanguage;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Definition of the C language.
 */
public class CLanguage implements ILanguage {

    /**
     * @return the name of the language.
     */
    @Override
    public String getName() {
        return "C";
    }

    /**
     * @return the id of the language.
     */
    @Override
    public String getId() {
        return "fr.cnes.icode.c";
    }

    /**
     * @return the list of extensions of the language.
     */
    @Override
    public List<String> getFileExtension() {
        return Stream.of(
                "c", "h", "C", "H"
        ).collect(Collectors.toList());
    }
}