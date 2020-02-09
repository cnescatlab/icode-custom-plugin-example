/************************************************************************************************/
/* i-Code CNES is a static code analyzer.                                                       */
/* This software is a free software, under the terms of the Eclipse Public License version 1.0. */
/* http://www.eclipse.org/legal/epl-v10.html                                                    */
/************************************************************************************************/

package fr.cnes.icode.c.checkers;

import fr.cnes.icode.test.ICodeCheckerTester;

/**
 * This class aims to test all C rules. There are 2 functions in this class.
 * The first one verifies that an error in a file is detected whenever there is
 * one, the other verifies that nothing is detected when there's no error.
 * <p>
 * These functions test all rules with values provided by parametrized test.
 */
public class TestAllCCheckers implements ICodeCheckerTester {

    /**
     * This List represent the data set and contains:
     * - path to an errored file
     * - path to a correct file
     * - array of line raising errors
     * - array of function raising errors
     * - class of the checker to apply to previous files
     *
     * @return Array of test data.
     */
    public static Object[][] data() {
        return new Object[][]{
                {"/PRIMITIVE_TYPE/error.c", "/PRIMITIVE_TYPE/no_error.c", new int[]{72}, new String[]{"GLOBAL"}, NoFloat.class},
                {"/FORBIDDEN_KEYWORDS/error.c", "/FORBIDDEN_KEYWORDS/no_error.c", new int[]{60, 62, 65, 71}, new String[]{"GLOBAL", "GLOBAL", "GLOBAL", "GLOBAL"}, NoToDo.class}
        };
    }

}
