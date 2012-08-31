%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

extern FILE* yyin;
void yyerror(const char *s);
extern int yyparse();
char* buffer;
char macroExpressionName [20][100];
static char macroExpressionExpansion [20][150];

int noOfArguments[20];
char arguments [20][10][50];
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

Goal        : Macros MainClass TypeDeclarationList                                      {printf("%s%s%s",$1,$2,$3);
}
            ;
      
          
Macros      : MacroExpression Macros                                                   {sprintf(buffer,"%s%s",$1,$2); $$ = strdup(buffer);}
            | MacroStatement Macros                                                     {sprintf(buffer,"%s%s",$1,$2); $$ = strdup(buffer);}
            | /*empty*/                                                                 {sprintf(buffer,"\n"); $$ = strdup(buffer);}
            ;
            
MacroStatement  : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '{' Statements '}'       
                  {
                    totalMacros++;
                    sprintf(buffer,"#define %s(%s) {%s}\n",$3,$5,$8); 
                    $$ = strdup(buffer);
                  }
                ;

MacroExpression : '#' DEFINE IDENTIFIER '(' IdentifierList ')' '(' Expr ')'       
                    {
                        totalMacros++;
                        strcpy(macroExpressionName[totalMacros-1],$3);
                        int args = noOfIdentifiers;
                        noOfArguments[totalMacros-1] = args;  
                        sprintf(buffer,"#define %s(%s) (%s)\n",$3,$5,$8);
			printf("MacroName : %s\n",macroExpressionName[totalMacros-1]);
			printf("Total Number of Arguments : %d\n", noOfArguments[totalMacros-1]);
			if(noOfArguments[totalMacros-1] > 0) printf("The Arguments are : \n");
			for(args = 0; args < noOfArguments[totalMacros-1] ; args++)
				printf("%d : %s\n",args, arguments[totalMacros-1][args]);
			noOfIdentifiers = 0;
			sprintf(macroExpressionName[totalMacros-1],"%s",$8);
			printf("Macro Expansion : %s\n",macroExpressionName[totalMacros-1]);
			$$ = strdup(buffer); 
                    }
                ;  

IdentifierList  :  IDENTIFIER MoreIdentifiers                                           
                    {
			sprintf(arguments[totalMacros][noOfIdentifiers],"%s",$1);
			noOfIdentifiers++;
                        sprintf(buffer,"%s %s",$1,$2);
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
                        IDENTIFIER '.' IDENTIFIER '.' IDENTIFIER '(' Expression ')'';' 
                    '}' 
                '}'    
                {   
                    if( (strcmp($15,"System") & strcmp($17,"out")  & strcmp($19,"println")) == 0) {
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
      | IDENTIFIER dotIdentifiers '('  ')' ';'                              {sprintf(buffer,"%s%s(); \n",$1,$2); $$ = strdup(buffer);}
      |	IDENTIFIER dotIdentifiers '(' Expr MoreExpressions ')' ';'          {sprintf(buffer,"%s%s(%s%s); \n",$1,$2,$4,$5); $$ = strdup(buffer);}
      | ';'                                                                 {sprintf(buffer,";"); $$ = strdup(buffer);}
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
            |	PrimaryExpression '.' IDENTIFIER '(' Expr MoreExpressions ')'      {sprintf(buffer,"%s.%s(%s%s)",$1,$3,$5,$6);$$ = strdup(buffer);}
            |   PrimaryExpression '.' IDENTIFIER '(' ')'                                {sprintf(buffer,"%s.%s()",$1,$3); $$ = strdup(buffer);}
            |	IDENTIFIER '(' Expr MoreExpressions ')'/* Macro expr call */                      
                {
                /*sprintf(buffer,"%s(%s)",$1,$3);*/
                  sprintf(buffer,"MACRO TO BE REPLACED HERE");
                  $$ = strdup(buffer);
                }
            
            |   IDENTIFIER '('  ')'                                                     
                {
                    //sprintf(buffer,"%s ()",$1);
                      sprintf(buffer,"MACRO TO BE REPLACED HERE"); 
                     $$ = strdup(buffer);
                }
            ;

MoreExpressions : /*empty*/                                         {sprintf(buffer,""); $$ = strdup(buffer);}
                | MoreExpressions ',' Expr                          {sprintf(buffer,"%s , %s",$1,$3); $$ = strdup(buffer);}
                ;

PrimaryExpression: INTVAL                       {sprintf(buffer,"%d",$1); $$ = strdup(buffer);}
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
	printf ("Parse error: %s\n" , s)	;
}
