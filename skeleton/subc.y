%{
/*
 * File Name   : subc.y
 * Description : a skeleton bison input
 */

#include "subc.h"
#include "subc.tab.h"

int    yylex ();
int    yyerror (char* s);
void   REDUCE(char* s);

%}

/* yylval types */
%union {
    int intVal;
    char *stringVal;
    struct id *idptr;
    struct decl *declptr;
    struct ste *steptr;
}

/* Precedences and Associativities */
%left   ','
%right  '='
%left   LOGICAL_OR
%left   LOGICAL_AND
%left   '&'
%left   EQUOP
%left   RELOP
%left   '+' '-'
%left   '*'
%right  '!' INCOP DECOP
%left   '[' ']' '(' ')' '.' STRUCTOP
%nonassoc   ELSE

/* Tokens and Types */
/* Tokens */
%token        VOID STRUCT RETURN IF ELSE WHILE FOR BREAK CONTINUE
%token        LOGICAL_OR LOGICAL_AND RELOP EQUOP INCOP DECOP STRUCTOP

/* string, int, id */
%token<stringVal>   CHAR_CONST STRING
%token<intVal>      INTEGER_CONST
%token<idptr>       ID
%token<declptr>     TYPE

/* decl */
%type<declptr>      struct_specifier func_decl param_list param_decl def_list def compound_stmt local_defs stmt_list stmt unary

/* type decl */
%type<declptr>      type_specifier expr_e const_expr expr or_expr or_list and_expr and_list binary args

%type<intVal>       pointers;

%%

program
        : ext_def_list
        ;

ext_def_list
        : ext_def_list ext_def
        | /* empty */
        ;

ext_def
        : type_specifier pointers ID ';' { printf("ext_def;\n"); }
        | type_specifier pointers ID '[' const_expr ']' ';'
        | func_decl ';'
        | type_specifier ';'
        | func_decl compound_stmt

type_specifier
        : TYPE { printTypeDecl($1); }
        | VOID
        | struct_specifier { REDUCE("type_specifier => struct_specifier\n"); }

struct_specifier
        : STRUCT ID '{'
        {
            pushscope();
            printscopestack();
        }
        def_list
        {
            printscopestack();
            struct ste *fields = popscope();
            printscopestack();
            declare($2, ($<declptr>$ = makestructdecl(fields)));
            printscopestack();
        }
        '}'
        {
            $$ = $<declptr>6;
        }
        | STRUCT ID
        {
            struct decl *decl_ptr = findcurrentdecl($2);
            if(decl_ptr != NULL && (check_is_struct_type(decl_ptr) == 1)){
                $$ = decl_ptr;
                //printf("this is struct type\n");
            }
            else {
                $$ = NULL;
                printf("ERROR : this is not struct type\n");
            }
        }

func_decl
        : type_specifier pointers ID '(' ')'
        {
            struct decl *procdecl = makeprocdecl();
            declare($3, procdecl);
            pushscope(); /* for collecting formals */
            declare(returnid, $1);

            // no formals

            struct ste *formals;
            formals = popscope();

            /* formals->decl is always returnid decl with return type*/
            procdecl->returntype = formals->decl;
            procdecl->formals = formals->prev; // null in this production
            
            /* error ; struct_specifier returns NULL, because this is not a struct*/
            if (procdecl->returntype == NULL)
                printf("ERROR : this is not a struct\n");

            $$ = procdecl;
        }
        | type_specifier pointers ID '(' VOID ')'
        {
            // what is VOID???????
        }
        | type_specifier pointers ID '(' 
        {
            struct decl *procdecl = makeprocdecl();
            declare($3, procdecl);
            pushscope(); /* for collecting formals */
            declare(returnid, $1);
            $<declptr>$ = procdecl;
        }
        param_list ')'
        {
            struct ste *formals;
            struct decl *procdecl = $<declptr>5;
            formals = popscope();
            /* formals->decl is always returnid decl with return type*/
            procdecl->returntype = formals->decl;
            procdecl->formals = formals->prev;

            /*
                // check point (formal list-first)
                printf("formal list first param = %s\n", procdecl->formals->name->name);
                printf("formal list second param = %s\n", procdecl->formals->prev->name->name);
            */

            /* error ; struct_specifier returns NULL, because this is not a struct*/
            if (procdecl->returntype == NULL)
                printf("ERROR : this is not struct\n");
 
            $$ = procdecl;
        }

pointers
        : '*' { $$ = 1; }
        | /* empty */ { $$ = 0; }

param_list  /* list of formal parameter declaration */
        : param_decl
        | param_list ',' param_decl

param_decl  /* formal parameter declaration */
        : type_specifier pointers ID
        {
            if ($2 == 0) // no pointer
                declare($3, $$ = makevardecl($1));
            else // pointer
                declare($3, $$ = makevardecl(makeptrdecl($1)));
            printscopestack();
        }
        | type_specifier pointers ID '[' const_expr ']'
        {
            if ($2 == 0) // no pointer
                declare($3, $$ = makeconstdecl(makearraydecl($5->value, makevardecl($1))));
            else // pointer
                declare($3, $$ = makeconstdecl(makearraydecl($5->value, makevardecl(makeptrdecl($1)))));
            
            printscopestack();
        }

def_list    /* list of definitions, definition can be type(struct), variable, function */
        : def_list def
        {
            printf("def list!\n");
        }
        | /* empty */

def
        : type_specifier pointers ID ';'
        {
            if ($2 == 0) // no pointer
                declare($3, $$ = makevardecl($1));
            else // pointer
                declare($3, $$ = makevardecl(makeptrdecl($1)));

            printscopestack();
        }
        | type_specifier pointers ID '[' const_expr ']' ';'
        {
            if ($2 == 0) // no pointer
                declare($3, $$ = makeconstdecl(makearraydecl($5->value, makevardecl($1))));
            else // pointer
                declare($3, $$ = makeconstdecl(makearraydecl($5->value, makevardecl(makeptrdecl($1)))));
            
            printscopestack();
        }
        | type_specifier ';'
        | func_decl ';'

compound_stmt
        : '{' {
            pushscope();
            //printscopestack();
        }
        local_defs stmt_list '}' {
            popscope();
            //printscopestack();
        }

local_defs  /* local definitions, of which scope is only inside of compound statement */
        :   def_list

stmt_list
        : stmt_list stmt
        | /* empty */

stmt
        : expr ';'
        | compound_stmt
        | RETURN ';'
        | RETURN expr ';'
        | ';'
        | IF '(' expr ')' stmt
        | IF '(' expr ')' stmt ELSE stmt
        | WHILE '(' expr ')' stmt
        | FOR '(' expr_e ';' expr_e ';' expr_e ')' stmt
        | BREAK ';'
        | CONTINUE ';'

expr_e
        : expr
        | /* empty */

const_expr
        : expr

expr
        : unary '=' expr
        | or_expr

or_expr
        : or_list

or_list
        : or_list LOGICAL_OR and_expr
        | and_expr

and_expr
        : and_list

and_list
        : and_list LOGICAL_AND binary
        | binary

binary
        : binary RELOP binary
        | binary EQUOP binary
        | binary '+' binary
        | binary '-' binary
        | unary %prec '='
        {
            //printf("unary = %d\n", $1->value);
        }

unary
        : '(' expr ')'
        | '(' unary ')' 
        | INTEGER_CONST
        {
            // [TODO] memory leak.. how can I send only integer? or without malloc..?
            $$ = makeintconstdecl(inttype, $1);
        }
        | CHAR_CONST
        | STRING
        | ID
        | '-' unary %prec '!'
        | '!' unary
        | unary INCOP
        | unary DECOP
        | INCOP unary
        | DECOP unary
        | '&' unary %prec '!'
        | '*' unary %prec '!'
        | unary '[' expr ']'
        | unary '.' ID
        | unary STRUCTOP ID
        | unary '(' args ')'
        | unary '(' ')'

args    /* actual parameters(function arguments) transferred to function */
        : expr
        | args ',' expr

%%

/*  Additional C Codes  */

int yyerror (char* s) {
    fprintf (stderr, "%s\n", s);
}

void REDUCE( char* s) {
    printf("%s\n",s);
}