#property copyright "void_xxx"
#property link      "yeet"
#property strict

#include "structs.mqh"

#ifndef FILE_CONSTANTS_SEEN
#define FILE_CONSTANTS_SEEN

const error_msg MT4Errors[] = {
   { 0,    "No error returned."  },
   { 1,    "No error returned, but the result is unknown."  },
   { 2,    "Common error."  },
   { 3,    "Invalid trade parameters."  },
   { 4,    "Trade server is busy."  },
   { 5,    "Old version of the client terminal." },
   { 6,    "No connection with trade server." },
   { 7,    "Not enough rights." },
   { 8,    "Too frequent requests." },
   { 9,    "Malfunctional trade operation." },
   { 64,   "Account disabled." },
   { 65,   "Invalid account." },
   { 128,  "Trade timeout." },
   { 129,  "Invalid price." },
   { 130,  "Invalid stops." },
   { 131,  "Invalid trade volume." },
   { 132,  "Market is closed." },
   { 133,  "Trade is disabled." },
   { 134,  "Not enough money." },
   { 135,  "Price changed." },
   { 136,  "Off quotes." },
   { 137,  "Broker is busy." },
   { 138,  "Requote." },
   { 139,  "Order is locked." },
   { 140,  "Long positions only allowed." },
   { 141,  "Too many requests." },
   { 145,  "Modification denied because an order is too close to market." },
   { 146,  "Trade context is busy." },
   { 147,  "Expirations are denied by broker." },
   { 148,  "The amount of opened and pending orders has reached the limit set by a broker." },
   { 4000, "No error." },
   { 4001, "Wrong function pointer." },
   { 4002, "Array index is out of range." },
   { 4003, "No memory for function call stack." },
   { 4004, "Recursive stack overflow." },
   { 4005, "Not enough stack for parameter." },
   { 4006, "No memory for parameter string." },
   { 4007, "No memory for temp string." },
   { 4008, "Not initialized string." },
   { 4009, "Not initialized string in an array." },
   { 4010, "No memory for an array string." },
   { 4011, "Too long string." },
   { 4012, "Remainder from zero divide." },
   { 4013, "Zero divide." },
   { 4014, "Unknown command." },
   { 4015, "Wrong jump." },
   { 4016, "Not initialized array." },
   { 4017, "DLL calls are not allowed." },
   { 4018, "Cannot load library." },
   { 4019, "Cannot call function." },
   { 4020, "EA function calls are not allowed." },
   { 4021, "Not enough memory for a string returned from a function." },
   { 4022, "System is busy." },
   { 4050, "Invalid function parameters count." },
   { 4051, "Invalid function parameter value." },
   { 4052, "String function internal error." },
   { 4053, "Some array error." },
   { 4054, "Incorrect series array using." },
   { 4055, "Custom indicator error." },
   { 4056, "Arrays are incompatible." },
   { 4057, "Global variables processing error." },
   { 4058, "Global variable not found." },
   { 4059, "Function is not allowed in testing mode." },
   { 4060, "Function is not confirmed." },
   { 4061, "Mail sending error." },
   { 4062, "String parameter expected." },
   { 4063, "Integer parameter expected." },
   { 4064, "Double parameter expected." },
   { 4065, "Array as parameter expected." },
   { 4066, "Requested history data in updating state." },
   { 4067, "Some error in trade operation execution." },
   { 4099, "End of a file." },
   { 4100, "Some file error." },
   { 4101, "Wrong file name." },
   { 4102, "Too many opened files." },
   { 4103, "Cannot open file." },
   { 4104, "Incompatible access to a file." },
   { 4105, "No order selected." },
   { 4106, "Unknown symbol." },
   { 4107, "Invalid price." },
   { 4108, "Invalid ticket." },
   { 4109, "Trade is not allowed." },
   { 4110, "Longs are not allowed." },
   { 4111, "Shorts are not allowed." },
   { 4200, "Object already exists." },
   { 4201, "Unknown object property." },
   { 4202, "Object does not exist." },
   { 4203, "Unknown object type." },
   { 4204, "No object name." },
   { 4205, "Object coordinates error." },
   { 4206, "No specified subwindow." },
   { 4207, "Some error in object operation." },
};

string getErrorMessage(int error_id) {
   int a = 0, b = ArraySize(MT4Errors) - 1, middle = (a + b) / 2;
   while (a <= b) {
      if (MT4Errors[middle].id < error_id) a = middle + 1;
      else if (MT4Errors[middle].id == error_id)
         return "Error " + IntegerToString(error_id) + " - " + MT4Errors[middle].msg;
      else b = middle - 1;
      middle = (a + b) / 2;
   }
   return "undocumented error " + IntegerToString(error_id) + ", not in MT4 documentation";
}

pair_value LEVERAGE[] = {
	/*AUD pairs    */ {"AUDCAD", 0.03}, {"AUDCHF", 0.03}, {"AUDHKD", 0.05},
	{"AUDJPY", 0.04}, {"AUDNZD", 0.03}, {"AUDSGD", 0.05}, {"AUDUSD", 0.03},
	/*CAD pairs    */ {"CADCHF", 0.03}, {"CADHKD", 0.05}, {"CADJPY", 0.04},
	{"CADSGD", 0.05},
	/*CHF pairs    */ {"CHFHKD", 0.05}, {"CHFJPY", 0.04}, {"CHFZAR", 0.07},
	/*EUR pairs    */ {"EURAUD", 0.03}, {"EURCAD", 0.02}, {"EURCHF", 0.03},
	{"EURCZK", 0.05}, {"EURDKK", 0.02}, {"EURGBP", 0.05}, {"EURHKD", 0.05},
	{"EURHUF", 0.05}, {"EURJPY", 0.04}, {"EURNOK", 0.03}, {"EURNZD", 0.03},
	{"EURPLN", 0.05}, {"EURSEK", 0.03}, {"EURSGD", 0.05}, {"EURTRY", 0.12},
	{"EURUSD", 0.02}, {"EURZAR", 0.07},
	/*GBP pairs    */ {"GBPAUD", 0.05}, {"GBPCAD", 0.05}, {"GBPCHF", 0.05},
	{"GBPHKD", 0.05}, {"GBPJPY", 0.05}, {"GBPNZD", 0.05}, {"GBPPLN", 0.05},
	{"GBPSGD", 0.05}, {"GBPUSD", 0.05}, {"GBPZAR", 0.07},
	/*HKD pairs    */ {"HKDJPY", 0.05},
	/*NZD pairs    */ {"NZDCAD", 0.03}, {"NZDCHF", 0.03}, {"NZDHKD", 0.05},
	{"NZDJPY", 0.04}, {"NZDSGD", 0.05}, {"NZDUSD", 0.03},
	/*SGD pairs    */ {"SGDCHF", 0.05}, {"SGDHKD", 0.05}, {"SGDJPY", 0.05},
	/*TRY pairs    */ {"TRYJPY", 0.12},
	/*USD pairs    */ {"USDCAD", 0.02}, {"USDCHF", 0.03}, {"USDCNH", 0.05},
	{"USDCZK", 0.05}, {"USDDKK", 0.02}, {"USDHKD", 0.05}, {"USDHUF", 0.05},
	{"USDJPY", 0.04}, {"USDMXN", 0.08}, {"USDNOK", 0.03}, {"USDPLN", 0.05},
	{"USDSAR", 0.05}, {"USDSEK", 0.03}, {"USDSGD", 0.05}, {"USDTHB", 0.05},
	{"USDTRY", 0.12}, {"USDZAR", 0.07},
	/*ZAR pairs    */ {"ZARJPY", 0.07}
};

#endif

