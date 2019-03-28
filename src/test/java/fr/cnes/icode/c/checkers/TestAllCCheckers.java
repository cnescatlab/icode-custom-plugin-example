/************************************************************************************************/
/* i-Code CNES is a static code analyzer.                                                       */
/* This software is a free software, under the terms of the Eclipse Public License version 1.0. */
/* http://www.eclipse.org/legal/epl-v10.html                                                    */
/************************************************************************************************/

package fr.cnes.icode.c.checkers;

import fr.cnes.icode.datas.AbstractChecker;
import fr.cnes.icode.datas.CheckResult;
import fr.cnes.icode.exception.JFlexException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameter;
import org.junit.runners.Parameterized.Parameters;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * This class aims to test all C rules. There are 2 functions in this class.
 * The first one verifies that an error in a file is detected whenever there is
 * one, the other verifies that nothing is detected when there's no error.
 *
 * These functions test all rules with values provided by parametrized test.
 */
@RunWith(Parameterized.class)
public class TestAllCCheckers {

    @Parameters(name = "TEST {index}: {4}")
    public static Iterable<Object[]> data() {
        return Arrays.asList(new Object[][] {
                {"/PRIMITIVE_TYPE/error.c", "/PRIMITIVE_TYPE/no_error.c", new int[]{ 72 }, new String[]{ "GLOBAL" }, NoFloat.class},
                {"/FORBIDDEN_KEYWORDS/error.c", "/FORBIDDEN_KEYWORDS/no_error.c", new int[]{ 60, 62, 65, 71 }, new String[]{ "GLOBAL", "GLOBAL", "GLOBAL", "GLOBAL" }, NoToDo.class}
        });
    }

    @Parameter
    public String errorFile;
    @Parameter(1)
    public String noErrorFile;
    @Parameter(2)
    public int[] lines;
    @Parameter(3)
    public String[] locations;
    @Parameter(4)
    public Class<?> checker;
    public AbstractChecker rule;

    /**
     * This test verifies that an error can be detected.
     */
    @Test
    public void testRunWithError() {

        try {
            // Initializing rule and getting error file.
            final File file = new File(getClass().getResource(errorFile).getFile());

            // Instantiate checker.
            this.rule = (AbstractChecker) checker.newInstance();

            // Defining file in the rule instantiation.
            this.rule.setInputFile(file);
            // Defining id in the rule instantiation.
            this.rule.setId(checker.getName());

            // Running rule
            final List<CheckResult> list = this.rule.run();

            // We verify that there is an error.
            assertFalse("No error found.", list.isEmpty());

            // We verify that there is the right number of errors

            final int nb_CheckResults = list.size();
            assertEquals("Wrong number of CheckResults : ", lines.length, nb_CheckResults);

            // We verify that the error detected is the right one. There is
            // only one case of error : a blank common (with no name) is
            // detected.
            final String fileName = list.get(0).getFile().getName();
            final String[] split = errorFile.split("/");
            assertEquals("Wrong file name : ", split[split.length-1], fileName);

            // We verify the values
            for (final CheckResult value : list) {
                final int index = list.indexOf(value);
                final String location = value.getLocation();
                assertTrue("CheckResult " + Integer.toString(index) + " has wrong location : " + location + " should contain "
                        + locations[index], location.contains(locations[index]));
                final int line = value.getLine();
                assertEquals("CheckResult " + Integer.toString(index) + " is in wrong line : ", lines[index], line);
            }
        } catch (final JFlexException | IllegalAccessException | InstantiationException | IOException e) {
            fail(String.format("Analysis error (%s): %s", e.getClass().getSimpleName(), e.getMessage()));
        }
    }

    /**
     * This test verifies nothing is returned when there's no error.
     */
    @Test
    public void testRunWithoutError() {
        try {
            // Initializing rule and getting error file.
            final File file = new File(getClass().getResource(noErrorFile).getFile());

            // Defining file in the rule instantiation.
            this.rule = (AbstractChecker) checker.newInstance();
            this.rule.setInputFile(file);

            // Running rule
            final List<CheckResult> list = this.rule.run();

            // We verify that there is an error.

            assertTrue("Error(s) are detected: " + getCheckResults(list), list.isEmpty());

        } catch (final JFlexException | IllegalAccessException | InstantiationException | IOException e) {
            fail(String.format("Analysis error (%s): %s", e.getClass().getSimpleName(), e.getMessage()));
        }
    }

    /**
     * Aggregate CheckResults in a single string.
     *
     * @param list List of CheckResults.
     * @return A single String.
     */
    public static final String getCheckResults(final List<CheckResult> list) {
        String message = "line(s), location(s) : ";
        for (final CheckResult value : list) {
            message = message + "\n    " + value.getLine().toString() + ", " + value.getLocation();
        }
        return message;
    }

}
