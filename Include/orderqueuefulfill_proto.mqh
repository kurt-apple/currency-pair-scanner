#include "short.mqh"

double getSL(string p, double factor) {
	return 0;
}

short OrderQueueFulfill(string p, short queue, int magic, double liquidity)
{	double lots = dynamiclots(p);
	t = 0;
	if(OrdersTotal() > 0)
	{	for(int i = OrdersTotal() - 1; i >= 0; i--)
		{	if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			{	Alert("error selecting order");
				return queue;
			}
			else
			{	if(OrdersTotalType(magic) == OP_BUY)
				{	if(queue < 0)
					{	if(OL > 0.01)
						{	if(!OrderClose(OTK, 0.01, BID(OS), 10))
							{	Alert("error closing order: " + ERR);
							}
						}
						if(OSL+5*PT(p) <= BID(p) - 5*PT(p))
						{	if(!Trail(OTK, 5*PT(p)))
							{	Alert("error closing order: " + ERR);
								ExitProgram();
							}
							return ++queue;
				}	}	}
				else if(OrdersTotalType(magic) == OP_SELL)
				{	if(queue > 0)
					{	if(OL > 0.01)
						{	if(!OrderClose(OTK, 0.01, ASK(OS), 10))
							{	Alert("error closing order: " + ERR);
						}	}
						if(OSL-5*PT(p) <= ASK(p) + 5*PT(p))
						{	if(!Trail(OTK, 5*PT(p)))
							{	Alert("error closing order: " + ERR);
								ExitProgram();
							}
							return --queue;
	}	}	}	}	}	}
	if(queue != 0)
	{	if(OrdersTotal() < MAXORDERS)
		{	if(queue > 0)
			{	if(OrdersTotalType(magic) != OP_SELL && isGoodEntry(OP_BUY, p))
				{	t = OrderSend(p, OP_BUY, lots, ASK(p), 10, BID(p) - getSL(p, factor), 0, NULL, magic);
					queue--;
			}	}
			else if(queue < 0)
			{	if(OrdersTotalType(magic) != OP_BUY && isGoodEntry(OP_SELL, p))
				{	t = OrderSend(p, OP_SELL, lots, BID(p), 10, ASK(p) + getSL(p, factor), 0, NULL, magic);
					queue++;
	}	}	}	}
	if(t < 0)
	{	Alert("OrderERR: " + p + " L:" + D1S(lots,1) + " | ATR:"+DdS(getSL(p, 1.0), p));
		Alert("ErrorCode: " + ERR);
		ExitProgram();
	}
	return queue;
}
