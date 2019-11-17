#property copyright "void_xxx"
#property link      "yeet"
#property strict

#include "structs.mqh"
#include "short.mqh"
#include "price_analysis.mqh"

#ifndef FILE_SL_LEVELS_SEEN
#define FILE_SL_LEVELS_SEEN

double slv(order_prep &op) { return op.ot == OP_BUY ? slvb(op) : slvs(op); }
double slvs(order_prep &op) { return BID(op.p) + op.tp; }
double slvb(order_prep &op) { return ASK(op.p) - op.tp; }

order_prep maxSL_Long(order_prep &op, DEBUGS) {
    op.sl = N2FLOOR((CASH - marginLong(op.p, op.lots)) / (PTVAL(op.p) * op.lots));
    if(v) Print("maxSL_Long(" + op.p + "): lots = " + D2S(op.lots) + ", should be SL = " + D0S(op.sl));
    if(v && op.sl <= 0) Print("maxSL(" + op.p + "): SLpoints is " + D0S(op.sl) + ", which ain't right.");
    return op;
}

order_prep maxSL_Sell(order_prep &op, DEBUGS) {
    op.sl = N2FLOOR((CASH - marginSell(op.p, op.lots)) / (PTVAL(op.p) * op.lots));
    if(v) Print("maxSL_Sell(" + op.p + "): lots = " + D2S(op.lots) + ", should be SL = " + D0S(op.sl));
    if(v && op.sl <= 0) Print("maxSL(" + op.p + "): SLpoints is " + D0S(op.sl) + ", which ain't right.");
    return op;
}

//started checking 10/28/2019
void marginSL_Long(order_prep &op, DEBUGS) {
    op.lots = op.lots < 0.01 ? maxLong(op.p, v) : op.lots;
    double maxMarginReq = marginLong(op.p, op.lots, v);
    double SLvalue, marginLeftPerLot, ptValForLots, freemargin;
    while(op.lots >= 0.01) {
        maxMarginReq = marginLong(op.p, op.lots, v);
        freemargin = CASH - maxMarginReq;
        if(v) Print("marginSL_Long: liquid CASH = $" + D2S(CASH) + ", maxMarginReq for " + D2S(op.lots) + " lots = $" + D2S(maxMarginReq) + ". freemargin = $" + D2S(freemargin) + ". PTVAL = $" + D2S(PTVAL(op.p)));
        ptValForLots = PTVAL(op.p) * op.lots;
        if(freemargin < 0 && v) Print("marginSL_Long(" + op.p + "): freemargin is below maxMarginReq ($" + D2S(maxMarginReq) + "). free margin = $" + D2S(freemargin) + ". maxMarginReq = $" + D2S(maxMarginReq));
        SLvalue = N2FLOOR(freemargin / ptValForLots);
        if(SLvalue > 1 && freemargin > MIN_RISK) {
            if(v) Print("marginSL_Long(" + op.p + "): margin SL = " + D0S(SLvalue));
        }
        else {
            if(v) Print("WARN: marginSL_Long(" + op.p + "): lots = " + D2S(op.lots) + ", SLvalue = " + D0S(SLvalue) + " < one point");
            op.lots -= 0.01;
        }
    }
    if(v) Print("marginSL_Long(" + op.p + "): couldn't make it work.");
}

void marginSL_Sell(order_prep &op, DEBUGS) {
	op.lots = op.lots < 0.01 ? maxSell(op.p, v) : op.lots;
    double maxMarginReq = marginSell(op.p, op.lots, v);
    double marginLeftPerLot, ptValForLots, freemargin;
    while(op.lots >= 0.01) {
        maxMarginReq = marginSell(op.p, op.lots, v);
        freemargin = CASH - maxMarginReq;
        if(v) Print("marginSL_Sell: liquid CASH = $" + D2S(CASH) + ", maxMarginReq for " + D2S(op.lots) + " lots = $" + D2S(maxMarginReq) + ". freemargin = $" + D2S(freemargin) + ". PTVAL = $" + D2S(PTVAL(op.p)));
        ptValForLots = PTVAL(op.p) * op.lots;
        if(freemargin < 0 && v) Print("marginSL_Sell(" + op.p + "): freemargin is below maxMarginReq. free margin = $" + D2S(freemargin) + ". maxMarginReq = $" + D2S(maxMarginReq));
        if(v) Print("marginSL_Sell(" + op.p + "): ptval for " + D2S(op.lots) + " lots: $" + D2S(ptValForLots) + ". Points until Margin Stop: " + D1S(op.sl) + " worth $" + D2S(ptValForLots * op.sl));
        op.sl = N2FLOOR(freemargin / ptValForLots);
        if(op.sl > 1) {
            if(v) Print("marginSL_Long(" + op.p + "): margin SL = " + D0S(op.sl));
        }
        else {
            if(v) Print("WARN: marginSL_Sell(" + op.p + "): SLvalue = " + D2S(op.sl) + " < one point");
            op.lots -= 0.01;
        }
    }
    if(v) Print("marginSL_Sell(" + op.p + "): couldn't make it work.");
}

void atrSL(order_prep &op, double multiple, DEBUGS) {
    multiple * iATR(op.p, CPER, 14, 0);
}

//SL based on total range from highest high to lowest low in given timeframe
void totalRangeSL(order_prep &op, DEBUGS) {
    op.sl = totalRange(op.p, CPER, v) + MINBYSPREAD * SPREAD(op.p);
}

//SL based on range from current price to lowest low of range in given timeframe
void dirRangeSL(order_prep &op, DEBUGS) {
    if(op.ot == OP_BUY) dirRangeSL_Long(op, v);
    else dirRangeSL_Sell(op, v);
}

void dirRangeSL_Long(order_prep &op, DEBUGS) {
	op.sl = (loRange(op.p, CPER, v) + MINBYSPREAD * SPREAD(op.p)) / PT(op.p);
}

void dirRangeSL_Sell(order_prep &op, DEBUGS) {
    op.sl = (hiRange(op.p, CPER, v) + MINBYSPREAD * SPREAD(op.p)) / PT(op.p);
}

//SL based on spread. Probably not a good idea.
void spreadSL(order_prep &op, DEBUGS) { MINBYSPREAD * SPREAD(op.p); }

//TODO: aggregate all SL calculations and create a smart SL value
void getSL(order_prep &op, DEBUGS) {
    if(op.ot == OP_BUY) getSL_Long(op, v);
    else getSL_Sell(op, v);
}

void getSL_Long(order_prep &op, DEBUGS) {
    op.lots = (op.lots < 0.01 ? maxLong(op.p, v) : op.lots);
    spreadSL(op, v);
    op.tp = 0.0;
    order_prep tmp_margin = op, tmp_range = op;
    marginSL_Long(tmp_margin, v);
    dirRangeSL_Long(tmp_range, v);
    double MINSL = MAX(op.sl, tmp_range.sl);
    while(tmp_margin.sl < MINSL && op.lots >= 0.01) {
        if(v) Print("getSL_Long(" + op.p + "): marginSL " + DsS(tmp_margin.sl, op.p) + " < MINSL " + DsS(MINSL, op.p) + ", decreasing lots to " + D2S(op.lots - 0.01));
        tmp_margin.lots -= 0.01;
        marginSL_Long(tmp_margin, v);
    }
    if(v) Print("getSL_Long(" + op.p + "): SL will be: " + (tmp_margin.sl < MINSL ? "marginSL: " + D2S(tmp_margin.sl) : "MINSL: " + D2S(MINSL)));
    //if(v) Print("getSL_Long(" + p + "): Sanity check... MIN(marginSL " + D0S(marginSL) + ", MINSL " + D0S(MINSL) + " ) = " + D0S(MIN(marginSL, MINSL)));
    op.sl = MIN(tmp_margin.sl, MINSL);
    if(v) Print("getSL_Long: returning SL in OP variable: " + D0S(op.sl));
}

void getSL_Sell(order_prep &op, DEBUGS) {
    op.lots = (op.lots < 0.01 ? maxSell(op.p, v) : op.lots);
    spreadSL(op, v);
    op.tp = 0.0;
    order_prep tmp_margin = op, tmp_range = op;
    marginSL_Sell(tmp_margin, v);
    dirRangeSL_Sell(tmp_range, v);
    double MINSL = MIN(op.sl, tmp_range.sl);
    while(tmp_margin.sl < MINSL && op.lots >= 0.01) {
        if(v) Print("getSL_Sell(" + op.p + "): marginSL " + DsS(tmp_margin.sl, op.p) + " > MINSL " + DsS(MINSL, op.p) + ", decreasing lots to " + D2S(op.lots - 0.01));
        tmp_margin.lots -= 0.01;
        marginSL_Sell(tmp_margin, v);
    }
    if(v) Print("getSL_Sell(" + op.p + "): SL will be: " + (tmp_margin.sl < MINSL ? "marginSL: " + D2S(tmp_margin.sl) : "MINSL: " + D2S(MINSL)));
    //if(v) Print("getSL_Sell(" + p + "): Sanity check... MIN(marginSL " + D0S(marginSL) + ", MINSL " + D0S(MINSL) + " ) = " + D0S(MIN(marginSL, MINSL)));
    op.sl = MIN(tmp_margin.sl, MINSL);
    if(v) Print("getSL_Sell: returning SL in OP variable: " + D0S(op.sl));
}

#endif
