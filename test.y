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
%type <text> in
%type <text> conjuntoop1
%type <text> pertinencia
%type <text> tipagem
%type <text> inclusao
%type <text> remocao
%type <text> selecao
%type <text> iteracao
%type <text> function_call
%type <text> args
%type <text> variable_declaration
%type <text> mathop1
%type <text> mathop2
%type <text> matharg







%%
statement: 
		assignment SEMICOLON statement
	|	function_declaration statement
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
		ID
	|	OPENPAR comparison CLOSEPAR
	|	NUM
	;

comparison:
		NOT comparg
	|	comparg AND comparg
	|	comparg OR comparg
	|	comparg GREATER comparg
	|	comparg GE comparg
	|	comparg LESS comparg
	|	comparg LE comparg
	|	comparg EQ comparg
	|	comparg NEQ comparg
	;

read:
		READ OPENPAR ID CLOSEPAR
	;

write:
		WRITE OPENPAR ID CLOSEPAR
	|	WRITE OPENPAR mathop CLOSEPAR
	|	WRITE OPENPAR NUM CLOSEPAR
	|	WRITE OPENPAR  STRING  CLOSEPAR
	;


writeln:
		WRITELN OPENPAR ID CLOSEPAR
	|	WRITELN OPENPAR mathop CLOSEPAR
	|	WRITELN OPENPAR NUM CLOSEPAR
	|	WRITELN OPENPAR  STRING  CLOSEPAR
	;
in:
		ID IN ID
	|	ID IN conjuntoop
	;

return:
		RETURN ID
	|	RETURN NUM
	|	RETURN function_call
	|	RETURN comparison
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


args:
		args COMMA args
	|	ID
	|	NUM
	;

function_declaration:
		type ID OPENPAR args CLOSEPAR OPENBRAC statement CLOSEBRAC
	;
	
	
assignment:
		ID ASSIGN NUM
	|	ID ASSIGN ID
	;

variable_declaration:
		INT ID SEMICOLON
	|	FLOAT ID SEMICOLON
	|	SET ID SEMICOLON
	|	ELEM ID SEMICOLON
	;

mathop:
		mathop PLUS mathop1
	|	mathop MINUS mathop1
	|	mathop1
	;

mathop1:
		mathop1 AST mathop2
	|	mathop1 BS mathop2
	|	mathop2
	;


mathop2:
		matharg
	|	OPENPAR mathop CLOSEPAR
	;

matharg:
		ID
	|	NUM
	|	function_call
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

