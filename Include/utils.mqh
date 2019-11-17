#property copyright "void_xxx"
#property link      "yeet"
#property strict

#include "structs.mqh"
#include "variables.mqh"
#include "short.mqh"

#ifndef FILE_UTILS_SEEN
#define FILE_UTILS_SEEN

pair_value temp;
void swap_pv( pair_value& x[], int a, int b) {
	temp = x[a];
	x[a] = x[b];
	x[b] = temp;
}

void sort_pv( pair_value& x[]) {
   int asize = ArraySize(x);
   int highind = 0;
   for(int i = 0; i < asize; i++) {
      highind = i;
      for( int j = i+1; j < asize; j++)
         if(x[j].value > x[highind].value) highind = j;
      if(i != highind) swap_pv(x, i, highind);
   }
}

int find_pv(pair_value& x[], str pair) {
   for(int i = 0; i < ArraySize(x); i++) {
      if(x[i].pair == pair) return i;
   }
   return -1;
}

double fetch_v(pair_value& x[], str pair) {
	int i = find_pv(x, pair);
	return i >= 0 ? x[i].value : -1;
}

str lines[LINES_OF_COMMENT], output;
void rollingComment(str newline) {
   Comment("");
   for(int i = LINES_OF_COMMENT-1; i > 1; i--) lines[i] = lines[i-1];
   lines[0] = newline + "\n";
   output = "";
   for(int i = 0; i < LINES_OF_COMMENT; i++) output += lines[i];
   Comment(output);
}

void clearAllObjects() {
	int totalobjects;
	for(long cid = ChartFirst(); cid != -1; cid = ChartNext(cid) ) {
		totalobjects = ObjectsTotal(cid);
		for(int i = totalobjects - 1;  i >= 0;  i--)
			ObjectDelete(cid, ObjectName(cid, i));
   }
   Comment("");
}

#endif
