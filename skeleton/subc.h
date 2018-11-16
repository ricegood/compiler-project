/******************************************************
 * File Name   : subc.h
 * Description
 *    This is a header file for the subc program.
 ******************************************************/

#ifndef __SUBC_H__
#define __SUBC_H__

enum lextype_ {KEYWORD, UNDEFINED, ID_}; // 0, 1, 2
enum typeclass_ {INT_, CHAR_, VOID_, STRUCT_, STRING_, ARRAY_, POINTER_}; // 0, 1, 2, 3, 4

#include <stdio.h>
#include <strings.h>
#include <stdlib.h>
#include <string.h>

/* structure for IDs */
typedef struct id {
	int lexType;
	char *name;
	int count;
} id;

/* structure for symbol table entries */
typedef struct ste {
	struct id *name;
	struct decl *decl;
	struct ste *prev;
} ste;

/* structure for declarations */
typedef struct decl {
	int declclass;
	struct decl *type;
	int value;
	float real_value;
	struct ste *formals;
	struct decl *returntype;
	int typeclass;
	struct decl *elementvar;
	int num_index;
	struct ste *fieldlist;
	struct decl *ptrto;
	int size;
	struct ste **scope;
	struct decl *next;
} decl;

/* For hash table */
unsigned hash(char *name);
struct id *enter(int lexType, char *name, int length);
struct id *lookup_hash(char *name);

int read_line();


#endif