//+------------------------------------------------------------------+
//|                                                   HeikenAshi.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Indicators\Indicators.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiHeikenAshi : public CIndicator
  {
public:
                     CiHeikenAshi(void);
                    ~CiHeikenAshi(void);
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period);
   //--- methods of access to indicator data
   double            Open(const int index) const;
   double            High(const int index) const;
   double            Low(const int index) const;
   double            Close(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
   virtual bool      Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[]);
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiHeikenAshi::CiHeikenAshi(void)
  {
   
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiHeikenAshi::~CiHeikenAshi(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the "Heiken Ashi" indicator                               |
//+------------------------------------------------------------------+
bool CiHeikenAshi::Create(const string symbol,const ENUM_TIMEFRAMES period)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle = iCustom(symbol, period, "\\Indicators\\Heiken_Ashi");

//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period))
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
bool CiHeikenAshi::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[])
  {
   return(Initialize(symbol,period));
  }
//+------------------------------------------------------------------+
//| Initialize the indicator with special parameters                 |
//+------------------------------------------------------------------+
bool CiHeikenAshi::Initialize(const string symbol,const ENUM_TIMEFRAMES period)
  {
   if(CreateBuffers(symbol,period,5))
     {
      //--- string of status of drawing
      m_name  ="Heiken Ashi";
      m_status="("+symbol+","+PeriodDescription()+") H="+IntegerToString(m_handle);
      //--- create buffers
      ((CIndicatorBuffer*)At(0)).Name("Open");
      ((CIndicatorBuffer*)At(1)).Name("High");
      ((CIndicatorBuffer*)At(2)).Name("Low");
      ((CIndicatorBuffer*)At(3)).Name("Close");
      //--- ok
      return(true);
     }
//--- error
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiHeikenAshi::Open(const int index) const
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
double CiHeikenAshi::High(const int index) const
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
double CiHeikenAshi::Low(const int index) const
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
double CiHeikenAshi::Close(const int index) const
  {
   CIndicatorBuffer *buffer=At(3);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
