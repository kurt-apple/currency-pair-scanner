#property copyright "void_xxx"
#property link      "yeet"
#property version   "1.00"
#property strict
#include "../Include/order_management.mqh"

void OnStart() {
	Print("MARGIN: $" + D2S(marginLong(ChartSymbol())) + ", LOTS: " + D2S(maxLong(ChartSymbol())));
	Print("LOTSIZE: " + ITS(MarketInfo(ChartSymbol(), MODE_LOTSIZE)));
}

//10/14/2019
//EURJPY SLpips 27.6k, value $764 per micro