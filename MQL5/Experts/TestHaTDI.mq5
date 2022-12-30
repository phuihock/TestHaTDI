//+------------------------------------------------------------------+
//|                                                    TestHaTDI.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\MySignals\SignalTDI.mqh>
#include <Expert\Signal\MySignals\SignalHeikenAshi.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedRisk.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                  ="TestHaTDI";    // Document name
ulong                    Expert_MagicNumber            =22419;          //
bool                     Expert_EveryTick              =false;          //
//--- inputs for main signal
input int                Signal_ThresholdOpen          =10;             // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =10;             // Signal threshold value to close [0...100]
input double             Signal_PriceLevel             =0.0;            // Price level to execute a deal
input double             Signal_StopLevel              =50.0;           // Stop Loss level (in points)
input double             Signal_TakeLevel              =50.0;           // Take Profit level (in points)
input int                Signal_Expiration             =4;              // Expiration of pending orders (in bars)
input int                Signal_HaTDI_RSI_Period       =13;             // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input ENUM_APPLIED_PRICE Signal_HaTDI_RSI_Price        =PRICE_CLOSE;    // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input int                Signal_HaTDI_Volatility_Band  =34;             // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input double             Signal_HaTDI_StdDev           =1;              // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input int                Signal_HaTDI_RSI_Price_Line   =2;              // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input ENUM_MA_METHOD     Signal_HaTDI_RSI_Price_Type   =MODE_SMA;       // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input int                Signal_HaTDI_Trade_Signal_Line=7;              // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input ENUM_MA_METHOD     Signal_HaTDI_Trade_Signal_Type=MODE_SMA;       // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input ENUM_TIMEFRAMES    Signal_HaTDI_UpperTimeframe   =PERIOD_CURRENT; // HaTDI(13,PRICE_CLOSE,34,1,2,...)
input double             Signal_HaTDI_Weight           =1.0;            // HaTDI(13,PRICE_CLOSE,34,1,2,...) Weight [0...1.0]
input double             Signal_HeikenAshi_Weight      =1.0;            // Relative Strength Index Weight [0...1.0]
//--- inputs for trailing
input double             Trailing_ParabolicSAR_Step    =0.02;           // Speed increment
input double             Trailing_ParabolicSAR_Maximum =0.2;            // Maximum rate
//--- inputs for money
input double             Money_FixRisk_Percent         =1.0;            // Risk percentage
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CTDISignal
   CTDISignal *filter0=new CTDISignal;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.RSI_Period(Signal_HaTDI_RSI_Period);
   filter0.RSI_Price(Signal_HaTDI_RSI_Price);
   filter0.Volatility_Band(Signal_HaTDI_Volatility_Band);
   filter0.StdDev(Signal_HaTDI_StdDev);
   filter0.RSI_Price_Line(Signal_HaTDI_RSI_Price_Line);
   filter0.RSI_Price_Type(Signal_HaTDI_RSI_Price_Type);
   filter0.Trade_Signal_Line(Signal_HaTDI_Trade_Signal_Line);
   filter0.Trade_Signal_Type(Signal_HaTDI_Trade_Signal_Type);
   filter0.UpperTimeframe(Signal_HaTDI_UpperTimeframe);
   filter0.Weight(Signal_HaTDI_Weight);
//--- Creating filter CSignalHeikenAshi
   CSignalHeikenAshi *filter1=new CSignalHeikenAshi;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.Weight(Signal_HeikenAshi_Weight);
//--- Creation of trailing object
   CTrailingPSAR *trailing=new CTrailingPSAR;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.Step(Trailing_ParabolicSAR_Step);
   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
//--- Creation of money object
   CMoneyFixedRisk *money=new CMoneyFixedRisk;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixRisk_Percent);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
