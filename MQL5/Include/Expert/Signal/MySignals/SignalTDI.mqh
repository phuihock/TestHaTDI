//+------------------------------------------------------------------+
//|                                                OsFraMASignal.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Expert\ExpertSignal.mqh>
#include "Indicators\TDI.mqh"
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator '-- TDI'                              |
//| Type=SignalAdvanced                                              |
//| Name=HaTDI                                                       |
//| ShortName=HaTDI                                                  |
//| Class=CTDISignal                                                 |
//| Page=                                                            |
//| Parameter=RSI_Period,int,13,RSI_Period                           |
//| Parameter=RSI_Price,ENUM_APPLIED_PRICE,PRICE_CLOSE,RSI_Price     |
//| Parameter=Volatility_Band,int,34,Volatility_Band                 |
//| Parameter=StdDev,double,1,StdDev                                 |
//| Parameter=RSI_Price_Line,int,2,RSI_Price_Line                    |
//| Parameter=RSI_Price_Type,ENUM_MA_METHOD,MODE_SMA,RSI_Price_Type  |
//| Parameter=Trade_Signal_Line,int,7,Trade_Signal_Line              |
//| Parameter=Trade_Signal_Type,ENUM_MA_METHOD,MODE_SMA,Trade_Signal_Type  |
//| Parameter=UpperTimeframe,ENUM_TIMEFRAMES,PERIOD_CURRENT,UpperTimeframe |
//+------------------------------------------------------------------+
// wizard description end

//+---------------------------------------------------------------------+
//| https://discord.com/channels/949575367360929812/1057979136137756702 |
//+---------------------------------------------------------------------+
class CTDISignal: public CExpertSignal
  {
protected:
   CiTDI             m_ci;
   int               m_pattern_0; // model 0 "scalping"
   int               m_pattern_1; // model 1 "short-term trading"
   int               m_pattern_2; // model 2 "medium-term trading"
   int               m_rsi_period; // RSI_Period: 8-25
   ENUM_APPLIED_PRICE m_rsi_price;
   int               m_volatility_band; // Volatility_Band: 20-40
   double            m_stddev; // Standard Deviations: 1-3
   int               m_rsi_price_line;
   ENUM_MA_METHOD    m_rsi_price_type;
   int               m_trade_signal_line;
   ENUM_MA_METHOD    m_trade_signal_type;
   ENUM_TIMEFRAMES   m_uppertimeframe; // UpperTimeframe: If above current will display values from  that timeframe.
public:
                     CTDISignal();
   void              RSI_Period(int value) {m_rsi_period=value;}
   void              RSI_Price(ENUM_APPLIED_PRICE value) { m_rsi_price=value;}
   void              Volatility_Band(int value) {m_volatility_band=value;}
   void              StdDev(double value) {m_stddev=value;}
   void              RSI_Price_Line(int value) {m_rsi_price_line=value;}
   void              RSI_Price_Type(ENUM_MA_METHOD value) {m_rsi_price_type=value;}
   void              Trade_Signal_Line(int value) {m_trade_signal_line=value;}
   void              Trade_Signal_Type(ENUM_MA_METHOD value) {m_trade_signal_type=value;}
   void              UpperTimeframe(ENUM_TIMEFRAMES value) {m_uppertimeframe=value;}
   bool              ValidationSettings() override;
   bool              InitIndicators(CIndicators* indicators) override;
   int               LongCondition() override;
   int               ShortCondition() override;
  };

//+------------------------------------------------------------------+
CTDISignal::CTDISignal() :
   m_pattern_0(50),
   m_pattern_1(60),
   m_pattern_2(70),
   m_rsi_period(13),
   m_rsi_price(PRICE_CLOSE),
   m_volatility_band(34),
   m_stddev(1),
   m_rsi_price_line(2),
   m_rsi_price_type(MODE_SMA),
   m_trade_signal_line(7),
   m_trade_signal_type(MODE_SMA),
   m_uppertimeframe(PERIOD_CURRENT)
  {
   m_used_series=USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTDISignal::ValidationSettings()
  {
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTDISignal::InitIndicators(CIndicators* indicators)
  {
   if(indicators==NULL)
      return(false);

   if(!m_ci.Create(m_symbol.Name(), m_period, m_rsi_period, m_rsi_price, m_volatility_band, m_stddev, m_rsi_price_line, m_rsi_price_type, m_trade_signal_line, m_trade_signal_type, m_uppertimeframe))
     {
      printf(__FUNCTION__+": object initialization error");
     }
   if(!indicators.Add(GetPointer(m_ci)))
     {
      printf(__FUNCTION__+": object adding error");
     }
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CTDISignal::LongCondition()
  {
   int idx = StartIndex();
   double rsi_price_line = m_ci.RSI_Price_Line(idx);
   double trade_signal_line = m_ci.Trade_Signal_Line(idx);
   double market_base_line = m_ci.Market_Base_Line(idx);
// go long under the same conditions as for the short-term trading but only when all lines are below 50
   if(rsi_price_line > trade_signal_line && rsi_price_line > market_base_line && rsi_price_line < 50 && trade_signal_line < 50 && market_base_line < 50)
      return m_pattern_2;

// enter long when the green is above both the red and the yellow lines; enter short when the red one is above both the green and the yellow ones.
   if(rsi_price_line > trade_signal_line && rsi_price_line > market_base_line)
      return m_pattern_1;

// enter long when the green line is above the red line and enter short when the red line is the above green line.
   if(rsi_price_line > trade_signal_line)
      return m_pattern_0;

   return 0;
  }
//+------------------------------------------------------------------+
int CTDISignal::ShortCondition()
  {
   int idx = StartIndex();
   double rsi_price_line = m_ci.RSI_Price_Line(idx);
   double trade_signal_line = m_ci.Trade_Signal_Line(idx);
   double market_base_line = m_ci.Market_Base_Line(idx);
   if(rsi_price_line < trade_signal_line && rsi_price_line < market_base_line && rsi_price_line > 50 && trade_signal_line > 50 && market_base_line > 50)
      return m_pattern_2;

   if(rsi_price_line < trade_signal_line && rsi_price_line < market_base_line)
      return m_pattern_1;

   if(rsi_price_line < trade_signal_line)
      return m_pattern_0;

   return 0;
  }
//+------------------------------------------------------------------+
