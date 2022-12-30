//+------------------------------------------------------------------+
//|                                                      Pennant.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Indicators\Indicator.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiTDI : public CIndicator
  {
public:
                     CiTDI(void);
                    ~CiTDI(void);
   //--- method of creating
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period, int RSI_Period, ENUM_APPLIED_PRICE RSI_Price, int Volatility_Band, double StdDev, int RSI_Price_Line, ENUM_MA_METHOD RSI_Price_Type, int Trade_Signal_Line, ENUM_MA_METHOD Trade_Signal_Type, ENUM_TIMEFRAMES UpperTimeframe);
   //--- methods of access to data of indicator
   double            VB_High(const int index) const;
   double            Market_Base_Line(const int index) const;
   double            VB_Low(const int index) const;
   double            RSI_Price_Line(const int index) const;
   double            Trade_Signal_Line(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
   virtual bool      Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[]);
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,int RSI_Period, ENUM_APPLIED_PRICE RSI_Price, int Volatility_Band, double StdDev, int RSI_Price_Line, ENUM_MA_METHOD RSI_Price_Type, int Trade_Signal_Line, ENUM_MA_METHOD Trade_Signal_Type, ENUM_TIMEFRAMES UpperTimeframe);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiTDI::CiTDI(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiTDI::~CiTDI(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the "Accelerator Oscillator" indicator                    |
//+------------------------------------------------------------------+
bool CiTDI::Create(const string symbol,const ENUM_TIMEFRAMES period, int RSI_Period, ENUM_APPLIED_PRICE RSI_Price, int Volatility_Band, double StdDev, int RSI_Price_Line, ENUM_MA_METHOD RSI_Price_Type, int Trade_Signal_Line, ENUM_MA_METHOD Trade_Signal_Type, ENUM_TIMEFRAMES UpperTimeframe)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iCustom(symbol,period,"\\Indicators\\TradersDynamicIndex", RSI_Period, RSI_Price, Volatility_Band, StdDev, RSI_Price_Line, RSI_Price_Type, Trade_Signal_Line, Trade_Signal_Type, UpperTimeframe);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- idicator successfully created
   if(!Initialize(symbol,period,RSI_Period, RSI_Price, Volatility_Band, StdDev, RSI_Price_Line, RSI_Price_Type, Trade_Signal_Line, Trade_Signal_Type, UpperTimeframe))
     {
      //--- initialization failed
      IndicatorRelease(m_handle);
      m_handle=INVALID_HANDLE;
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize the indicator with universal parameters               |
//+------------------------------------------------------------------+
bool CiTDI::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[])
  {
   return(Initialize(symbol,period,
                     (int)params[0].integer_value,
                     (ENUM_APPLIED_PRICE)params[1].integer_value,
                     (int)params[2].integer_value,
                     (double)params[3].integer_value,
                     (int)params[4].integer_value,
                     (ENUM_MA_METHOD)params[5].integer_value,
                     (int)params[6].integer_value,
                     (ENUM_MA_METHOD)params[7].integer_value,
                     (ENUM_TIMEFRAMES)params[8].integer_value
                    ));
  }
      //+------------------------------------------------------------------+
      //| Initialize the indicator with special parameters                 |
      //+------------------------------------------------------------------+
      bool CiTDI::Initialize(const string symbol,const ENUM_TIMEFRAMES period,int RSI_Period,ENUM_APPLIED_PRICE RSI_Price,int Volatility_Band,double StdDev,int RSI_Price_Line,ENUM_MA_METHOD RSI_Price_Type,int Trade_Signal_Line,ENUM_MA_METHOD Trade_Signal_Type,ENUM_TIMEFRAMES UpperTimeframe)
  {
   if(CreateBuffers(symbol,period,5))
     {
      //--- string of status of drawing
      m_name  ="TDI";
      m_status="("+symbol+","+PeriodDescription()+") H="+IntegerToString(m_handle);
      //--- create buffers
      ((CIndicatorBuffer*)At(0)).Name("VB High");
      ((CIndicatorBuffer*)At(1)).Name("Market Base Line");
      ((CIndicatorBuffer*)At(2)).Name("VB Low");
      ((CIndicatorBuffer*)At(3)).Name("RSI Price Line");
      ((CIndicatorBuffer*)At(4)).Name("Trade Signal Line");
      //--- ok
      return(true);
     }
//--- error
   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiTDI::VB_High(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiTDI::Market_Base_Line(const int index) const
  {
   CIndicatorBuffer *buffer=At(1);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiTDI::VB_Low(const int index) const
  {
   CIndicatorBuffer *buffer=At(2);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiTDI::RSI_Price_Line(const int index) const
  {
   CIndicatorBuffer *buffer=At(3);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiTDI::Trade_Signal_Line(const int index) const
  {
   CIndicatorBuffer *buffer=At(4);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
