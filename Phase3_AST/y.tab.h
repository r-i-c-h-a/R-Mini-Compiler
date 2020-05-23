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
    T_NE = 258,
    T_GE = 259,
    T_GT = 260,
    T_LT = 261,
    T_LE = 262,
    T_EQ = 263,
    T_ANDD = 264,
    T_ORD = 265,
    T_LEFTASSIGN = 266,
    T_EQASSIGN = 267,
    T_IF = 268,
    T_ELSE = 269,
    T_FOR = 270,
    T_WHILE = 271,
    T_IN = 272,
    CONST_NUMBER = 273,
    CONST_STRING = 274,
    SYM = 275,
    T_NEWLINE = 276,
    T_SEMICOLON = 277,
    T_COLON = 278,
    T_PRINT = 279,
    T_PLUS = 280,
    T_MINUS = 281,
    T_STAR = 282,
    T_FSLASH = 283,
    T_LEFTPAREN = 284,
    T_RIGHTPAREN = 285,
    T_LEFTCURL = 286,
    T_RIGHTCURL = 287
  };
#endif
/* Tokens.  */
#define T_NE 258
#define T_GE 259
#define T_GT 260
#define T_LT 261
#define T_LE 262
#define T_EQ 263
#define T_ANDD 264
#define T_ORD 265
#define T_LEFTASSIGN 266
#define T_EQASSIGN 267
#define T_IF 268
#define T_ELSE 269
#define T_FOR 270
#define T_WHILE 271
#define T_IN 272
#define CONST_NUMBER 273
#define CONST_STRING 274
#define SYM 275
#define T_NEWLINE 276
#define T_SEMICOLON 277
#define T_COLON 278
#define T_PRINT 279
#define T_PLUS 280
#define T_MINUS 281
#define T_STAR 282
#define T_FSLASH 283
#define T_LEFTPAREN 284
#define T_RIGHTPAREN 285
#define T_LEFTCURL 286
#define T_RIGHTCURL 287

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
