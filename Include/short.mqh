#property copyright "void_xxx"
#property link      "yeet"
#property strict

#include "constants.mqh"
#include "variables.mqh"

#ifndef FILE_SHORT_SEEN
#define FILE_SHORT_SEEN

//price data
#define ASK(x)              SymbolInfoDouble(x, SYMBOL_ASK)
#define BID(x)              SymbolInfoDouble(x, SYMBOL_BID)
#define PT(x)               MarketInfo(x, MODE_POINT)
#define TICKVAL(x)          MarketInfo(x, MODE_TICKVALUE)
#define TICKSIZE(x)         MarketInfo(x, MODE_TICKSIZE)
#define PTVAL(x)            TICKVAL(x) / ((TICKSIZE(x)) / PT(x))
#define DIGITS(x)           SymbolInfoInteger(x, SYMBOL_DIGITS)
#define SPREAD(x)           (ASK(x) - BID(x))

//order information
#define OOP                 OrderOpenPrice()
#define OSL                 OrderStopLoss()
#define OTP                 OrderTakeProfit()
#define OS                  OrderSymbol()
#define OL                	OrderLots()
#define OTK					OrderTicket()
#define OTY                 OrderType()

//numeric
#define FLOOR(x)            MathFloor(x)
#define N2(x)               NormalizeDouble(x, 2)
#define N2FLOOR(x)			NormalizeDouble(FLOOR(x*100)/100, 2)
#define NP(x, y)            NormalizeDouble(x, PT(y))
#define ABS(x)              MathAbs(x)
#define MAX(x, y)           MathMax(x, y)
#define MIN(x, y)           MathMin(x, y)
#define MAX3(x, y, z)       MAX(x, MAX(y, z))
#define MIN3(x, y, z)       MIN(x, MIN(y, z))
#define MAX4(a, b, c, d)    MAX3(a, MAX3(b, c, d))
#define MIN4(a, b, c, d)    MIN3(a, MIN3(b, c, d))

//chart information
#define CPER                ChartPeriod()
#define NUMPAIRS            SymbolsTotal(false)

//string conversion
#define DTS(x, y)           DoubleToStr(x, y)
#define ITS(x)              IntegerToString(x)
#define D0S(x)				DTS(x, 0)
#define D1S(x)              DTS(x, 1)
#define D2S(x)              DTS(x, 2)
#define D3S(x)              DTS(x, 3)
#define D4S(x)              DTS(x, 4)
#define D5S(x)              DTS(x, 5)
#define D6S(x)              DTS(x, 6)
#define D7S(x)              DTS(x, 7)
#define D8S(x)              DTS(x, 8)
#define DdS(x)              DTS(x, Digits)
#define DsS(x, y)           DTS(x, DIGITS(y))
#define ERR               	getErrorMessage(GetLastError())

//syntax shortenings
#define str                 string
#define no                  false
#define ya                  true

//account information
#define CASH                (AccountFreeMargin() - totalInSL())
#define MIN_RISK			MIN_RISK_FACTOR*CASH
#define MAX_RISK			MAX_RISK_FACTOR*CASH
#define ORDERS				OrdersTotal()

//argument shortenings
#define DEBUGS              bool v = no
#define LOTARG              double lots = 0.0
#define SHIFTY              int shift = 0
#define INSECT				ya

#endif

