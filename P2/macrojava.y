%{
#include<stdio.h>
#include<stdlib.h>
extern FILE* yyin;
void yyerror(const char *s);
extern int yyparse();
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

%initial-action {
char* buffer = (char *)malloc(100000*sizeof(char));
}

%% 

// Grammar section.  Add your rules here.
// Example rule to parse empty classes. 
//macrojava: CLASS IDENTIFIER '{' '}' { printf ("Parsed the empty class successfully!");}
Goal        : Macros MainClass TypeDeclarationList                                      {sprintf(stdin,"%s %s %s",$1,$2,$3)}
            ;
      
          
Macros      : Macros MacroExpression                                                    {sprintf(buffer,"%s %s",$1,$2); $$ = strdup(buffer);}
            | Macros MacroStatement                                                     {sprintf(buffer,"%s %s",$1,$2); $$ = strdup(buffer);}
            | /*empty*/                                                                 {sprintf(buffer,""); $$ = strdup(buffer);}
            ;
            
MacroStatement  : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '{' Statements '}'       {sprintf(buffer,"#define %s(%s) {%s}",$3,$5,$8); $$ = strdup(buffer);}
                ;

MacroExpression : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '(' Expression ')'       {sprintf(buffer,"#define %s(%s) {%s}",$3,$5,$8); $$ = strdup(buffer);}
                ;  

IdentifierList  :  IDENTIFIER MoreIdentifiers                                           {sprintf(buffer,"%s %s",$1,$2); $$ = strdup(buffer);}
                |  /*empty*/                                                            {sprintf(buffer,""); $$ = strdup(buffer);}
                ;

MoreIdentifiers :  MoreIdentifiers "," IDENTIFIER                                       {sprintf(buffer,"%s, %s",$1,$3); $$ = strdup(buffer);}
                |  /*empty*/                                                            {sprintf(buffer,""); $$ = strdup(buffer);}
                ;
                
MainClass    : 	CLASS IDENTIFIER '{'                                                    
                    PUBLIC STATIC VOID IDENTIFIER '(' STRING  '['']' IDENTIFIER ')' '{' 
                        IDENTIFIER '.' IDENTIFIER '.' IDENTIFIER '(' Expression ')'';' 
                    '}' 
                '}'    
                {   
                    if( (strcmp($15,"System") & strcmp($17,"out")  & strcmp($19,"println")) == 0) {
                        sprintf (buffer ,"class %s {\n\t public static void main (String [] %s  {\n\t\tSystem.out.println(\"Expression \" ); \n\t} \n}",$2,$12);
                        $$ = strdup(buffer);
                    } else yyerror("ERROR : System.out.println not found.\n")  
                }
            ;

TypeDeclarationList : TypeDeclarationList CLASS IDENTIFIER '{' VariableDeclarations MethodDeclarations '}'      
                      {
                          sprintf(buffer,"%s class %s {\n\t %s \n\n\t %s }\n",$1,$3,$5,$6); 
                          $$ = strdup(buffer);
	                  }
	                | TypeDeclarationList CLASS IDENTIFIER EXTENDS IDENTIFIER '{' VariableDeclarations MethodDeclarations '}' 
	                {
                          sprintf(buffer,"%s class %s extends %s {\n\t %s \n\n\t %s }\n",$1,$3,$5,$7,$8); 
                          $$ = strdup(buffer);
	                  }
                    | /*empty*/              {sprintf(buffer,""); $$ = strdup(buffer);}
                    ;

VariableDeclarations :  VariableDeclarations Type IDENTIFIER ';'    {sprintf(buffer,"%s %s %s;\n",$1,$2,$3); $$ = strdup(buffer);}
                     | /*empty*/             {sprintf(buffer,""); $$ = strdup(buffer);}
                     ;

MethodDeclarations : MethodDeclarations PUBLIC Type IDENTIFIER '(' Arguments ')' '{' VariableDeclarations Statements RETURN Expression ';' '}' 
                    {
                        sprintf(buffer,"%s public %s %s %s(%s) {%s %s return %s;\n}",$1,$3,$4,$5,$6,$9,$10,$12); 
                        $$ = strdup(buffer);
                    } 
                  | MethodDeclarations PUBLIC Type IDENTIFIER '(' Arguments ')' '{' VariableDeclarations Statements RETURN PrimaryExpression ';' '}' {} 
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


Statements : '{'  Statements  '}' Statements                                            {sprintf(buffer,"{\n %s } %s",$2, $4); $$ = strdup(buffer);}
	  | IDENTIFIER '=' Expr ';' Statements {}                                           {sprintf(buffer,"%s = %s ;\n %s",$1,$3,$5); $$ = strdup(buffer);}
	  | IDENTIFIER '[' Expr ']' '=' Expr ';' Statements {}                              {sprintf(buffer,"%s[%s] = %s; %s",$1,$3,$6,$8); $$ = strdup(buffer);}
	  | IF '(' Expr ')' Statements                                                      {sprintf(buffer,"if (%s) %s",$3,$5); $$ = strdup(buffer);}
	  | IF '(' Expr ')' Statements ELSE Statements                                      {sprintf(buffer,"if (%s) %s else %s",$1); $$ = strdup(buffer);}
      | WHILE '(' Expr ')' Statements                                                   {sprintf(buffer,"while (%s) %s; \n %s",$1,$5); $$ = strdup(buffer);}
      | IDENTIFIER dotIdentifiers '('  ')' ';' Statements                               {sprintf(buffer,"%s%s(); \n %s",$1,$2,$6); $$ = strdup(buffer);}
      |	IDENTIFIER dotIdentifiers '(' Expr MoreExpressions ')' ';' Statements            {sprintf(buffer,"%s%s(%s %s); \n %s",$1,$2,$4,$5,$8); $$ = strdup(buffer);}
      | /*empty*/                                                                        {sprintf(buffer,""); $$ = strdup(buffer);}
      | ';'                                                                              {sprintf(buffer,";"); $$ = strdup(buffer);}
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
            |	PrimaryExpression '.' IDENTIFIER                                        {sprintf(buffer,"%s.%s",$1,$3); $$ = strdup(buffer);}
            |	PrimaryExpression '.' IDENTIFIER '(' Expr MoreExpressions ')'           {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
            |   PrimaryExpression '.' IDENTIFIER '(' ')'                                {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
            |	IDENTIFIER '(' Expression ')'/* Macro expr call */                      {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
            |   IDENTIFIER '('  ')'                                                     {sprintf(buffer,"%s ()",$1); $$ = strdup(buffer);}
            ;

MoreExpressions : /*empty*/                                         {sprintf(buffer,""); $$ = strdup(buffer);}
                | MoreExpressions ',' Expr                          {sprintf(buffer,"%s , %s",$1,$2); $$ = strdup(buffer);}
                ;

PrimaryExpression: INTVAL                       {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
                 | BOOLVAL                      {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
                 | IDENTIFIER                   {sprintf(buffer,"%s",$1); $$ = strdup(buffer);}
                 | THIS                         {sprintf(buffer,"this");  $$ = strdup(buffer);}
                 | NEW INT '[' Expr ']'         {sprintf(buffer,"new int [ %s ]",$4); $$ = strdup(buffer);}
                 | NEW IDENTIFIER '(' ')'       {sprintf(buffer,"new %s ()",$2); $$ = strdup(buffer);}
                 | '!' Expr                     {sprintf(buffer,"!%s",$2); $$ = strdup(buffer);}
                 | '(' Expression ')'           {sprintf(buffer,"(%s)",$2); $$ = strdup(buffer);}
                 | '(' PrimaryExpression ')'    {sprintf(buffer,"(%s)",$2); $$ = strdup(buffer);}
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
