/* Lexical Analyzer for MacroJava 
 * Author : Akhilesh Godi (CS10B037)
 * CS3310 - Assignment-1
 * Problem Statement : http://www.cse.iitm.ac.in/~krishna/cs3300/hw1.html
 */

%{
#include<stdlib.h>
#include<stdio.h>
#include "macrojava.tab.h"
%}


DIGIT       [0-9]
ALPHA       [_a-zA-Z]              
ID          {ALPHA}[_a-zA-Z0-9$]*
KEYWORDS    ("define"|"abstract"|"continue"|"for"|"new"|"switch"|"assert"|"default"|"goto"|"package"|"synchronized"|"boolean"|"do"|"if"|"private"|"this"|"break"|"double"|"implements"|"protected"|"throw"|"byte"|"else"|"import"|"public"|"throws"|"case"|"enum"|"instanceof"|"return"|"transient"|"catch"|"extends"|"int"|"short"|"try"|"char"|"final"|"interface"|"static"|"void"|"class"|"finally"|"long"|"volatile"|"const"|"float"|"native"|"super"|"while")
BOOLEANS    ("true"|"false"|"True"|"False")
SYMBOLS     ("#"|"("|")"|"{"|"["|"]"|"}"|"|"|";"|"?"|"."|",")
OPERATORS   ("<"|">"|"!"|"&"|"*"|"-"|"+"|"/"|"!="|"."|"="|"&&"|"||"|"<<"|">>"|"^"|"%"|"==")

%%

"//"[^\n]*|"/*"[^"*/"]"*/" 
"\t"|"\n"|" "   

0|[1-9]{DIGIT}*                     {
                                        yylval.ival = atoi(yytext);
                                        return INT;
                                    }
    
{BOOLEANS}                          {
                                        yylval.bval = strdup(yytext);
                                        return BOOLEAN;
                                    }

{KEYWORDS}                          {
                                        yylval.kw = strdup(yytext);
                                        return KEYWORD;
                                    }
                                    
{SYMBOLS}                           {
                                        yylval.symbol = strdup(yytext);
                                        return SYMBOL;  
                                    }
                     
{OPERATORS}                         {
                                        yylval.op = strdup(yytext);
                                        return OPERATOR;
                                    }
                                     
{ID}                                {
                                        yylval.id = strdup(yytext);
                                        return IDENTIFIER;
                                    }

.                                   

%%
