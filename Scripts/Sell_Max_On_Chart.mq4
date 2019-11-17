#property copyright "void_xxx"
#property link      "yeet"
#property version   "1.00"
#property strict
#include "../Include/order_management.mqh"

void OnStart() { OrderMax(ChartSymbol(), OP_SELL); }
