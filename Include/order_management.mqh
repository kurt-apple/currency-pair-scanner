#property copyright "void_xxx"
#property link      "yeet"
#property strict
#include "constants.mqh"
#include "price_analysis.mqh"
#include "variables.mqh"
#include "short.mqh"
#include "sl_levels.mqh"
#include "tp_levels.mqh"

#ifndef FILE_ORDER_MANAGEMENT_SEEN
#define FILE_ORDER_MANAGEMENT_SEEN

//last checked: 2019-10-27, 10:36
bool smart_close(str p, int t, double lots, int ot) {
	bool result = OrderClose(t, lots, ot == OP_BUY ? BID(p) : ASK(p), SLIP);
	if(!result) Print("ERROR: Failed to close ticket: " + ITS(t) + ". " + ERR);
	return result;
}

//last checked: 2019-10-27 21:29
void CloseOrders(str symbol = "*") {
	bool touched = no,
	allflag = symbol == "*";
	RefreshRates();
	int oto = ORDERS;
	for(int i = oto - 1; i >= 0; i--) {
		if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
			Alert("ERROR: While selecting order - " + ERR);
			break;
		}
		else if(allflag || OS == symbol) {
			if(smart_close(symbol, OTK, OL, OTY)) touched = true;
			else Alert("Error closing order " + ITS(OTK) + ". " + ERR);
		}
	}
	if(!touched) Alert("There are no trades to close at this time.");
}

//started checking maxLong and maxSell 10/27/2019 23:19
double maxLong(str p, DEBUGS) {
	double margin = marginLong(p, 1.0, v);
	if(margin <= 0) {
		Print("ERROR: maxLong: margin on buy side for " + p + " returned as " + D4S(margin) + ". Tracing marginLong(" + p + "). T R A C I N G");
		margin = marginLong(p, 1.0, INSECT);
	}
	if(v) Print("maxLong: maxLong(" + p + ") = " + D2S(N2FLOOR((CASH / margin))));
	return N2FLOOR(CASH / margin);
}
double maxSell(str p, DEBUGS) {
	double margin = marginSell(p, 1.0, v);
	if(margin <= 0) {
		Print("ERROR: maxShort: margin on sell side for " + p + " returned as " + D2S(margin) + ". Tracing marginSell(" + p + "). T R A C I N G");
		margin = marginSell(p, 1.0, INSECT);
	}
	if(v) Print("maxSell: maxSell(" + p + ") = " + D2S(N2FLOOR(CASH / margin)));
	return N2FLOOR(CASH / margin);
}
double maxLots(str p, int ot, DEBUGS) { return ot == OP_BUY ? maxLong(p, v) : maxSell(p, v);  }

order_prep prepare_order(str p, int ot, LOTARG, DEBUGS) {
	if(v) Print("prepare_order: calculating SL");
	order_prep order;
	order.p = p;
	order.ot = ot;
	order.lots = lots;
	order.sl = 0;
	order.tp = 0;
	getSL(order, v);
	if(v) Print("prepare_order: SL = " + D0S(order.sl) + ", calculating TP");
	if(order.lots < 0.01) { 
		Print("ERROR: prepare_order " + p + ", lots=" + D2S(lots) + ":  op.lots is wack: = " + D2S(order.lots));
	}
	if(ot == OP_BUY) order.tp = getTP_Long_Points(p, order.lots, v);
	else order.tp = getTP_Sell_Points(p, order.lots, v);
	return order;
}

int order(order_prep &op) { return op.ot == OP_BUY ? buy(op) : sell(op); }

int buy(order_prep &op) {
	double ask = ASK(op.p);
	return OrderSend(op.p, OP_BUY, op.lots, ask, SLIP, slvb(op), tpvb(op));
}

int sell(order_prep &op) {
	double bid = BID(op.p);
	return OrderSend(op.p, OP_SELL, op.lots, bid, SLIP, slvs(op), tpvs(op));
}

void OrderMax(str p, int ot, DEBUGS) {
	order_prep x = prepare_order(p, ot, v);
	double riskUnits;
	if(ot == OP_BUY) riskUnits = x.sl;
	else riskUnits = x.sl - BID(p);

	double SL, TP;

	int ticket;

	Print(D2S(riskUnits/PT(p)) + " points stop loss");
	if(ot == OP_BUY) {
		SL = ASK(p) - riskUnits;
		TP = ASK(p) + RR * riskUnits;
	}
	else {
		SL = BID(p) + riskUnits;
		TP = BID(p) - RR * riskUnits;
	}

	if(v) {
		Print("SL: " + DsS(SL, p) + "; TP: " + DsS(TP, p));
	}

	if(MarketInfo(p, MODE_TRADEALLOWED)) {
		if(riskUnits != 0.0) {
			if(ot == OP_BUY) {
				Print("would buy "
					+ p
					+ ", "
					+ D2S(x.lots)
					+ " lots, ask is "
					+ DdS(ASK(p))
					+ ", "
					+ ITS(SLIP)
					+ " pts slip, SL="
					+ DdS(SL)
					+ ", TP="
					+ DdS(TP));
				ticket = OrderSend(p, OP_BUY, x.lots, ASK(p), SLIP, SL, TP);
			}
			else {
				Print("would sell "
					+ p
					+ ", "
					+ D2S(x.lots)
					+ " lots, bid is "
					+ DdS(BID(p))
					+ ", "
					+ ITS(SLIP)
					+ " pts slip, SL="
					+ DdS(SL)
					+ ", TP="
					+ DdS(TP));
				ticket = OrderSend(p, OP_SELL, x.lots, BID(p), SLIP, SL, TP);
			}
			Alert("Ticket " + ITS(ticket) + ticket != -1 ? " sent." : ERR);
		}
		else Alert("Volatility and/or spread are too high, aborted trading.");
	}
	else Alert("Trading is not allowed right now.");
}

double totalInSL() {
	double totalStopLoss = 0.00;
	int ot = OrdersTotal();
	for(int i = ot - 1; i >= 0; i--) {
		if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
			Alert("ERROR - Unable to select order - code " + ERR);
			break;
		}
		totalStopLoss += (MathAbs(OSL - OOP) / PT(OS)) * PTVAL(OS) * OL;
	}
	return totalStopLoss;
}

double symbol_lots(str p) {
	double symbol_lots = 0.00;
	int ot = OrdersTotal();
	for(int i = ot - 1; i >= 0; i--) {
		if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
			Alert("ERROR - Unable to select order - code " + ERR);
			break;
		}
		if(OS == p) symbol_lots += OL;
	}
	return symbol_lots;
}

double pbiggestorder(str p) {
	double maxlots = 0.00;
	int ot = OrdersTotal();
	for(int i = ot - 1; i >= 0; i--) {
		if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
			Alert("ERROR - Unable to select order - code " + ERR);
			break;
		}
		if(OrderSymbol() == p && OrderLots() > maxlots) maxlots = OrderLots();
	}
	return maxlots;
}

double psmallestorder(str p) {
	double minlots = 0.00;
	int ot = OrdersTotal();
	for(int i = ot - 1; i >= 0; i--) {
		if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
			Alert("ERROR - Unable to select order - code " + ERR);
			break;
		}
		if(OrderSymbol() == p && OrderLots() < minlots) minlots = OrderLots();
	}
	return minlots;
}



/*
Source: oanda docs.
Calculating margin used

Margin used is equal to position value multiplied by the margin requirement,
summed up over all open positions. Position value is the size of the position
(in units) converted from the base currency of the currency p in question
to your account currency using the current ask rate if the position is long
and the current bid rate if the position is short.

Example:
You have a CAD account and the following open positions: 10,000 long EUR/USD
and 20,000 short EUR/CZK. The current EUR/CAD rate is 1.2518/20.

Required Margin depends on the currency p and the maximum leverage set for
your account:

You have set your maximum leverage to 50:1.

The Position Value of a 10,000 EUR/USD long position is 10,000 EUR converted
to CAD, which is equal to 10,000 x 1.2520, or $12,520 CAD. The margin
requirement for EUR/USD is 2% (when the account maximum leverage is set to
50:1). As a result, the margin required on this EUR/USD position is equal to
$12,520 x 0.02, or $250.40 CAD.

The position value of a 20,000 EUR/CZK short position is 20,000 EUR converted
to CAD, which is equal to 20,000 x 1.2518, or $25,036 CAD. The margin
requirement for EUR/CZK is 5% (when the account maximum leverage is set to
50:1). As a result, the margin required on this EUR/CZK position is equal to
$25,036 x 0.05, or $1,251.80 CAD.

The position value of your account is $12,520 + $25,036 = $37,556 CAD. The
margin used on your open positions is $250.40 + $1,251.80 = $1,502.20 CAD.

Example:
Same example as above but with maximum leverage set to 20:1.

The position values remain the same, but the margin required is equal to 5% of
the position value, which is ($12,520 x 0.05) + ($25,036 x 0.05) = $626.00 +
$1,251.80. Hence, the margin used on open positions is equal to $1,877.80 CAD.
*/

double marginLong(str p, double volume = 1.0, DEBUGS) {
	str currency = AccountCurrency();
	//if 50:1, expects 50, not 2, or 0.02. VARIES BY CURRENCY PAIR
	double margin = 1 / fetch_v(LEVERAGE, p);
	if(margin <= 0) {
		Print("ERROR: marginLong(" + p + "): margin from leverage array returned " + fetch_v(LEVERAGE, p) + ", margin calculated was $" + margin + ".");
	}
	double lotsize = MarketInfo(p, MODE_LOTSIZE);
	double ask = ASK(p);

	//---- allow only standard forex symbols like XXXYYY
	if(StringLen(p) != 6) {
	  	Print("ERROR: MarginCalc: '" + p + "' must be standard forex symbol XXXYYY");
	  	return(0.0);
	}

	str first = StringSubstr(p, 0, 3); // the first symbol, for example,  EUR
	str second = StringSubstr(p, 3, 3); // the second symbol, for example, USD

	//---- check for data availability
	if(ask <= 0 || lotsize <= 0) {
		Print("ERROR: MarginCalc: no market information for '" + p + "'");
		return(0.0);
	}

	//check the simplest variations - without cross currencies
	if(first == currency) return((lotsize * volume) / margin);        // USDxxx
	if(second == currency) return((lotsize * ask * volume) / margin); // xxxUSD

	//check cross currencies, search for direct conversion thru deposit currency
	str base = currency + first;
	ask = ASK(base);
	// USDxxx
	if(ask > 0) {
		if(v) Print("marginLong(" + p + "): cross currency ask price for " + base + " returned " + D2S(ask));
		//if(v) Print("marginLong(" + p + "): lotsize " + D1S(lotsize) + " / ask " + DsS(ask, base) + " * volume " + D2S(volume) + " / margin " + D3S(margin) + " = " + D2S(lotsize / ask * volume / margin));
		return(lotsize / ask * volume / margin);
	}

	//try vice versa
	base = first + currency;
	ask = ASK(base); // xxxUSD
	if(ask > 0) {
		if(v) Print("marginLong(" + p + "): cross currency ask price for " + base + " returned " + D2S(ask));
		//if(v) Print("marginLong(" + p + "): lotsize " + D1S(lotsize) + " * ask " + DsS(ask, base) + " * volume " + D2S(volume) + " / margin " + D3S(margin) + " = " + D2S(lotsize * ask * volume / margin));
		return(lotsize * ask * volume / margin);
	}

	//---- direct conversion is impossible
	Print("ERROR: MarginCalculate: could not convert '" + p + "'");
	return(0.0);
}

double marginSell(str p, double volume = 1.0, DEBUGS) {
	str currency = AccountCurrency();
	//if 50:1, expects 50, not 2, or 0.02. VARIES BY CURRENCY PAIR
	double margin = 1 / fetch_v(LEVERAGE, p);
	double lotsize = MarketInfo(p, MODE_LOTSIZE);
	double bid = BID(p);

	//---- allow only standard forex symbols like XXXYYY
	if(StringLen(p) != 6) {
	  	Print("ERROR: MarginCalc: '" + p + "' must be standard forex symbol XXXYYY");
	  	return(0.0);
	}

	str first = StringSubstr(p, 0, 3); // the first symbol, for example,  EUR
	str second = StringSubstr(p, 3, 3); // the second symbol, for example, USD

	//---- check for data availability
	if(bid <= 0 || lotsize <= 0) {
		Print("ERROR: MarginCalc: no market information for '" + p + "'");
		return(0.0);
	}

	//---- check the simplest variations - without cross currencies
	if(first == currency) return((lotsize * volume) / margin);		  // USDxxx
	if(second == currency) return((lotsize * bid * volume) / margin); // xxxUSD

	//check cross currencies, search for direct conversion thru deposit currency
	str base = currency + first;
	// USDxxx
	bid = BID(base);
	if(bid > 0) {
		if(v) Print("marginSell(" + p + "): cross currency bid price for " + base + " returned " + D2S(bid));
		//if(v) Print("marginSell(" + p + "): lotsize " + D1S(lotsize) + " * ask " + DsS(bid, base) + " * volume " + D2S(volume) + " / margin " + D3S(margin) + " = " + D2S(lotsize * bid * volume / margin));
		return(lotsize / bid * volume / margin);
	}

	//---- try vice versa
	base = first + currency; // xxxUSD
	bid = BID(base);
	if(bid > 0) {
		if(v) Print("marginSell(" + p + "): cross currency bid price for " + base + " returned " + D2S(bid));
		//if(v) Print("marginSell(" + p + "): lotsize " + D1S(lotsize) + " * ask " + DsS(bid, base) + " * volume " + D2S(volume) + " / margin " + D3S(margin) + " = " + D2S(lotsize * bid * volume / margin));
		return(lotsize * bid * volume / margin);
	}

	//---- direct conversion is impossible
	Print("ERROR: MarginCalculate: can not convert '" + p + "'");
	return(0.0);
}

/*
//// pulled from https://www.mql5.com/en/forum/123307

+------------------------------------------------------------------+
| A very simple function to calculate margin for Forex symbols.    |
| It automatically calculates in the account's base currency and   |
| does not work for complicated rates that do not have direct      |
| recalculation into the trade account's base currency.            |
+------------------------------------------------------------------+
double MarginCalculate(str symbol, double volume)
{
 str first    = StringSubstr(symbol,0,3); // the first symbol, for example,  EUR
 str second   = StringSubstr(symbol,3,3); // the second symbol, for example, USD
 str currency = AccountCurrency();        // deposit currency, for example,  USD
 double leverage = AccountLeverage();        // leverage, for example,       100
 contract size, for example, 100000
 double contract = MarketInfo(symbol, MODE_LOTSIZE);
 double bid      = MarketInfo(symbol, MODE_BID);      // Bid price
---- allow only standard forex symbols like XXXYYY
 if(StringLen(symbol) != 6)
   {
    Print("MarginCalculate: '",symbol,"' must be standard forex symbol XXXYYY");
    return(0.0);
   }
---- check for data availability
 if(bid <= 0 || contract <= 0)
   {
    Print("MarginCalculate: no market information for '",symbol,"'");
    return(0.0);
   }
---- check the simplest variations - without cross currencies
 if(first == currency)
     return(contract*volume / leverage);           // USDxxx
 if(second == currency)
     return(contract*bid*volume / leverage);       // xxxUSD
---- check cross currencies, search for direct conversion thru deposit currency
 str base = currency + first;                   // USDxxx
 if(MarketInfo(base, MODE_BID) > 0)
     return(contract / MarketInfo(base, MODE_BID)*volume / leverage);
---- try vice versa
 base = first + currency;                          // xxxUSD
 if(MarketInfo(base, MODE_BID) > 0)
     return(contract*MarketInfo(base, MODE_BID)*volume / leverage);
---- direct conversion is impossible
 Print("MarginCalculate: can not convert '",symbol,"'");
 return(0.0);
}
*/

#endif
