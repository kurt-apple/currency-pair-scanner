#property copyright "void_xxx"
#property link      "yeet"
#property strict

#include "structs.mqh"
#include "price_analysis.mqh"

#ifndef FILE_TP_LEVELS_SEEN
#define FILE_TP_LEVELS_SEEN

double tpv(order_prep &op) { return op.ot == OP_BUY ? tpvb(op) : tpvs(op); }
double tpvs(order_prep &op) { return BID(op.p) - op.tp; }
double tpvb(order_prep &op) { return ASK(op.p) + op.tp; }

double marginTP(str p, int ot, LOTARG, DEBUGS) {
    if(ot == OP_BUY) return marginTP_Long(p, lots, v);
    else return marginTP_Sell(p, lots, v);
}

double marginTP_Long(str p, LOTARG, DEBUGS) {
    //cost per lot
    double perLot = marginLong(p);
    //max lots you can afford of symbol p
    double maxLots = N2(lots) == 0 ? maxLong(p, v) : lots;
    double maxMarginReq, marginLeft, TPvalue, marginLeftPerLot, ptValForLots;
    const double freemargin = CASH, ptval = PTVAL(p), RRII = RR + 1;
    while(maxLots > 0.01) {
        maxMarginReq = maxLots * perLot;
        marginLeft = freemargin - maxMarginReq;
        marginLeftPerLot = marginLeft / maxLots;
        ptValForLots = ptval * maxLots;
        TPvalue = ((marginLeftPerLot / RRII) / ptValForLots);
        if(TPvalue >= PT(p)) return TPvalue;
        else maxLots -= 0.01;
    }
    return -1;
}

double marginTP_Sell(str p, LOTARG, DEBUGS) {
    //cost per lot
    double perLot = marginSell(p);
    //max lots you can afford of symbol p
    double maxLots = N2(lots) == 0 ? maxSell(p, v) : lots;
    double maxMarginReq, marginLeft, TPvalue, marginLeftPerLot, ptValForLots;
    const double freemargin = CASH, ptval = PTVAL(p), RRII = RR + 1;
    while(maxLots > 0.01) {
        maxMarginReq = maxLots * perLot;
        marginLeft = freemargin - maxMarginReq;
        marginLeftPerLot = marginLeft / maxLots;
        ptValForLots = ptval * maxLots;
        TPvalue = ((marginLeftPerLot / RRII) / ptValForLots);
        if(TPvalue >= PT(p)) return TPvalue;
        else maxLots -= 0.01;
    }
    return -1;
}

double atrTP(str p, double multiple, DEBUGS) {
    return multiple * iATR(p, CPER, 14, 0);
}

double totalRangeTP(str p, DEBUGS) {
    return totalRange(p, CPER, 2*barsInTF(p, CPER, v)) + MINBYSPREAD * SPREAD(p);
}

//SL based on range from current price to lowest low of range in given timeframe
double dirRangeTP(str p, int ot, DEBUGS) {
    if(ot == OP_BUY) return dirRangeTP_Long(p, v);
    else return dirRangeTP_Sell(p, v);
}

double dirRangeTP_Long(str p, DEBUGS) {
    return (loRange(p, CPER, v) + MINBYSPREAD * SPREAD(p)) / PT(p);
}

double dirRangeTP_Sell(str p, DEBUGS) {
    return (hiRange(p, CPER, v) + MINBYSPREAD * SPREAD(p)) / PT(p);
}

double spreadTP(str p, DEBUGS) { return (MINBYSPREAD * SPREAD(p)) / PT(p); }

order_prep getTP(str p, int ot, LOTARG, DEBUGS) {
    return ot == OP_BUY ? getTP_Long(p, lots, v) : getTP_Sell(p, lots, v);
}

order_prep getTP_Long(str p, double lots, DEBUGS) {
    order_prep op;
    op.p = p;
    op.lots = lots;
    op.sl = 0.0;
    op.tp = MAX3(spreadTP(p, v),
        marginTP_Long(p, op.lots, v),
        dirRangeTP_Long(p, v));
    return op;
}

order_prep getTP_Sell(str p, double lots, DEBUGS) {
    order_prep op;
    op.p = p;
    op.lots = lots;
    op.sl = 0.0;
    op.tp = MAX3(spreadTP(p, v),
        marginTP_Sell(p, op.lots, v),
        dirRangeTP_Sell(p, v));
    return op;
}

double getTP_Long_Points(str p, double lots, DEBUGS) {
	//if(v) Print("getTP_Sell_Points(" + p + "): spreadTP: " + D0S(spreadTP(p, v)) + ", marginTP_Long: " + D0S(marginTP_Long(p, lots, v)) + ", dirRangeTP_Long: " + D0S(dirRangeTP_Long(p, v)));
	return MAX3(spreadTP(p, v),
        marginTP_Long(p, lots, v),
        dirRangeTP_Long(p, v));
}

double getTP_Sell_Points(str p, double lots, DEBUGS) {
	//if(v) Print("getTP_Sell_Points(" + p + "): spreadTP: " + D0S(spreadTP(p, v)) + ", marginTP_Sell: " + D0S(marginTP_Sell(p, lots, v)) + ", dirRangeTP_Sell: " + D0S(dirRangeTP_Sell(p, v)));
	return MAX3(spreadTP(p, v),
        marginTP_Sell(p, lots, v),
        dirRangeTP_Sell(p, v));
}

#endif
