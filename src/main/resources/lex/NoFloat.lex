/************************************************************************************************/
/* i-Code CNES is a static code analyzer.                                                       */
/* This software is a free software, under the terms of the Eclipse Public License version 1.0. */ 
/* http://www.eclipse.org/legal/epl-v10.html                                                    */
/************************************************************************************************/ 

/**********************************************************************************/
/* This file is used to generate a rule checker to verify that no float keyword   */
/* is used in a C file.                                                           */
/**********************************************************************************/

package fr.cnes.icode.c.checkers;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.File;
import java.util.List;
import java.util.EmptyStackException;
import java.util.Stack;

import fr.cnes.icode.datas.AbstractChecker;
import fr.cnes.icode.datas.CheckResult;
import fr.cnes.icode.exception.JFlexException;

%%

%class NoFloat
%extends AbstractChecker
%public
%column
%line


%function run
%yylexthrow JFlexException
%type List<CheckResult>


%state SINGLELINE_COMMENT, MULTILINE_COMMENT, STRING_DOUBLE

COMMENT_WORD    = [\/][\/]
COMMENT_START   = [\/][\*]
COMMENT_END     = [\*][\/]
NEWLINE			= \r | \n | \r\n

PRIMITIVE       = "float" | "double"

STRING_D		= [\"]
IGNORE_STRING_D = [\\][\"]

																
%{
	/* GLOBAL: constant for main program localisation */
    private static final String GLOBAL = "GLOBAL";
	
	String location = GLOBAL;

    private String parsedFileName;

    public NoFloat() { }
	
	@Override
	public void setInputFile(final File file) throws FileNotFoundException {
		super.setInputFile(file);
        this.parsedFileName = file.toString();
        this.zzReader = new FileReader(new File(file.getAbsolutePath()));
	}
%}

%eofval{
	return getCheckResults();
%eofval}


%%          



/************************/



/************************/
/* COMMENT STATES       */
/************************/
<SINGLELINE_COMMENT>
		{
				{NEWLINE}      	    {yybegin(YYINITIAL);}
		  	 	[^]                 {}
		}

<MULTILINE_COMMENT>
		{
				{COMMENT_END}       {yybegin(YYINITIAL);}
		  	 	[^]                 {}
		}

/************************/
/* YYINITIAL STATE	    */
/************************/
<YYINITIAL>
		{
			  	{COMMENT_WORD} 	    {yybegin(SINGLELINE_COMMENT);}
			  	{COMMENT_START}     {yybegin(MULTILINE_COMMENT);}
			    {PRIMITIVE}		    {setError(location,"The keyword " + yytext() + " is not allowed.", yyline+1);}
				{STRING_D}		    {yybegin(STRING_DOUBLE);}
			 	[^]            	    {}
		}

/************************/
/* STRING_DOUBLE STATE	*/
/************************/
<STRING_DOUBLE>   	
		{
				{IGNORE_STRING_D}	{}
				{STRING_D}    		{yybegin(YYINITIAL);}  
		  	 	[^]                 {}
		}		

/************************/
/* ERROR STATE	        */
/************************/
				[^]                 {
                                        final String errorMessage = "Analysis failure : Your file could not be analyzed. Please verify that it was encoded in an UNIX format.";
                                        throw new JFlexException(this.getClass().getName(), parsedFileName, errorMessage, yytext(), yyline, yycolumn);
								    }