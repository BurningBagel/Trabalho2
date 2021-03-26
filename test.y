%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int yyerror(char *s);
int yylex(void);


struct simbolo{
	simbolo* anterior;
	simbolo* seguinte;
	char nome[50];
	char valor[50];
	};
	
simbolo* tabelaSimbolos;
	
simbolo* CriarSimbolo(simbolo* ant){
	simbolo *ancora = (simbolo*)malloc(sizeof(simbolo));
	(*ancora).anterior = ant;
	(*ancora).seguinte = NULL;
	return ancora;
}
	
simbolo* RemoverSimbolo(simbolo* alvo){//retorna ponteiro para o próximo simbolo caso esteja removendo de algum lugar que não seja o fim da tabela
	simbolo *ancora = (*alvo).seguinte;
	free(alvo);
	return ancora;
}
	
simbolo* ProcurarTabela(char *nome){
	simbolo *ancora = tabelaSimbolos;
	while(ancora != NULL){
		if(!strcmp((*ancora).nome,nome)){
			return ancora;
		}
		ancora = (*ancora).seguinte;
	}
	return NULL;
}
	
	


%}

%union {
	double val;	
	char *text;
	bool boolean;
}

%token <val> NUM
%token <text> STRING
%token <text> CHAR
%token <text> ID
%token <text> INT
%token <text> FLOAT
%token <text> ELEM
%token <text> SET
%token <text> IF
%token <text> ELSE
%token <text> FOR
%token <text> READ
%token <text> WRITE
%token <text> WRITELN
%token <text> IN
%token <text> IS_SET
%token <text> ADD
%token <text> REMOVE
%token <text> EXISTS
%token <text> FORALL
%token <text> RETURN
%token <text> OPENPAR
%token <text> CLOSEPAR
%token <text> OPENCURLY
%token <text> CLOSECURLY
%token <text> OPENBRAC
%token <text> CLOSEBRAC
%token <text> LESS
%token <text> LE
%token <text> EQ
%token <text> NEQ
%token <text> GREATER
%token <text> GE
%token <text> PLUS
%token <text> MINUS
%token <text> DBS
%token <text> AST
%token <text> BS
%token <text> ASSIGN
%token <text> COMMA
%token <text> SEMICOLON
%token <text> OR
%token <text> AND
%token <text> NOT
%token <text> AMP
%token <text> PCENT

%start	statement

%type <text> assignment
%type <text> function_declaration
%type <text> conjuntoop
%type <text> mathop
%type <text> return
%type <text> for
%type <text> if
%type <text> write
%type <text> writeln
%type <text> read
%type <text> comparg
%type <text> comparison
//%type <text> in
%type <text> conjuntoop1
%type <text> pertinencia
%type <text> tipagem
%type <text> inclusao
%type <text> remocao
%type <text> selecao
%type <text> iteracao
%type <text> function_call
%type <text> funcargs
%type <text> args
%type <text> args1
%type <text> variable_declaration
%type <val> mathop1
%type <val> mathop2
%type <val> matharg







%%
statement: 
		assignment SEMICOLON statement
	|	function_declaration statement
	|	variable_declaration statement
	|	conjuntoop SEMICOLON statement
	|	mathop SEMICOLON statement
	|	return SEMICOLON statement
	|	for statement
	|	if statement
	|	write SEMICOLON statement
	|	writeln SEMICOLON statement
	|	read SEMICOLON statement
	|	%empty
	;

comparg:
		ID					{/*olhar na tabela*/}
	|	OPENPAR comparison CLOSEPAR		{$$ = $2;}
	|	NUM					{$$ = ($2 != 0);}
	;

comparison:
		NOT comparg				{$$ = !$2;}
	|	comparg AND comparg			{$$ = $1 && $3;}
	|	comparg OR comparg			{$$ = $1 || $3;}
	|	comparg GREATER comparg		{$$ = $1 > $3;}
	|	comparg GE comparg			{$$ = $1 >= $3;}
	|	comparg LESS comparg			{$$ = $1 < $3;}
	|	comparg LE comparg			{$$ = $1 <= $3;}
	|	comparg EQ comparg			{$$ = $1 == $3;}
	|	comparg NEQ comparg			{$$ = $1 != $3;}
	;

read:
		READ OPENPAR ID CLOSEPAR		{/*ler entrada, guardar?*/}
	;

write:
//		WRITE OPENPAR ID CLOSEPAR
		WRITE OPENPAR mathop CLOSEPAR		{printf("%d",$3);}
//	|	WRITE OPENPAR NUM CLOSEPAR	
	|	WRITE OPENPAR  STRING  CLOSEPAR	{printf("%s",$3);}
	;


writeln:
//		WRITELN OPENPAR ID CLOSEPAR
		WRITELN OPENPAR mathop CLOSEPAR	printf("%d\n",$3);}
//	|	WRITELN OPENPAR NUM CLOSEPAR
	|	WRITELN OPENPAR  STRING  CLOSEPAR	printf("%s\n",$3);}
	;
/*in:
		ID IN ID
	|	ID IN conjuntoop
	;
*/
return:
//		RETURN ID
//	|	RETURN function_call
		RETURN comparison
	|	RETURN mathop
	|	RETURN
	;

for:
		FOR OPENPAR assignment SEMICOLON comparison SEMICOLON assignment CLOSEPAR OPENBRAC statement CLOSEBRAC
	;

if:
		IF OPENPAR comparison CLOSEPAR OPENBRAC statement CLOSEBRAC
	|	IF OPENPAR comparison CLOSEPAR OPENBRAC statement CLOSEBRAC ELSE OPENBRAC statement CLOSEBRAC
	;

conjuntoop:
		pertinencia
	|	tipagem
	|	inclusao
	|	remocao
	|	selecao
	|	iteracao
	;
	
conjuntoop1:
		pertinencia
	|	tipagem
	|	inclusao
	|	remocao
	|	selecao
	|	iteracao
	|	ID
	;

pertinencia:
		mathop IN conjuntoop1
	;

tipagem:
		IS_SET OPENPAR conjuntoop1 CLOSEPAR
	;

inclusao:
		ADD OPENPAR pertinencia CLOSEPAR
	;

remocao:
		REMOVE OPENPAR pertinencia CLOSEPAR
	;
	
	
selecao:
		EXISTS OPENPAR pertinencia CLOSEPAR
	;

iteracao:
		FORALL OPENPAR pertinencia CLOSEPAR OPENBRAC statement CLOSEBRAC
	|	FORALL OPENPAR pertinencia CLOSEPAR statement SEMICOLON
	;

function_call:
		ID OPENPAR args CLOSEPAR SEMICOLON
	;


/*args:
		args COMMA args
	|	ID
	|	NUM
	;
*/
args:
		ID args1		{strcat($1,$2); strcpy($$,$1); free($1);}
	|	NUM args1		{	
						char ancora[50];
						sprintf(ancora,"%d",42);
						strcat(ancora,$2);
						strcpy($$,ancora);
						free(ancora);
					}
	;

args1:
		COMMA args		{strcpy($$,strcat(",",$2)); free($1);}
	|	%empty
	;

funcargs:
		TYPE ID		{
						char ancora[50];
						strcpy(ancora,$1);
						strcat(ancora,",");
						strcat(ancora,$2);
						strcpy($$,ancora);
						free(ancora);
						free($1);
						free($2);
					}
	|	TYPE ID COMMA funcargs	{
						char ancora[50];
						strcpy(ancora,$1);
						strcat(ancora,",");
						strcat(ancora,$2);
						strcat(ancora,"|");
						strcat(ancora,$4);
						strcpy($$,ancora);
						free(ancora);
						free($1);
						free($2);
						free($3);
					}
	|	%empty
	;
	

function_declaration:
		type ID OPENPAR funcargs CLOSEPAR OPENBRAC statement CLOSEBRAC
	;
	
	
assignment:
		ID ASSIGN NUM			{/*mais coisa de tabela de simbolos?*/}
	|	ID ASSIGN ID
	;

variable_declaration:
		type ID SEMICOLON		{/*colocar na tabela de símbolos?*/}
/*		INT ID SEMICOLON
	|	FLOAT ID SEMICOLON
	|	SET ID SEMICOLON
	|	ELEM ID SEMICOLON
*/	;

mathop:
		mathop PLUS mathop1		{$$ = $1 + $3;}
	|	mathop MINUS mathop1 		{$$ = $1 - $3;}
	|	mathop1
	;

mathop1:
		mathop1 AST mathop2		{$$ = $1 * $3;}
	|	mathop1 BS mathop2		{$$ = $1 / $3;}
	|	mathop2
	;


mathop2:
		matharg
	|	OPENPAR mathop CLOSEPAR	{$$ = $2;}
	;

matharg:
		ID				{/*olhar na tabela de simbolos?*/}
	|	NUM
	|	function_call			{$$ = atoi($1);}
	;

type:
		SET
	|	INT
	|	ELEM
	|	FLOAT
	;

%%

int yyerror(char *s){
	extern int yylineo;
	extern char *yytext;

	printf("ERRO %s NO SIMBOLO <%s> na linha <%d>\n",s,yytext,yylineo);
	exit(1);
}

int yyerror(char *s){
	return yyerror(s);
}

int main(int argc, char **argv){
	tabelaSimbolos = (simbolo*)malloc(sizeof(simbolo));
	++argv;
	--argc;//pula o nome do programa
	if (argc > 0){
		yyin = fopen(argv[0],"r");
	}
	else{
		yyin = stdin;
	}
	yyparse();
	fclose(yyin);
	yylex_destroy();
	return 0;
}

