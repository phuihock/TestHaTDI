//+------------------------------------------------------------------+
//|                                                    SignalHeikenAshi.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#include "Indicators\HeikenAshi.mqh"
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of oscillator '--- Heiken Ashi'                    |
//| Type=SignalAdvanced                                              |
//| Name=Relative Strength Index                                     |
//| ShortName=HeikenAshi                                             |
//| Class=CSignalHeikenAshi                                          |
//| Page=signal_rsi                                                  |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalHeikenAshi.                                         |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Relative Strength Index' oscillator.               |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalHeikenAshi : public CExpertSignal
  {
protected:
   CiHeikenAshi             m_heikenashi;            // object-oscillator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "current close vs current open"
   int               m_pattern_1;      // model 1 "(with confirmation) current close vs current open + current close vs previous open"
public:
                     CSignalHeikenAshi(void);
                    ~CSignalHeikenAshi(void);
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;           }

   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the oscillator
   bool              InitHeikenAshi(CIndicators *indicators);
   //--- methods of getting data
   double            Open(int ind)                       { return(m_heikenashi.Open(ind));   }
   double            High(int ind)                       { return(m_heikenashi.High(ind));   }
   double            Low(int ind)                        { return(m_heikenashi.Low(ind));    }
   double            Close(int ind)                      { return(m_heikenashi.Close(ind));  }

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalHeikenAshi::CSignalHeikenAshi(void) : m_pattern_0(50), m_pattern_1(70)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalHeikenAshi::~CSignalHeikenAshi(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalHeikenAshi::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalHeikenAshi::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize HeikenAshi oscillator
   if(!InitHeikenAshi(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize HeikenAshi oscillators.                                      |
//+------------------------------------------------------------------+
bool CSignalHeikenAshi::InitHeikenAshi(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_heikenashi)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_heikenashi.Create(m_symbol.Name(),m_period))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalHeikenAshi::LongCondition(void)
  {
   int result=0;
   int idx=StartIndex();
//---
   if(Close(idx) > Open(idx) && Close(idx) > Open(idx+1))
     {
      result = m_pattern_1;
     }
   if(Close(idx) > Open(idx))
     {
      result = m_pattern_0;
     }

//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalHeikenAshi::ShortCondition(void)
  {
   int result=0;
   int idx=StartIndex();
//---
   if(Close(idx) < Open(idx) && Close(idx) < Open(idx+1))
     {
      result = m_pattern_1;
     }
   if(Close(idx) < Open(idx))
     {
      result = m_pattern_0;
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
