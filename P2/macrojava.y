%{
#include<stdio.h>
int i = 1;
extern FILE* yyin;

extern int yyparse();
%}

%union{
	int ival; // integers
	char *bval;// true and false
	char  *kw; // such as class, int, boolean etc
	char *op; // such as +, -, * etc
	char *id; // identifiers
}

%token <ival> INTVAL
%token <bval> BOOLVAL
%token <kw> KEYWORD
%token <op> OPERATOR
%token <id> IDENTIFIER
%token END_OF_FILE
%token THIS
%token MAIN
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
%token LENGTH
%token SYSTEM
%token OUT
%token PRINTLN
%left '<' '>' '=' NE LE GE
%left '+' '-'
%left '*' '/' '%'
//%type <bval> BE
//%type <bval> PE2
//%type <ival> PE1
%type <ival> IE
%type <ival> IT
%type <ival> INTF

%% 

// Grammar section.  Add your rules here.
// Example rule to parse empty classes. 
//macrojava: CLASS IDENTIFIER '{' '}' { printf ("Parsed the empty class successfully!");}
G : M Tstar END_OF_FILE
M  : 	CLASS IDENTIFIER '{' PUBLIC STATIC VOID MAIN '(' STRING '['']' IDENTIFIER ')' '{' SYSTEM'.'OUT'.'PRINTLN '(' IE ')'';' '}' '}' { printf ("class %s {\n\t public static void main (String [] %s {\n\t\tSystem.out.println(\"Expression is : %d \" ); \n\t} \n}",$2,$12,$21);}
    ;

T 	 : 	CLASS IDENTIFIER '{' TIstar MEstar '}'{printf("Applying production T");}
	 | 	CLASS IDENTIFIER EXTENDS IDENTIFIER '{' TIstar MEstar "}"   {printf("Applying production T");}
     ;

Tstar : Tstar T 
      |
      ;

Type :	INT '[' ']' 
	 | 	BOOLEAN
	 | 	INT 
	 | 	IDENTIFIER  
	 ;

TIstar : TIstar Type IDENTIFIER ';' 
     |
     ;
     
commaTIstar  : commaTIstar ',' Type IDENTIFIER 
             | 
             ;

args  :    
      | Type IDENTIFIER commaTIstar
      ;
ME 	 : 	PUBLIC Type IDENTIFIER '(' args ')' '{' TIstar StatementStar RETURN IE ';' '}'   
     ;   
     
MEstar : MEstar ME  {printf("Applying production Mestar");}
       |
       ;
  
IE   : IE '+' IT 		{$$ = $1+$3;printf("----%d----\n",$$);}
	 | IE '-' IT	    {$$ = $1-$3;printf("----%d----\n",$$);}
     | IT			    {$$=$1;}
     ;

IT   : INTF			{$$=$1;}
     | IT '*' INTF		{ $$ = $1 * $3;printf("----%d----\n",$$);} 
     | IT '/' INTF      { $$ = $1 / $3; printf("----%d----\n",$$);}
     | IT '%' INTF      {$$ = $1 % $3;printf("----%d----\n",$$);} 	
     ;

INTF : INTVAL		{$$=$1;}
     | '(' IE ')'		{$$=$2;}
     ; 
     /*
PE2 :   BOOLVAL         {$$ = $1;}
    ;
PE3 :   IDENTIFIER      //{$$ = $1;}
	| 	THIS            //{$$ = $1;}
	| 	NEW INT '[' PE1 ']'  // {$$ = $1;}
	| 	NEW IDENTIFIER '(' ')'  //{$$ = $1;}
	| 	'!' PE3         //  {$$ = !($2);}
	| 	'(' PE3 ')'      // {$$ = $2;}
    ;*/

Statement 	: 	'{' StatementStar '}'
	| 	IDENTIFIER '=' IE ';'                    
	| 	IDENTIFIER '[' IE ']' '=' IE ';'
	|   IF '(' IE ')' Statement //Resolve the if then else conflict.
	| 	WHILE '(' IE ')' Statement
    ;
/*    
Temp :
     | ELSE Statement
     ;
     */
StatementStar : Statement StatementStar
              |
  /*
E : BE  {printf ("Came to boolean\n");}
    | IE    {printf("Came to arithmetic\n");
    ;
  
BE  :   PE2 '&' PE2       { if($1=="true" && $3=="true") $$ ="true"; else $$="false";}
    | 	PE1 '<' PE1       { $$ = $1 < $3;}
    ; */


    /*
    | 	PE1 '[' PE1 ']'       //{ $$ = $1[$3];}
    | 	PE3 '.' LENGTH       
    | 	PE1 '.' IDENTIFIER '(' something ')'       //{ $$ = $1.$3($5); }
    ;
    
something :	 
        | blah E
        ;
blah : ',' E blah
     |
    ;
 */
%%
main(){
	// parse through the input until there is no more.
	do {
		yyparse();
	} while (!feof(yyin));
}

void yyerror(const char *s){
	printf ("Parse error: %s\n" , s)	;
}
