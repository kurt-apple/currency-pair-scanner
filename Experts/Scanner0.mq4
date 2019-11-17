#property copyright "void_xxx"
#property version   "1.00"
#property strict
#include "../Include/order_management.mqh"
#define BR " :::: "
#define TF ChartPeriod()

str content;

void commentsymbolstotal(pair_value& a[]) {
	content = "";
	//after debugging, replace i < 2 with i < NUMPAIRS
	for(int i = 0; i < NUMPAIRS; i++) a[i] = iEVR_Comp(SymbolName(i, no));
	sort_pv(a);
	order_prep os_sell, os_buy;
	int loopsize = 5;
	for(int i = 0; i < loopsize; i++) {
		//Print("scanner0: beginning scan of " + a[i].pair);
		os_buy 	= prepare_order(a[i].pair, OP_BUY);
		os_sell = prepare_order(a[i].pair, OP_SELL);
		if(os_buy.sl <= 0 || os_sell.sl <= 0) {
			if(loopsize < NUMPAIRS) loopsize++;
			continue;
		}
		if(os_buy.lots < 0.01) {
			content += a[i].pair + " lots 0; T R A C I N G.\n";
			Print("ERROR: " + a[i].pair + " buyside lots 0; T R A C I N G.\n");
			os_buy = prepare_order(a[i].pair, OP_BUY, 0.0, INSECT);
			ExpertRemove();
		}
		else if(os_sell.lots < 0.01) {
			content += a[i].pair + " lots 0; T R A C I N G.\n";
			Print("ERROR: " + a[i].pair + " sellside lots 0; T R A C I N G.\n");
			os_sell = prepare_order(a[i].pair, OP_SELL, 0.0, INSECT);
			ExpertRemove();
		}
		else if(marginLong(a[i].pair, os_buy.lots) + PTVAL(a[i].pair) * os_buy.lots * os_buy.sl > CASH) {
			content += "cost of buying " + a[i].pair + " lots " + D2S(os_buy.lots) + " and SL " + D0S(os_buy.sl) + " costs too much ($" + D2S(os_buy.lots * PTVAL(os_buy.p) * os_buy.sl + marginLong(os_buy.p) * os_buy.lots) + "). T R A C I N G.\n";
			Print("ERROR: cost of buying " + a[i].pair + " lots " + D2S(os_buy.lots) + " and SL " + D0S(os_buy.sl) + " costs too much ($" + D2S(os_buy.lots * PTVAL(os_buy.p) * os_buy.sl + marginLong(os_buy.p) * os_buy.lots) + "). T R A C I N G.\n");
			os_buy = prepare_order(a[i].pair, OP_BUY, 0.0, INSECT);
			ExpertRemove();
		}
		else if(PTVAL(a[i].pair) * os_sell.lots * os_sell.sl > CASH) {
			content += "cost of shorting " + a[i].pair + " lots " + D2S(os_sell.lots) + " and SL " + D0S(os_sell.sl) + " costs too much ($" + D2S(os_sell.lots * PTVAL(os_sell.p) * os_sell.sl + marginLong(os_sell.p) * os_sell.lots) + "). T R A C I N G.\n";
			Print("ERROR: cost of shorting " + a[i].pair + " lots " + D2S(os_sell.lots) + " and SL " + D0S(os_sell.sl) + " costs too much ($" + D2S(os_sell.lots * PTVAL(os_sell.p) * os_sell.sl + marginLong(os_sell.p) * os_sell.lots) + "). T R A C I N G.\n");
			os_sell = prepare_order(a[i].pair, OP_SELL, 0.0, INSECT);
			ExpertRemove();
		}
		/*else if((PTVAL(os_buy.p) * os_buy.lots * os_buy.sl) > CASH * 0.25) {
			content += "huge risk for buying " + os_buy.p + ": $" + D2S(PTVAL(a[i].pair) * os_buy.lots * os_buy.sl) + " with SL " + D0S(os_buy.sl) + " Points *** T R A C I N G.\n";
			Print("tracing buy " + a[i].pair + " at " + D2S(os_buy.lots) + " lots because SL Points = " + D0S(os_buy.sl) + " and that's ridiculous");
			os_buy = prepare_order(a[i].pair, OP_BUY, 0.0, INSECT);
			Print("scanner0 debug: os_buy.sl: " + D0S(os_buy.sl) + " Points, worth $" + D2S(os_buy.lots * PTVAL(os_buy.p) * os_buy.sl) + ".");
			ExpertRemove();
		}
		else if((PTVAL(os_sell.p) * os_sell.lots * os_sell.sl) > CASH * 0.25) {
			content += "huge risk for selling " + os_sell.p + ": $" + D2S(PTVAL(a[i].pair) * os_sell.lots * os_sell.sl) + " with SL " + D0S(os_sell.sl) + " Points *** T R A C I N G.\n";
			Print("tracing sell " + a[i].pair + " at " + D2S(os_sell.lots) + " lots because SL Points = " + D0S(os_sell.sl) + " and that's ridiculous");
			os_sell = prepare_order(a[i].pair, OP_SELL, 0.0, INSECT);
			Print("scanner0 debug: os_sell.sl: " + D0S(os_sell.sl) + " Points, worth $" + D2S(os_sell.lots * PTVAL(os_sell.p) * os_sell.sl) + ".");
			ExpertRemove();
		}*/
		else if(iEMAvector(a[i].pair) > 0) {
			content += "LONG "
			+ a[i].pair
			+ ", "
			+ D2S(os_buy.lots)
			+ " for $" + D2S(marginLong(a[i].pair, os_buy.lots))
			+ " * SL "
			+ D1S(os_buy.sl)
			+ " * PTVAL $"
			+ D3S(PTVAL(a[i].pair))
			+ ", SL worth $"
			+ D2S(PTVAL(a[i].pair) * os_buy.lots * os_buy.sl)
			+ "\n";
			EventSetMillisecondTimer(5000);
		}
		else {
			content += "SHORT "
			+ a[i].pair
			+ ", "
			+ D2S(os_sell.lots)
			+ " for $" + D2S(marginSell(a[i].pair, os_sell.lots))
			+ ", SL "
			+ D1S(os_sell.sl)
			+ " * PTVAL $"
			+ D3S(PTVAL(a[i].pair))
			+ ", SL worth $"
			+ D2S(PTVAL(a[i].pair) * os_sell.lots * os_sell.sl)
			+ "\n";
			EventSetMillisecondTimer(5000);
		}
	}
	Comment(content);
}

pair_value evr_array[];

int OnInit() {
	ArrayResize(evr_array, NUMPAIRS);
	commentsymbolstotal(evr_array);
	EventSetMillisecondTimer(1500);
	return(INIT_SUCCEEDED);
}

void OnTimer() { commentsymbolstotal(evr_array); }

void OnChartEvent(const int e, const long& l, const double& d, const str& s) {
	if(e == CHARTEVENT_CHART_CHANGE) {
		int period = ChartPeriod();
		int count = 0;
		for(long id = ChartFirst(); id != -1; id = ChartNext(id) ) {
			ChartSetSymbolPeriod(id, ChartSymbol(id), period);
		}
	}
}
