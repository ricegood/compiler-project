#
# This is a makefile for the skeleton program for project 2.
#

CC = gcc
LEX = flex
YACC = bison
COMPILE_OPTION = -g
LINK_OPTION = -lfl
YACC_OPTION = -vd

all : subc

clean :
	rm -f *.o lex.yy.c subc.tab.c subc.tab.h subc.output subc

subc : lex.yy.o hash.o scopestack.o symboltable.o labelstack.o subc.tab.o
	${CC} -o subc lex.yy.o hash.o scopestack.o symboltable.o labelstack.o subc.tab.o ${LINK_OPTION}

subc.tab.o : subc.tab.c subc.h
	${CC} -c ${COMPILE_OPTION} subc.tab.c

hash.o : hash.c subc.h
	${CC} -c ${COMPILE_OPTION} hash.c

scopestack.o : scopestack.c subc.h
	${CC} -c ${COMPILE_OPTION} scopestack.c

symboltable.o : symboltable.c subc.h
	${CC} -c ${COMPILE_OPTION} symboltable.c

labelstack.o : labelstack.c subc.h
	${CC} -c ${COMPILE_OPTION} labelstack.c

lex.yy.o : lex.yy.c subc.tab.h subc.h
	${CC} -c ${COMPILE_OPTION} lex.yy.c

lex.yy.c : subc.l
	${LEX} subc.l

subc.tab.h subc.tab.c : subc.y
	${YACC} ${YACC_OPTION} subc.y

