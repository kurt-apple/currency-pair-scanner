#property copyright "void_xxx"
#property link      "yeet"
#property strict

#ifndef FILE_STRUCTS_SEEN
#define FILE_STRUCTS_SEEN

struct pair_value {
   string pair;
   double value;
};

struct order_prep {
    string p;
    int ot;
    double lots;
    double sl; //points sl from open price
    double tp; //points tp from open price
};

struct error_msg {
   int id;
   string msg;
};

#endif

