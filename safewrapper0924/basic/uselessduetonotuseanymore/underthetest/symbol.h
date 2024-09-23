#ifndef __SYMBOL
#define __SYMBOL

// Stores the coordinate in source file
typedef struct
{
  // Length is for an expression
  unsigned int line, col, length;
} Coordinate;
// Token type for an identifier
typedef struct
{
  Coordinate src; // used for error reporting
  char *name; //copied string (pointer)
} IdStruct;

#endif