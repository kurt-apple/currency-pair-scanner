#property copyright "void_xxx"
#property link      "yeet"
#property strict
#include "utils.mqh"
#include "order_management.mqh"

#ifndef FILE_PRICE_ANALYSIS_SEEN
#define FILE_PRICE_ANALYSIS_SEEN

double iHH(str pair, int tf, int bars, SHIFTY) {
	return iHigh(pair, tf, iHighest(pair, tf, MODE_HIGH, bars, 0));
}

double iLL(str pair, int tf, int bars, SHIFTY) {
	return iLow(pair, tf, iLowest(pair, tf, MODE_LOW, bars, 0));
}

int barsInTF(str p, int tf = 0, DEBUGS) {
	if(tf == 0) tf = CPER;
	int bars = iBars(p, tf)*tf;
	if(AVGHOLD < bars) {
		if(AVGHOLD < tf) {
			if(v) Print("returning min bars (" + ITS(MINBARS) + ")");
			return MINBARS;
		}
		else {
			if(v) Print("holdtime / tf: " + ITS(AVGHOLD / tf));
			return MathMin(MINBARS, AVGHOLD / tf);
		}
	}
	else {
		if(v) Print("bars on chart fewer than holdtime: " + ITS(bars));
		return bars;
	}
}

double totalRange(str pair, int tf, int bars) {
	return MathMax(iHH(pair, tf, bars) - iLL(pair, tf, bars), PT(pair));
}
double hiRange(str pair, int tf, int bars) {
	return MathMax(iHH(pair, tf, bars) - ASK(pair), PT(pair));
}
double loRange(str pair, int tf, int bars) {
	return MathMax(BID(pair) - iLL(pair, tf, bars), PT(pair));
}

double spread(str pair) { return MathAbs(BID(pair) - ASK(pair)); }

double iEVR(str pair, int tf, int time, DEBUGS) {
	return totalRange(pair, tf, barsInTF(pair, tf, v)) / spread(pair);
}

pair_value iEVR(str pair) {
   pair_value pv;
   pv.pair = pair;
   pv.value = iEVR(pair, CPER, AVGHOLD);
   return pv;
}

pair_value iEVR_Comp(str p) {
	pair_value pv;
	pv.pair = p;
	pv.value = iEVR(p, CPER, AVGHOLD) * PTVAL(p) / marginSell(p, 0.01);
	return pv;
}

double iRangePos(str pair, int tf, DEBUGS) {
	int bars = barsInTF(pair, tf, v);
	double range = totalRange(pair, tf, bars) / 2.0;
	return ((BID(pair) - iLL(pair, tf, bars)) - range) / range;
}

double iEMAvector(str pair, DEBUGS) {
	int bars = 2*barsInTF(pair, CPER, v);
	double ma = iMA(pair, CPER, bars, 0, MODE_EMA, PRICE_WEIGHTED, 0);
	double bid = BID(pair), ask = ASK(pair);
	double deltaB = bid - ma;
	double deltaA = ask - ma;
	return 10000 * (ABS(deltaB) < ABS(deltaA) ? deltaB / bid : deltaA / ask);
}

#endif
