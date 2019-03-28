/************************************************************************************************/
/* i-Code CNES is a static code analyzer.                                                       */
/* This software is a free software, under the terms of the Eclipse Public License version 1.0. */ 
/* http://www.eclipse.org/legal/epl-v10.html                                                    */
/************************************************************************************************/ 

/**********************************************************************************/
/* This file is used to generate a rule checker to verify that no todo expression */
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

%class NoToDo
%extends AbstractChecker
%public
%column
%line


%function run
%yylexthrow JFlexException
%type List<CheckResult>


%state SINGLELINE_COMMENT, MULTILINE_COMMENT, PRIMITIVE, CODE, STRING_SIMPLE, STRING_DOUBLE

COMMENT_WORD    = [\/][\/]
COMMENT_START   = [\/][\*]
COMMENT_END     = [\*][\/]
NEWLINE			= \r | \n | \r\n
SPACE			= {NEWLINE} | [\ \t\f]

TODO            = "todo" | "TODO" | "ToDo" | "Todo"

FUNCT			= {FNAME}{SPACE}*[\(]{SPACE}*[\)]
IDENTIFIANT     = [:jletter:] [:jletterdigit:]*

STRING_D		= \"
IGNORE_STRING_D = [\\][\"]
STRING_S	 	= \'
IGNORE_STRING_S = [\\][\']

																
%{
	/* GLOBAL: constant for main program localisation */
    private static final String GLOBAL = "GLOBAL";
	
	String location = GLOBAL;
	/* functionLine: the beginning line of the function */
	int functionLine = 0;

    private String parsedFileName;
	String errorTodo = "";

	private Stack<String> functionStack = new Stack<>();

    public NoToDo() { }
	
	@Override
	public void setInputFile(final File file) throws FileNotFoundException {
		super.setInputFile(file);
        this.parsedFileName = file.toString();
        this.zzReader = new FileReader(new File(file.getAbsolutePath()));
	}
	
	private void endLocation() throws JFlexException {
		try {
		    String functionFinished = functionStack.pop();
			if (!functionStack.empty()) {
				/* there is a current function: change location to this function */
				location = functionStack.peek();
			} else {
				/* we are in the main program: change location to main */
				location = GLOBAL;
			}
		} catch (final EmptyStackException e) {
        	final String errorMessage = e.getMessage();
            throw new JFlexException(this.getClass().getName(), parsedFileName,
            errorMessage, yytext(), yyline, yycolumn);
		}
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
				{NEWLINE}      	{yybegin(YYINITIAL);}
				{TODO}          {errorTodo = yytext(); setError(location,"The keyword " + errorTodo + " is not allowed.", yyline+1);}
		  	 	[^]|{SPACE}  	{}
			   	.              	{}
		}

<MULTILINE_COMMENT>
		{
				{COMMENT_END}   {yybegin(YYINITIAL);}
				{TODO}          {errorTodo = yytext(); setError(location,"The keyword " + errorTodo + " is not allowed.", yyline+1);}
		  	 	[^]|{SPACE}  	{}
			   	.              	{}
		}

/************************/
/* YYINITIAL STATE	    */
/************************/
<YYINITIAL>
		{
			  	{COMMENT_WORD} 	{yybegin(SINGLELINE_COMMENT);}
			  	{COMMENT_START} {yybegin(MULTILINE_COMMENT);}
				{STRING_D}		{yybegin(STRING_DOUBLE);}
				{STRING_S}		{yybegin(STRING_SIMPLE);}
			 	[^]            	{}
		}

/*
 * The string states are designed to avoid problems due to patterns found in strings.
 */ 
/************************/
/* STRING_SIMPLE STATE	*/
/************************/
<STRING_SIMPLE>   	
		{
				{IGNORE_STRING_S}	{}
				{STRING_S}    		{yybegin(YYINITIAL);}  
		  	 	[^]|{SPACE}  		{}
		}

/************************/
/* STRING_DOUBLE STATE	*/
/************************/
<STRING_DOUBLE>   	
		{
				{IGNORE_STRING_D}	{}
				{STRING_D}    		{yybegin(YYINITIAL);}  
		  	 	[^]|{SPACE}  		{}
		}		

/************************/
/* ERROR STATE	        */
/************************/
				[^]                 {
                                        final String errorMessage = "Analysis failure : Your file could not be analyzed. Please verify that it was encoded in an UNIX format.";
                                        throw new JFlexException(this.getClass().getName(), parsedFileName, errorMessage, yytext(), yyline, yycolumn);
								    }