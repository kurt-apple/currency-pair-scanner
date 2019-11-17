#property copyright "void_xxx"
#property version   "1.00"
#property strict
#include "price_analysis.mqh"

string linecontent;

void commentsymbolstotal(p_value& a[]) {
	linecontent = "";
	for(int i = 0; i < NUMPAIRS; i++) a[i] = iEVR(SymbolName(i, false));
	sort_pv(a);
	for(int i = 0; i < 20; i++)
		linecontent += a[i].p
			+ " :::: marginBUY $"
			+ D2S(marginLong(a[i].p, 0.01))
			+ " :::: or sell: $"
			+ D2S(marginSell(a[i].p, 0.01))
			+ "\n";
	Comment(linecontent);
}

p_value evr_array[];

int OnInit() {
	ArrayResize(evr_array, NUMPAIRS);
	commentsymbolstotal(evr_array);
	EventSetMillisecondTimer(1500);
	return(INIT_SUCCEEDED);
}

void OnTimer() { commentsymbolstotal(evr_array); }
