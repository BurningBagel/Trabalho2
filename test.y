%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int yyerror(char *s);
int yylex(void);


//#define ID 1
#define CHAR 2
#define NUM 3
#define STRING 4
#define FUNC 5


struct simbolo{				//elemento da tabela de simbolos. Contém ponteiros para os simbolos seguinte e anterior, o nome do simbolo, o valor associado a ele(em string,se tiver), qual tipo
	simbolo* anterior;		//de simbolo é (vide defines acima), e o tamanho do valor(caso exista)
	simbolo* seguinte;
	char *nome;
	char *valor;
	int tipo;
	int tamanhoValor;
	};
	
simbolo* tabelaSimbolos;
simbolo* topo;
	
simbolo* CriarSimbolo(char* nome, int tipo, char* valor){
	simbolo *ancora = (simbolo*)malloc(sizeof(simbolo));
	(*topo).seguinte = ancora;
	(*ancora).anterior = topo;
	(*ancora).seguinte = NULL;
	(*ancora).tipo = tipo;
	(*ancora).valor = strdup(valor);
	(*ancora).tamanhoValor = strlen(valor);
	topo = ancora;
	return ancora;
}
	
simbolo* RemoverSimbolo(simbolo* alvo){//retorna ponteiro para o próximo simbolo caso esteja removendo de algum lugar que não seja o fim da tabela
	simbolo *ancora = (*alvo).seguinte;
	free((*alvo).nome);
	free((*alvo).valor);
	free(alvo);
	return ancora;
}

void ApagarTabela(){
	simbolo *ancora = tabelaSimbolos;
	if(ancora == NULL) return;
	do{
		ancora = RemoverSimbolo(ancora);
	}
	while(ancora != NULL);
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
	
struct no{						//Elemento da árvore sintática! Contém um vetor de filhos e o número de quantos existem dentro.
	no filhos[];
	int numFilhos;

	int tipo;					//Contém também um número único que identifica qual variável foi usada para criar este nó(números definidos pelo próprio Bison)

	simbolo* refereTabela;		//Para uso futuro, caso o nó contenha referência á um ID, guardamos um ponteiro para onde ele se localiza na tabela de símbolos
	char *valor;				//Contém o valor associado ao item abaixo, caso exista. Para números, contém o número em string. Para IDs, contém o nome do ID, etc.
	char *nome;					//Contém uma string que identifica qual específica transição da variável foi usada para gerar este nó. Caso contenha um ID, será sempre "ID".
};									//Caso contenha uma constante, será "CHAR","STRING" ou "NUM", de acordo com a mesma.

no* raiz;


%}

%union {
	double val;	
	char *text;
	bool boolean;
	no *node;
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

%start	inicio 

%type <node> statement
%type <node> assignment
%type <node> function_declaration
%type <node> conjuntoop
%type <node> mathop
%type <node> return
%type <node> for
%type <node> if
%type <node> write
%type <node> writeln
%type <node> read
%type <node> comparg
%type <node> comparison
//%type <text> in
%type <node> conjuntoop1
%type <node> pertinencia
%type <node> tipagem
%type <node> inclusao
%type <node> remocao
%type <node> selecao
%type <node> iteracao
%type <node> function_call
%type <node> funcargs
%type <node> args
%type <node> args1
%type <node> variable_declaration
%type <node> mathop1
%type <node> mathop2
%type <node> matharg
%type <node> type;

%%

inicio:
		statement								{raiz = $1;}
	;





statement: 
		assignment SEMICOLON statement			{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													char ancora2[] = "assignment";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	function_declaration statement 			{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $2;
													(ancora*).numFilhos = 2;
													char ancora2[] = "function_declaration";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	variable_declaration statement 			{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $2;
													(ancora*).numFilhos = 2;
													char ancora2[] = "variable_declaration";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	conjuntoop SEMICOLON statement			{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													char ancora2[] = "conjuntoop";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	mathop SEMICOLON statement				{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													char ancora2[] = "mathop";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	return SEMICOLON statement				{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													char ancora2[] = "return";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	for statement							{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $2;
													(ancora*).numFilhos = 2;
													char ancora2[] = "for";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	if statement							{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $2;
													(ancora*).numFilhos = 2;
													char ancora2[] = "if";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	write SEMICOLON statement				{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													char ancora2[] = "write";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	writeln SEMICOLON statement				{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													char ancora2[] = "writeln";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	read SEMICOLON statement				{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													char ancora2[] = "read";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	%empty									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 0;
													char ancora2[] = "epsilon";
													(ancora*).nome = strdup(ancora2);
													(ancora*).tipo = YYSYMBOL_statement;
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;

comparg:
		ID										{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).tipo = YYSYMBOL_comparg;
													(ancora*).filhos = 0;
													(ancora*).valor = strdup($1->text);
													char ancora2[] = "ID";
													(ancora*).nome = strdup(ancora2);
													simbolo *ancoraSimb = ProcurarTabela($1->text);
													if(ancoraSimb != NULL){ //Vamos começar a usar a tabela de simbolos! Se não acharmos este ID na tabela, devemos colocar-lo lá, mas sem valor! Só em assignment a gente coloca valor
														(ancora*).refereTabela = ancoraSimb;
													}
													else{
														(ancora*).refereTabela = CriarSimbolo($1->text,0,NULL);//Não temos como saber aqui qual o tipo desse ID, então criamos ele sem isso tbm
													}
													$$ = ancora;
													free($1);

													

												}
	|	OPENPAR comparison CLOSEPAR				{	
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $2;
													(ancora*).numFilhos = 1;
													(ancora*).tipo = YYSYMBOL_comparg;
													char ancora2[] = "comparison";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													$$ = ancora;
												}
	|	NUM										{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 0;
													(ancora*).tipo = YYSYMBOL_comparg;
													char ancora2[] = "NUM";
													(ancora*).nome = strdup(ancora2);
													(ancora*).valor = strdup($1->text);
													(ancora*).refereTabela = NULL;
													$$ = ancora;
													free($1);
												}
	;

comparison:
		NOT comparg								{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $2;
													(ancora*).numFilhos = 1;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "not";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg AND comparg						{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "and";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg OR comparg						{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "or";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg GREATER comparg					{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "greater";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg GE comparg						{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "greater_or_equal";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg LESS comparg					{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "less";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg LE comparg						{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "less_or_equal";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg EQ comparg						{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "equal";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	comparg NEQ comparg						{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).numFilhos = 2;
													(ancora*).tipo = YYSYMBOL_comparison;
													char ancora2[] = "not_equal";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;

read:
		READ OPENPAR ID CLOSEPAR				{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 0;
													(ancora*).tipo = YYSYMBOL_read;
													char ancora2[] = "read";
													(ancora*).nome = strdup(ancora2);
													simbolo *ancoraSimb = ProcurarTabela($1->text);
													if(ancoraSimb != NULL){ 
														(ancora*).refereTabela = ancoraSimb;
													}
													else{
														(ancora*).refereTabela = CriarSimbolo($1->text,0,NULL);
													}
													$$ = ancora;
													(ancora*).valor = strdup($3->text);
													free($3);
												}
	;

write:
//		WRITE OPENPAR ID CLOSEPAR
		WRITE OPENPAR mathop CLOSEPAR			{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $3;
													(ancora*).numFilhos = 1;
													(ancora*).tipo = YYSYMBOL_write;
													char ancora2[] = "mathop";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
//	|	WRITE OPENPAR NUM CLOSEPAR	
	|	WRITE OPENPAR  STRING  CLOSEPAR			{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 0;
													(ancora*).tipo = YYSYMBOL_write;
													char ancora2[] = "string";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = strdup($3->text);
													$$ = ancora;
													free($3);
												}
	;


writeln:
//		WRITELN OPENPAR ID CLOSEPAR
		WRITELN OPENPAR mathop CLOSEPAR			{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $3;
													(ancora*).numFilhos = 1;
													(ancora*).tipo = YYSYMBOL_writeln;
													char ancora2[] = "mathop";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
//	|	WRITELN OPENPAR NUM CLOSEPAR
	|	WRITELN OPENPAR  STRING  CLOSEPAR		{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 0;
													(ancora*).tipo = YYSYMBOL_writeln;
													char ancora2[] = "string";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = strdup($3->text);
													$$ = ancora;
													free($3);
												}
	;
/*in:
		ID IN ID
	|	ID IN conjuntoop
	;
*/
return:
//		RETURN ID
//	|	RETURN function_call
		RETURN comparison						{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $2;
													(ancora*).numFilhos = 1;
													(ancora*).tipo = YYSYMBOL_return;
													char ancora2[] = "comparison";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	RETURN mathop 							{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).filhos[0] = $2;
													(ancora*).numFilhos = 1;
													(ancora*).tipo = YYSYMBOL_return;
													char ancora2[] = "mathop";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	RETURN 									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 0;
													(ancora*).tipo = YYSYMBOL_return;
													char ancora2[] = "null";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;

for:
		FOR OPENPAR assignment SEMICOLON comparison SEMICOLON assignment CLOSEPAR OPENBRAC statement CLOSEBRAC	{
																													no* ancora = (no*)malloc(sizeof(no));
																													(ancora*).filhos[0] = $3;
																													(ancora*).filhos[1] = $5;
																													(ancora*).filhos[2] = $7;
																													(ancora*).filhos[3] = $10;
																													(ancora*).numFilhos = 4;
																													(ancora*).tipo = YYSYMBOL_for;
																													char ancora2[] = "for";
																													(ancora*).nome = strdup(ancora2);
																													(ancora*).refereTabela = NULL;
																													(ancora*).valor = NULL;
																													$$ = ancora;
																												}
	;

if:
		IF OPENPAR comparison CLOSEPAR OPENBRAC statement CLOSEBRAC											{
																												no* ancora = (no*)malloc(sizeof(no));
																												(ancora*).filhos[0] = $3;
																												(ancora*).filhos[1] = $6;
																												(ancora*).numFilhos = 2;
																												(ancora*).tipo = YYSYMBOL_if;
																												char ancora2[] = "if";
																												(ancora*).nome = strdup(ancora2);
																												(ancora*).refereTabela = NULL;
																												(ancora*).valor = NULL;
																												$$ = ancora;
																											}
	|	IF OPENPAR comparison CLOSEPAR OPENBRAC statement CLOSEBRAC ELSE OPENBRAC statement CLOSEBRAC		{
																												no* ancora = (no*)malloc(sizeof(no));
																												(ancora*).filhos[0] = $3;
																												(ancora*).filhos[1] = $6;
																												(ancora*).filhos[2] = $10;
																												(ancora*).numFilhos = 3;
																												(ancora*).tipo = YYSYMBOL_if;
																												char ancora2[] = "else";
																												(ancora*).nome = strdup(ancora2);
																												(ancora*).refereTabela = NULL;
																												(ancora*).valor = NULL;
																												$$ = ancora;
																											}
	;

conjuntoop:
		pertinencia								{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop;
													char ancora2[] = "pertinencia";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	tipagem									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop;
													char ancora2[] = "tipagem";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	inclusao								{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop;
													char ancora2[] = "inclusao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	remocao									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop;
													char ancora2[] = "remocao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	selecao									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop;
													char ancora2[] = "selecao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	iteracao								{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop;
													char ancora2[] = "iteracao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;
	
conjuntoop1:
		pertinencia								{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "pertinencia";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	tipagem									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "tipagem";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	inclusao								{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "inclusao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	remocao									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "remocao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	selecao									{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "selecao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	iteracao								{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "iteracao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	|	ID 										{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 0;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "ID";
													(ancora*).nome = strdup(ancora2);
													simbolo *ancoraSimb = ProcurarTabela($1->text);
													if(ancoraSimb != NULL){
														(ancora*).refereTabela = ancoraSimb;
													}
													else{
														(ancora*).refereTabela = CriarSimbolo($1->text,0,NULL);
													}
													(ancora*).valor = strdup($1->text);
													free($1);
													$$ = ancora;
												}
	;

pertinencia:
		mathop IN conjuntoop1 					{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 2;
													(ancora*).filhos[0] = $1;
													(ancora*).filhos[1] = $3;
													(ancora*).tipo = YYSYMBOL_pertinencia;
													char ancora2[] = "pertinencia";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;

tipagem:
		IS_SET OPENPAR conjuntoop1 CLOSEPAR		{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $3;
													(ancora*).tipo = YYSYMBOL_tipagem;
													char ancora2[] = "tipagem";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;

inclusao:
		ADD OPENPAR pertinencia CLOSEPAR		{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $3;
													(ancora*).tipo = YYSYMBOL_inclusao;
													char ancora2[] = "inclusao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;

remocao:
		REMOVE OPENPAR pertinencia CLOSEPAR		{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $3;
													(ancora*).tipo = YYSYMBOL_remocao;
													char ancora2[] = "remocao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;
	
	
selecao:
		EXISTS OPENPAR pertinencia CLOSEPAR		{
													no* ancora = (no*)malloc(sizeof(no));
													(ancora*).numFilhos = 1;
													(ancora*).filhos[0] = $1;
													(ancora*).tipo = YYSYMBOL_conjuntoop1;
													char ancora2[] = "iteracao";
													(ancora*).nome = strdup(ancora2);
													(ancora*).refereTabela = NULL;
													(ancora*).valor = NULL;
													$$ = ancora;
												}
	;

iteracao:
		FORALL OPENPAR pertinencia CLOSEPAR OPENBRAC statement CLOSEBRAC	{
																				no* ancora = (no*)malloc(sizeof(no));
																				(ancora*).numFilhos = 2;
																				(ancora*).filhos[0] = $3;
																				(ancora*).filhos[1] = $6;
																				(ancora*).tipo = YYSYMBOL_iteracao;
																				char ancora2[] = "bracket";
																				(ancora*).nome = strdup(ancora2);
																				(ancora*).refereTabela = NULL;
																				(ancora*).valor = NULL;
																				$$ = ancora;
																			}
	|	FORALL OPENPAR pertinencia CLOSEPAR statement SEMICOLON				{
																				no* ancora = (no*)malloc(sizeof(no));
																				(ancora*).numFilhos = 2;
																				(ancora*).filhos[0] = $3;
																				(ancora*).filhos[1] = $5;
																				(ancora*).tipo = YYSYMBOL_iteracao;
																				char ancora2[] = "semicolon";
																				(ancora*).nome = strdup(ancora2);
																				(ancora*).refereTabela = NULL;
																				(ancora*).valor = NULL;
																				$$ = ancora;
																			}
	;

function_call:
		ID OPENPAR args CLOSEPAR SEMICOLON									{
																				no* ancora = (no*)malloc(sizeof(no));
																				(ancora*).numFilhos = 1;
																				(ancora*).filhos[0] = $3;
																				(ancora*).tipo = YYSYMBOL_function_call;
																				char ancora2[] = "function_call";
																				(ancora*).nome = strdup(ancora2);
																				(ancora*).valor = strdup($1->text);
																				simbolo *ancoraSimb = ProcurarTabela($1->text);
																				if(ancoraSimb != NULL){
																					(ancora*).refereTabela = ancoraSimb;
																				}
																				else{
																					(ancora*).refereTabela = CriarSimbolo($1->text,FUNC,NULL);
																				}
																				$$ = ancora;
																				free($1);
																			}
	;


/*args:
		args COMMA args
	|	ID
	|	NUM
	;
*/
args:
		ID args1		{
							no* ancora = (no*)malloc(sizeof(no));
							(ancora*).numFilhos = 1;
							(ancora*).filhos[0] = $2;
							(ancora*).tipo = YYSYMBOL_args;
							char ancora2[] = "ID";
							(ancora*).nome = strdup(ancora2);
							simbolo *ancoraSimb = ProcurarTabela($1->text);
							if(ancoraSimb != NULL){
								(ancora*).refereTabela = ancoraSimb;
							}
							else{
								(ancora*).refereTabela = CriarSimbolo($1->text,FUNC,NULL);
							}
							(ancora*).valor = strdup($1->text);
							free($1);
							$$ = ancora;
						}
	|	NUM args1		{	
							no* ancora = (no*)malloc(sizeof(no));
							(ancora*).numFilhos = 1;
							(ancora*).filhos[0] = $2;
							(ancora*).tipo = YYSYMBOL_args;
							char ancora2[] = "NUM";
							(ancora*).nome = strdup(ancora2);
							(ancora*).refereTabela = NULL;
							(ancora*).valor = strdup($1->text);
							free($1);
							$$ = ancora;
						}
	;

args1:
		COMMA args		{
							no* ancora = (no*)malloc(sizeof(no));
							(ancora*).numFilhos = 1;
							(ancora*).filhos[0] = $2;
							(ancora*).tipo = YYSYMBOL_args1;
							char ancora2[] = "comma";
							(ancora*).nome = strdup(ancora2);
							(ancora*).refereTabela = NULL;
							(ancora*).valor = NULL;
							$$ = ancora;
						}
	|	%empty			{
							no* ancora = (no*)malloc(sizeof(no));
							(ancora*).numFilhos = 0;
							char ancora2[] = "epsilon";
							(ancora*).nome = strdup(ancora2);
							(ancora*).tipo = YYSYMBOL_args1;
							(ancora*).refereTabela = NULL;
							(ancora*).valor = NULL;
							$$ = ancora;
						}
	;

funcargs:
		type ID					{
									no* ancora = (no*)malloc(sizeof(no));
									(ancora*).numFilhos = 1;
									(ancora*).filhos[0] = $1;
									(ancora*).tipo = YYSYMBOL_funcargs;
									char ancora2[] = "single";
									(ancora*).nome = strdup(ancora2);
									simbolo *ancoraSimb = ProcurarTabela($2->text);
									if(ancoraSimb != NULL){
										(ancora*).refereTabela = ancoraSimb;
									}
									else{
										(ancora*).refereTabela = CriarSimbolo($2->text,0,NULL);
									}
									(ancora*).valor = strdup($2->text);
									free($2);
									$$ = ancora;
								}
	|	type ID COMMA funcargs	{
									no* ancora = (no*)malloc(sizeof(no));
									(ancora*).numFilhos = 2;
									(ancora*).filhos[0] = $1;
									(ancora*).filhos[1] = $4;
									(ancora*).tipo = YYSYMBOL_funcargs;
									char ancora2[] = "comma";
									(ancora*).nome = strdup(ancora2);
									simbolo *ancoraSimb = ProcurarTabela($2->text);
									if(ancoraSimb != NULL){
										(ancora*).refereTabela = ancoraSimb;
									}
									else{
										(ancora*).refereTabela = CriarSimbolo($2->text,0,NULL);
									}
									(ancora*).valor = strdup($2->text);
									free($2);
									$$ = ancora;
								}
	|	%empty					{
									no* ancora = (no*)malloc(sizeof(no));
									(ancora*).numFilhos = 0;
									char ancora2[] = "epsilon";
									(ancora*).nome = strdup(ancora2);
									(ancora*).tipo = YYSYMBOL_funcargs;
									(ancora*).refereTabela = NULL;
									(ancora*).valor = NULL;
									$$ = ancora;
								}
	;
	

function_declaration:
		type ID OPENPAR funcargs CLOSEPAR OPENBRAC statement CLOSEBRAC	{
																			no* ancora = (no*)malloc(sizeof(no));
																			(ancora*).numFilhos = 3;
																			(ancora*).filhos[0] = $1;
																			(ancora*).filhos[1] = $4;
																			(ancora*).filhos[2] = $7;
																			(ancora*).tipo = YYSYMBOL_function_declaration;
																			char ancora2[] = "function_declaration";
																			(ancora*).nome = strdup(ancora2);
																			simbolo *ancoraSimb = ProcurarTabela($2->text);
																			if(ancoraSimb != NULL){
																				(ancora*).refereTabela = ancoraSimb;
																				(ancoraSimb*).tipo = FUNC;
																			}
																			else{
																				(ancora*).refereTabela = CriarSimbolo($2->text,FUNC,NULL);
																			}
																			(ancora*).valor = strdup($2->text);
																			free($2);
																			$$ = ancora;
																		}
	;
	
	
assignment:
		ID ASSIGN NUM													{
																			no* ancora = (no*)malloc(sizeof(no));
																			(ancora*).numFilhos = 0;
																			(ancora*).tipo = YYSYMBOL_assignment;

																		}
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
		mathop PLUS mathop1			{$$ = $1 + $3;}
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
	topo = tabelaSimbolos;
	//raiz = (no*)malloc(sizeof(no));
	//variavelRaiz = TRUE;
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
	ApagarTabela();
	return 0;
}

