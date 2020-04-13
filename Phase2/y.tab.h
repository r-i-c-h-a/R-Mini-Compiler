/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NUM_CONST = 258,
    STR_CONST = 259,
    SYMBOL = 260,
    LT = 261,
    LE = 262,
    EQ = 263,
    NE = 264,
    GE = 265,
    GT = 266,
    AND2 = 267,
    OR2 = 268,
    LEFT_ASSIGN = 269,
    EQ_ASSIGN = 270,
    IF = 271,
    ELSE = 272,
    FOR = 273,
    WHILE = 274,
    IN = 275,
    PRINT_ = 276,
    NEWLINE = 277,
    PLUS = 278,
    MINUS = 279,
    STAR = 280,
    FSLASH = 281,
    SEMICOLON = 282,
    COLON = 283,
    LEFT_PAREN = 284,
    RIGHT_PAREN = 285,
    LEFT_CURLY = 286,
    RIGHT_CURLY = 287
  };
#endif
/* Tokens.  */
#define NUM_CONST 258
#define STR_CONST 259
#define SYMBOL 260
#define LT 261
#define LE 262
#define EQ 263
#define NE 264
#define GE 265
#define GT 266
#define AND2 267
#define OR2 268
#define LEFT_ASSIGN 269
#define EQ_ASSIGN 270
#define IF 271
#define ELSE 272
#define FOR 273
#define WHILE 274
#define IN 275
#define PRINT_ 276
#define NEWLINE 277
#define PLUS 278
#define MINUS 279
#define STAR 280
#define FSLASH 281
#define SEMICOLON 282
#define COLON 283
#define LEFT_PAREN 284
#define RIGHT_PAREN 285
#define LEFT_CURLY 286
#define RIGHT_CURLY 287

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
