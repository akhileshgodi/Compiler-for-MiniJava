/*
 * Author : Akhilesh Godi (CS10B037)
 * Assignment : 2
 * CS 3310 - Language Translators Lab
 * http://www.cse.iitm.ac.in/~krishna/cs3300/hw2.html
 */
%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

extern FILE* yyin;
void yyerror(const char *s);
extern int yyparse();
char* buffer;

//Could have done better! Use a Lined List Implementation of structures
char macroName [100][50];
char macroExpansion [100][3000];
int noOfArguments[100];
char arguments [100][30][50];
int totalMacros = 0;
int noOfIdentifiers;

%}

%union{
	int ival; // integers
	char *bval;// true and false
	char  *kw; // such as class, int, boolean etc
	char *op; // such as +, -, * etc
	char *id; // identifiers
	char *str;
}

%token <ival> INTVAL
%token <bval> BOOLVAL
%token <kw> KEYWORD
%token <op> OPERATOR
%token <id> IDENTIFIER
%token END_OF_FILE
%token THIS
%token NEW
%token RETURN
%token CLASS
%token DEFINE
%token PUBLIC
%token STATIC
%token VOID
%token INT
%token BOOLEAN
%token IF
%token ELSE
%token WHILE
%token EXTENDS
%token STRING

%type <str> Goal
%type <str> Macros
%type <str> MacroStatement
%type <str> MacroExpression
%type <str> IdentifierList
%type <str> MoreIdentifiers
%type <str> MainClass
%type <str> TypeDeclarationList
%type <str> VariableDeclarations
%type <str> MethodDeclarations 
%type <str> Arguments
%type <str> MoreArguments 
%type <str> Type 
%type <str> Statements
%type <str> Statement
%type <str> Expr
%type <str> dotIdentifiers
%type <str> Expression
%type <str> MoreExpressions
%type <str> PrimaryExpression


%left '<' '>' '=' NE LE GE
%left '+' '-'
%left '*' '/' '%'

%initial-action {
buffer = (char *)malloc(100000*sizeof(char));
int i = 0;
for(i=0;i<20;i++) noOfArguments[i]=0;
}

%% 

Goal        : Macros MainClass TypeDeclarationList END_OF_FILE                                 
                {
                    printf("// Macrojava code parsed and minijava code generated successfully.\n");
                    printf("%s%s",$2,$3);
                }

            ;
      
          
Macros      : MacroExpression Macros                                                   {sprintf(buffer,"%s%s",$1,$2); $$ = strdup(buffer);}
            | MacroStatement Macros                                                    {sprintf(buffer,"%s%s",$1,$2); $$ = strdup(buffer);}
            | /*empty*/                                                                {sprintf(buffer,"\n"); $$ = strdup(buffer);}
            ;
            
MacroStatement  : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '{' Statements '}'       
                  {
                        totalMacros++;
                        int args = noOfIdentifiers;
                        noOfArguments[totalMacros-1] = args; 
                        sprintf(buffer,"#define %s(%s) {%s}\n",$3,$5,$8);
			            sprintf(macroName[totalMacros-1],"%s",$3);
			            char* temp = (char*) malloc(50);
			            strcpy(temp,arguments[totalMacros-1][noOfIdentifiers-1]);
			            for(args = noOfIdentifiers-1 ; args > 0 ;args--) {
			                strcpy(arguments[totalMacros-1][args],arguments[totalMacros-1][args-1]);
			            }
			            strcpy(arguments[totalMacros-1][0],temp);
			            free(temp);
			            noOfIdentifiers = 0;
			            sprintf(macroExpansion[totalMacros-1],"%s",$8);
			            $$ = strdup(buffer); 
                  
                  }
                ;

MacroExpression : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '(' Expr ')'       
                   {
                        totalMacros++;
                        int args = noOfIdentifiers;
                        noOfArguments[totalMacros-1] = args; 
                        sprintf(buffer,"#define %s(%s) (%s)\n",$3,$5,$8);
			            sprintf(macroName[totalMacros-1],"%s",$3);
			            char* temp = (char*) malloc(50);
			            strcpy(temp,arguments[totalMacros-1][noOfIdentifiers-1]);
			            for(args = noOfIdentifiers-1 ; args > 0 ;args--) {
			                strcpy(arguments[totalMacros-1][args],arguments[totalMacros-1][args-1]);
			            }
			            strcpy(arguments[totalMacros-1][0],temp);
			            //Check if the expresssion contains or uses other macros;
			            noOfIdentifiers = 0;
			            sprintf(macroExpansion[totalMacros-1],"%s",$8);
			            $$ = strdup(buffer); 
                  }
                ;  

IdentifierList  :  IDENTIFIER MoreIdentifiers                                           
                    {
			            sprintf(arguments[totalMacros][noOfIdentifiers],"%s",$1);
			            noOfIdentifiers++;
                        sprintf(buffer,"%s%s",$1,$2);
                        $$ = strdup(buffer);
                    }
                |  /*empty*/                                                            {sprintf(buffer,""); $$ = strdup(buffer);}
                ;

MoreIdentifiers :   MoreIdentifiers ',' IDENTIFIER                              
                    {
		                sprintf(arguments[totalMacros][noOfIdentifiers],"%s",$3);
		                noOfIdentifiers++;
                        sprintf(buffer,"%s, %s",$1,$3);
                        $$ = strdup(buffer);
                    }
                |  /*empty*/                                                            {sprintf(buffer,""); $$ = strdup(buffer);}
                ;
                
MainClass    : 	CLASS IDENTIFIER '{'                                                    
                    PUBLIC STATIC VOID IDENTIFIER '(' STRING  '['']' IDENTIFIER ')' '{' 
                        IDENTIFIER '.' IDENTIFIER '.' IDENTIFIER '(' Expr ')'';' 
                    '}' 
                '}'    
                {   
                    if((strcmp($15,"System") & strcmp($17,"out")  & strcmp($19,"println")) == 0) {
                        sprintf (buffer ,"class %s {\n\t public static void main (String [] %s  {\n\t\tSystem.out.println(%s); \n\t} \n}\n",$2,$12,$21);
                        $$ = strdup(buffer);
                    } else yyerror("ERROR : System.out.println not found.\n")  
                }
            ;

TypeDeclarationList : TypeDeclarationList CLASS IDENTIFIER '{' VariableDeclarations MethodDeclarations '}'      
                      {
                          sprintf(buffer,"%sclass %s {\n%s%s\n}\n",$1,$3,$5,$6); 
                          $$ = strdup(buffer);
	                  }
	                | TypeDeclarationList CLASS IDENTIFIER EXTENDS IDENTIFIER '{' VariableDeclarations MethodDeclarations '}' 
	                    {
                          sprintf(buffer,"%sclass %s extends %s {\n%s%s\n}\n",$1,$3,$5,$7,$8); 
                          $$ = strdup(buffer);
	                    }
                    | /*empty*/              {sprintf(buffer,""); $$ = strdup(buffer);}
                    ;

VariableDeclarations :  VariableDeclarations Type IDENTIFIER ';'    {sprintf(buffer,"%s %s %s;\n",$1,$2,$3); $$ = strdup(buffer);}
                     | /*empty*/             {sprintf(buffer,""); $$ = strdup(buffer);}
                     ;

MethodDeclarations : MethodDeclarations PUBLIC Type IDENTIFIER '(' Arguments ')' '{' VariableDeclarations Statements RETURN Expression ';' '}' 
                    {
                        sprintf(buffer,"%spublic %s %s(%s) {\n%s%s \n return %s;\n}\n",$1,$3,$4,$6,$9,$10,$12); 
                        $$ = strdup(buffer);
                    } 
                  | MethodDeclarations PUBLIC Type IDENTIFIER '(' Arguments ')' '{' VariableDeclarations Statements RETURN PrimaryExpression ';' '}' 
                    {
                        sprintf(buffer,"%s public %s %s(%s) {\n%s %s \n return %s;\n}\n",$1,$3,$4,$6,$9,$10,$12); 
                        $$ = strdup(buffer); 
                    } 
                  | /*empty*/                {sprintf(buffer,""); $$ = strdup(buffer);}
                    
                   ;
Arguments	: /* Empty */                     {sprintf(buffer,""); $$ = strdup(buffer);}
	  	| Type IDENTIFIER MoreArguments     {sprintf(buffer,"%s %s %s",$1,$2,$3); $$ = strdup(buffer);}
	  	;
	  	
MoreArguments : MoreArguments ',' Type IDENTIFIER   {sprintf(buffer,"%s, %s %s",$1,$3,$4); $$ = strdup(buffer);}
	      | /*Empty*/                         {sprintf(buffer,""); $$ = strdup(buffer);}
	      ;

Type 	: INT '[' ']'                           {sprintf(buffer,"int []"); $$ = strdup(buffer);}
	| BOOLEAN                                   {sprintf(buffer,"boolean"); $$ = strdup(buffer);}
	| INT                                       {sprintf(buffer,"int"); $$ = strdup(buffer);}
	| IDENTIFIER                                {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
	;

Statements : Statement Statements               {sprintf(buffer,"%s%s",$1,$2); $$=strdup(buffer);}
           | /*empty*/                          {sprintf(buffer,"");$$=strdup(buffer);}
           ;
              
Statement : '{'  Statements  '}'                                            {sprintf(buffer,"{\n%s\n}\n",$2); $$ = strdup(buffer);}
	  | IDENTIFIER '=' Expr ';'                                             {sprintf(buffer,"%s = %s;\n",$1,$3); $$ = strdup(buffer);}
	  | IDENTIFIER '[' Expr ']' '=' Expr ';'                                {sprintf(buffer,"%s[%s] = %s;\n",$1,$3,$6); $$ = strdup(buffer);}
	  | IF '(' Expr ')' Statement                                           {sprintf(buffer,"if (%s) %s",$3,$5); $$ = strdup(buffer);}
	  | IF '(' Expr ')' Statement ELSE Statement                            {sprintf(buffer,"if (%s) %selse %s",$3,$5,$7); $$ = strdup(buffer);}
      | WHILE '(' Expr ')' Statement                                        {sprintf(buffer,"while (%s) %s\n",$3,$5); $$ = strdup(buffer);}
      | IDENTIFIER dotIdentifiers '('  ')' ';'                              
      {
          if(strcmp($2,"")!=0) { 
            yyerror("");
          } else {
            int i = 0;
            int location = -1;
            for(i=0; i<totalMacros; i++) {
            	if(strcmp(macroName[i],$1) == 0) {
            		location = i;
            		i = totalMacros+1;
            	}
            }
            if(i==totalMacros) 
                yyerror("Macro not defined\n");
            else if (noOfArguments[location] != 0) {
                yyerror("Overloading not allowed");
            }
            else {
                if(i==totalMacros+2)
                  sprintf(buffer,"%s",macroExpansion[location]); 
                $$ = strdup(buffer);
            }
          }
      }
      
      |	IDENTIFIER dotIdentifiers '(' Expr MoreExpressions ')' ';'          
      {
          if(strcmp($2,"")!=0)
           { 
          
                if((strcmp($2,"out.println") && strcmp($5,"")) == 0) {
                    sprintf(buffer,"%s%s(); \n",$1,$2);
                    $$ = strdup(buffer);
                }
                else yyerror("Crap");
          }
          else {
            int i = 0;
		    int location = -1;
		    for(i=0; i<totalMacros; i++) {
		    	if(strcmp(macroName[i],$1) == 0) {
		    		location = i;
		    		i = totalMacros+1;
		    	}
		    }
		    if(i==totalMacros) { 
		        yyerror("Macro undefined");
            }
            
            //Otherwise storing parameters
            char tempStorage[20][10];
            sprintf(tempStorage[0], "%s",$4);
            int number = 1;
            int temp =strlen(tempStorage[0]);
            //Could have used srtok (Stupid me!)
            for(i=0;i<=strlen($5);i++) {
                if($5[i] == ',') {
                    tempStorage[number-1][temp++] = '\0';
                    number++;
                    temp=0;
                } else{
                    if($5[i]!=' '||'\0')
                    tempStorage[number-1][temp++] = $5[i]; 
                }
            }
            //Find and replace parameters
            int j; 
            sprintf(buffer, "%s",macroExpansion[location]);
            if(noOfArguments[location] == number) {
                for(j = 0 ; j < number ; j++) { 
                    char* tempBuffer = malloc(4000);
                    char* subString;
                    subString = strstr(buffer, arguments[location][j]);
                    if(subString == NULL) break;
                    while (1){
                        strncpy(tempBuffer, buffer, subString-buffer);  
                        tempBuffer[subString-buffer] = 0;
                        sprintf(tempBuffer+(subString-buffer), "%s%s", tempStorage[j], subString+strlen(arguments[location][j]));
                        strcpy(buffer, tempBuffer);
                        if (strlen(tempStorage[j]) >= strlen(subString) )
                            break;
                        if (!(subString = strstr(subString+strlen(tempStorage[j]), arguments[location][j])))
                            break;
                    }
                    free(tempBuffer);
                }
                $$ = strdup(buffer);
      	    }
      	    else yyerror("");
  	    }          
      
      }
      ;

Expr : Expression                                                                       {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
     | PrimaryExpression                                                                {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
     ;

dotIdentifiers : dotIdentifiers '.' IDENTIFIER                                          {sprintf(buffer,"%s.%s",$1,$3); $$ = strdup(buffer);}
               | /*Empty*/                                                              {sprintf(buffer,""); $$ = strdup(buffer);}
	  ;

Expression  :   PrimaryExpression '&' PrimaryExpression                                 {sprintf(buffer,"%s & %s",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '<' PrimaryExpression                                 {sprintf(buffer,"%s < %s",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '+' PrimaryExpression                                 {sprintf(buffer,"%s + %s",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '-' PrimaryExpression                                 {sprintf(buffer,"%s - %s",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '*' PrimaryExpression                                 {sprintf(buffer,"%s * %s",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '/' PrimaryExpression                                 {sprintf(buffer,"%s / %s",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '[' PrimaryExpression ']'                             {sprintf(buffer,"%s [ %s ]",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '.' IDENTIFIER                       {if(strcmp($3,"length")==0) {sprintf(buffer,"%s.%s",$1,$3); $$ = strdup(buffer);} else yyerror("length not found");}
            |	PrimaryExpression '.' IDENTIFIER '(' Expr MoreExpressions ')'      {sprintf(buffer,"%s.%s(%s%s)",$1,$3,$5,$6);$$ = strdup(buffer);}
            |   PrimaryExpression '.' IDENTIFIER '(' ')'                                {sprintf(buffer,"%s.%s()",$1,$3); $$ = strdup(buffer);}
            |	IDENTIFIER '(' Expr MoreExpressions ')'/* Macro expr call */               
                {
                    int i = 0;
				    int location = -1;
				    for(i=0; i<totalMacros || i == -1; i++) {
				    	if(strcmp(macroName[i],$1) == 0) {
				    		location = i;
				    		i = totalMacros+1;
				    	}
				    }
				    if(i==totalMacros) { 
				        yyerror("Macro undefined");
                    }
                    //Otherwise storing parameters
                    char tempStorage[20][10];
                    sprintf(tempStorage[0], "%s",$3);
                    int number = 1;
                    int temp =strlen(tempStorage[0]);
                    for(i=0;i<=strlen($4);i++) {
                        if($4[i] == ',') {
                            tempStorage[number-1][temp++] = '\0';
                            number++;
                            temp=0;
                        } else{
                            if($4[i]!=' '||'\0')
                            tempStorage[number-1][temp++] = $4[i]; 
                        }
                    }
                    //Find and replace parameters
                    int j; 
                    sprintf(buffer, "%s",macroExpansion[location]);
                    if(noOfArguments[location] == number) {
                        for(j = 0 ; j < number ; j++) { 
                            char* tempBuffer = malloc(4000);
                            char* subString;
                            subString = strstr(buffer, arguments[location][j]);
                            if(subString == NULL) break;
                            while (1){
                                strncpy(tempBuffer, buffer, subString-buffer);  
                                tempBuffer[subString-buffer] = 0;
                                sprintf(tempBuffer+(subString-buffer), "%s%s", tempStorage[j], subString+strlen(arguments[location][j]));
                                strcpy(buffer, tempBuffer);
                                if (strlen(tempStorage[j]) >= strlen(subString) )
                                    break;
                                if (!(subString = strstr(subString+strlen(tempStorage[j]), arguments[location][j])))
                                    break;
                            }
                            free(tempBuffer);
                        }
                        $$ = strdup(buffer);
                    }
                    else yyerror("");
              	}
          	    
          	    |   IDENTIFIER '('  ')'                                                     
               	    {
                        int i = 0;
					    int location = -1;
					    for(i=0; i<totalMacros || i == -1; i++) {
					    	if(strcmp(macroName[i],$1) == 0) {
					    		location = i;
					    		i = totalMacros+1;
					    	}
					    }
					    if(i==totalMacros) 
					        yyerror("Macro not defined");
                        else if (noOfArguments[location] != 0) {
                           yyerror("Overloading not allowed");
                        }else {
                            if(i==totalMacros+2)
					          sprintf(buffer,"%s",macroExpansion[location]); 
                            $$ = strdup(buffer);
                        }
                    }
            
            
            ;
MoreExpressions : /*empty*/                                         {sprintf(buffer,""); $$ = strdup(buffer);}
                | MoreExpressions ',' Expr                          {sprintf(buffer,"%s , %s",$1,$3); $$ = strdup(buffer);}
                ;

PrimaryExpression: INTVAL                       {sprintf(buffer,"%d",$1); $$ = strdup(buffer);}
                 | '+' INTVAL                   {sprintf(buffer,"%d",$2); $$ = strdup(buffer);}
                 | '-' INTVAL                   {sprintf(buffer,"%d",-($2)); $$ = strdup(buffer);}
                 | BOOLVAL                      {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
                 | IDENTIFIER                   {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
                 | THIS                         {sprintf(buffer,"this");  $$ = strdup(buffer);}
                 | NEW INT '[' Expr ']'         {sprintf(buffer,"new int [ %s ]",$4); $$ = strdup(buffer);}
                 | NEW IDENTIFIER '(' ')'       {sprintf(buffer,"new %s ()",$2); $$ = strdup(buffer);}
                 | '!' Expr                     {sprintf(buffer,"!%s",$2); $$ = strdup(buffer);}
                 | '(' Expr ')'                 {sprintf(buffer,"(%s)",$2); $$ = strdup(buffer);}
                 ;

%%
main(){
	// parse through the input until there is no more.
	do {
		yyparse();
	} while (!feof(yyin));
}

void yyerror(const char *s){
	printf ("// Failed to parse macrojava code.\n",s)	;
	exit(1);
}
