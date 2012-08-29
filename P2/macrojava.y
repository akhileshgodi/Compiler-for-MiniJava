%{
#include<stdio.h>
#include<stdlib.h>
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

%left '<' '>' '=' NE LE GE
%left '+' '-'
%left '*' '/' '%'


%% 

// Grammar section.  Add your rules here.
// Example rule to parse empty classes. 
//macrojava: CLASS IDENTIFIER '{' '}' { printf ("Parsed the empty class successfully!");}
Goal        : Macros MainClass TypeDeclarationList
            ;
      
          
Macros      : Macros MacroExpression
            | Macros MacroStatement
            | /*empty*/
            ;
            
MacroStatement  : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '{' Statements '}'
                ;

MacroExpression : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '(' Expression ')'
                ;  

IdentifierList  :  IDENTIFIER MoreIdentifiers
                |  /*empty*/
                ;

MoreIdentifiers :  MoreIdentifiers "," IDENTIFIER
                |  /*empty*/
                ;
                
MainClass    : 	CLASS IDENTIFIER '{'
                    PUBLIC STATIC VOID IDENTIFIER '(' STRING  '['']' IDENTIFIER ')' '{' 
                        IDENTIFIER '.' IDENTIFIER '.' IDENTIFIER '(' Expression ')'';' 
                    '}' 
                '}'    {   printf( "==== %d ==== ", strcmp($15,"System") & strcmp($17,"out")  & strcmp($19,"println") );
                if( (strcmp($15,"System") & strcmp($17,"out")  & strcmp($19,"println")) == 0)
                        printf ("class %s {\n\t public static void main (String [] %s  {\n\t\tSystem.out.println(\"Expression \" ); \n\t} \n}",$2,$12);
                  }
            ;

TypeDeclarationList : TypeDeclarationList CLASS IDENTIFIER '{' VariableDeclarations MethodDeclarations '}'
	                | TypeDeclarationList CLASS IDENTIFIER EXTENDS IDENTIFIER '{' VariableDeclarations MethodDeclarations '}' 
                    | /*empty*/
                    ;

VariableDeclarations :  VariableDeclarations Type IDENTIFIER ';'
                     | /*empty*/
                     ;

MethodDeclarations : MethodDeclarations PUBLIC Type IDENTIFIER '(' Arguments ')' '{' VariableDeclarations Statements RETURN Expression ';' '}' {} 
                  | MethodDeclarations PUBLIC Type IDENTIFIER '(' Arguments ')' '{' VariableDeclarations Statements RETURN PrimaryExpression ';' '}' {} 
                  | /*empty*/
                    
                   ;
Arguments	: /* Empty */
	  	| Type IDENTIFIER MoreArguments
	  	;
	  	
MoreArguments : MoreArguments ',' Type IDENTIFIER
	      | /*Empty*/
	      ;

Type 	: INT '[' ']' 
	| BOOLEAN
	| INT 
	| IDENTIFIER  
	;


Statements : '{'  Statements  '}' Statements
	  | IDENTIFIER '=' Expr ';' Statements {}
	  | IDENTIFIER '[' Expr ']' '=' Expr ';' Statements {}
	  | IF '(' Expr ')' Statements
	  | IF '(' Expr ')' Statements ELSE Statements
      | WHILE '(' Expr ')' Statements
      | IDENTIFIER dotIdentifiers '('  ')' ';' Statements
      |	IDENTIFIER dotIdentifiers '(' Expr MoreExpressions ')' ';' Statements
      | /*empty*/
      | ';'
      ;

Expr : Expression
     | PrimaryExpression
     ;

dotIdentifiers : dotIdentifiers '.' IDENTIFIER
               | /*Empty*/      
	  ;

Expression  :   PrimaryExpression '&' PrimaryExpression
            |	PrimaryExpression '<' PrimaryExpression
            |	PrimaryExpression '+' PrimaryExpression
            |	PrimaryExpression '-' PrimaryExpression
            |	PrimaryExpression '*' PrimaryExpression
            |	PrimaryExpression '/' PrimaryExpression
            |	PrimaryExpression '[' PrimaryExpression ']'
            |	PrimaryExpression '.' IDENTIFIER //This identifier is length
            |	PrimaryExpression '.' IDENTIFIER '(' Expr MoreExpressions ')'
            |   PrimaryExpression '.' IDENTIFIER '(' ')'
            |	IDENTIFIER '(' Expression ')'/* Macro expr call */
            |   IDENTIFIER '('  ')'
            ;

MoreExpressions : /*empty*/
                | MoreExpressions ',' Expr
                ;

PrimaryExpression: INTVAL
                 | BOOLVAL
                 | IDENTIFIER 
                 | THIS
                 | NEW INT '[' Expr ']'
                 | NEW IDENTIFIER '(' ')'
                 | '!' Expr
                 | '(' Expression ')'
                 | '(' PrimaryExpression ')'
                 ;

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
