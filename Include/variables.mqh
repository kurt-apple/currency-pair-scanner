#ifndef FILE_VARIABLES_SEEN
#define FILE_VARIABLES_SEEN

//used in calculations when a quantity of bars is passed as an argument
//for instance, price_analysis:barsInTimeframe(string, int, int, bool)
#define MINBARS 		6

//maximum number of points slippage to allow
#define SLIP            2

//minimum stoploss as multiple of spread
#define MINBYSPREAD     2.5

//minimum stoploss as multiple of ATR
#define MINATR          1.5

//maximum stoploss as multiple of ATR
#define MAXATR          5

//target Reward-to-Risk.
#define RR              2.5

//average hold time, in minutes, of all trades
#define AVGHOLD 		64

//for rolling comment system, max out
#define LINES_OF_COMMENT 6

//as percent of account. 0.25 = 25% of cash not tied up in trade
#define MAX_RISK_FACTOR 		0.10
#define MIN_RISK_FACTOR			0.01

#endif
