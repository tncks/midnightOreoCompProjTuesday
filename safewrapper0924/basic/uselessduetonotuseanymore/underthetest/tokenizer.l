%{
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "symbol.h"
#include "y.tab.h"

#define MAX_STR_CONST 1000
#define yyterminate() return EOF_TOKEN
/* YY_USER_ACTION is called after
matching a pattern and before executing the action */
#define YY_USER_ACTION \
  col += yyleng;
extern char *currentFileName;
int col = 1; //track the current column
int lineno = 1;
int yyerror(char* s);
%}

alpha [a-zA-Z]
alphanum [a-zA-Z0-9]
digit [0-9]
nonzero [1-9]
%x str
%x comment single_line_comment /* for comments */

%%

      char string_buf[MAX_STR_CONST]; /* to store strings */
      char *string_buf_ptr;

  /* Keywords */
"int" {return K_INT;} 
"float" {return K_FLOAT;}
"char" {return K_CHAR;} 
"for" {return FOR;} 
"while" {return WHILE;} 
"else" {return ELSE;} 
"if" {return IF;} 
"switch" {return SWITCH;} 
"case" {return CASE;} 
"return" {return RETURN;}
"continue" {return CONTINUE;}
"break" {return BREAK;}
"default" {return DEFAULT;}

 /* Symbols 
    Return the first character of the matched string
 */
[-+*/%] return *yytext;
[;,:()] return *yytext;
[\{\}\[\]] return *yytext;
[=!<>] return *yytext;
  /* Lex always executes the longest match action */
"==" {return EQ;}
">=" {return GE;}
"<=" {return LE;}
"!=" {return NE;}

"&&" {return AND;}
"||" {return OR;}

  /* Integers */
0 {yylval.iValue = 0; return INTEGER;}
{nonzero}({digit})*([eE][-+]?[0-9]+)? {
      yylval.iValue = (int)round(atof(yytext)); return INTEGER;}

  /* Floats */
{nonzero}({digit})*"."({digit})*([eE][-+]?[0-9]+)? {
      yylval.fValue = atof(yytext); return FLOAT;}

  /* Characters */
"\'"({alpha}|{digit})"\'" {yylval.cValue = yytext[1]; return CHARACTER;}

  /* Identifiers */
(_|{alpha})((_|{alphanum}))* {
  yylval.id.name = malloc(strlen(yytext)+1);
  yylval.id.src.line = lineno;
  yylval.id.src.col = col - yyleng;
  // yylval.name = malloc(strlen(yytext)+1);
  strcpy(yylval.id.name, yytext);
  // strcpy(yylval.name, yytext);
  return IDENTIFIER;  
}

/* Strings*/
\" { string_buf_ptr = string_buf; BEGIN(str);}
<str>\" {
  BEGIN(INITIAL);
  *string_buf_ptr = '\0';
  yylval.sValue = (char*)malloc(strlen(string_buf)+1);
  strcpy(yylval.sValue, string_buf);
  return STRING;
}
<str>\n {yyerror("Unterminated string.\n"); return ERROR;}
<str>\\n {*string_buf_ptr++ = '\n';}
<str>[^\n] {
  *string_buf_ptr++ = *yytext;
}

  /* Comments*/
"//" BEGIN(single_line_comment);
<single_line_comment>"\n" {col = 1; lineno++; BEGIN(INITIAL);}
<single_line_comment><<EOF>> {BEGIN(INITIAL); return EOF_TOKEN;}
<single_line_comment>[^\n]+ ;

"/*" BEGIN(comment);
<comment>"\n" {col = 1; lineno++;}
<comment>"*/" {BEGIN(INITIAL);}
<comment><<EOF>> {yyerror("Unclosed comment found\n");}
<comment>. ;

  /* Whitespace */
[ \t\r] ;
\n {col = 1; lineno++;}

. {yyerror("Error: Invalid character"); return ERROR;}

%%
int yywrap(){
  yyterminate();
  return EOF_TOKEN;
}