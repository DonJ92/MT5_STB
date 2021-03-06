//+------------------------------------------------------------------+
//|                                        SAT's TREND BREAK New.mq5 |
//|                                      Copyright 2021, Joyce Kihm. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 15
#property indicator_plots 1

#property indicator_type1 DRAW_COLOR_LINE
#property indicator_width1 2
#property indicator_color1 clrGreen, clrMagenta , clrGray
#property indicator_label1 "TP/SL目安ライン"
/*
#property indicator_type2 DRAW_NONE
#property indicator_width2 1
#property indicator_color2 C'28, 213, 255'
#property indicator_label2 "Buy"

#property indicator_type3 DRAW_NONE
#property indicator_width3 1
#property indicator_color3 C'224, 237, 38' 
#property indicator_label3 "Sell"
*/

input int   InpStrength = 2;           // フィルター強度(1ずつ変更してください)
input bool  InpAlert = false;          // Enable Alert
input color InpLabelColor_L=clrWhite;  // Lのテキスト色
input color InpLabelColor_S=clrWhite;  // Sのテキスト色

#define OBJ_SIGN_NAME_PREFIX  "stb_sign_"

double ExtBuf_K2[];
double ExtBuf_K2Clr[];
double ExtBuf_Up[];
double ExtBuf_Dn[];
double ExtBuf_MA1[],
       ExtBuf_MA2[],
       ExtBuf_MA3[];
double ExtBuf_pDI[],
       ExtBuf_mDI[];
double ExtBuf_ATR[];       
       
double ExtBuf_RenkoStep[],
       ExtBuf_RenkoLevel[],
       ExtBuf_RenkoTrend[];
       
double ExtBuf_CondUp[];
double ExtBuf_CondDn[];

int   _ind_handle_MA1, 
      _ind_handle_MA2, 
      _ind_handle_MA3;      
int   _ind_handle_ADXWilder;
int   _ind_handle_ATR;

int   _barsCalculatedArr[5]={0};

#define  TREND_NA  0
#define  TREND_UP  1
#define  TREND_DN  -1

int      _lastTrend=TREND_NA;
datetime _lastAlertTime=0;

string   _obj_panel_name_prefix;
int      _obj_panel_name_prefix_len;
string   _obj_emoji_name_prefix;
int      _obj_emoji_name_prefix_len;
string   _obj_text_name_prefix;
int      _obj_text_name_prefix_len;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBuf_K2);
   SetIndexBuffer(1,ExtBuf_K2Clr,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtBuf_Up,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtBuf_Dn,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtBuf_MA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtBuf_MA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtBuf_MA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,ExtBuf_pDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,ExtBuf_mDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,ExtBuf_ATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,ExtBuf_RenkoStep,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,ExtBuf_RenkoLevel,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,ExtBuf_RenkoTrend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,ExtBuf_CondUp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,ExtBuf_CondDn,INDICATOR_CALCULATIONS);
   
   ArrayInitialize(ExtBuf_RenkoStep,EMPTY_VALUE);
   ArrayInitialize(ExtBuf_RenkoLevel,EMPTY_VALUE);
   ArrayInitialize(ExtBuf_RenkoTrend,EMPTY_VALUE);
   
   /*
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(1,PLOT_ARROW, 233);
   PlotIndexSetInteger(2,PLOT_ARROW, 234);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,20);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,-20);
   */
//---
   _ind_handle_MA1=iMA(NULL,0,2*InpStrength,0,MODE_EMA,PRICE_CLOSE);
   _ind_handle_MA2=iMA(NULL,0,5*InpStrength,0,MODE_EMA,PRICE_CLOSE);
   _ind_handle_MA3=iMA(NULL,0,10*InpStrength,0,MODE_EMA,PRICE_CLOSE);   
   _ind_handle_ADXWilder=iADXWilder(NULL,0,14);
   _ind_handle_ATR=iATR(NULL,0,14);
   
   if(_ind_handle_MA1==INVALID_HANDLE ||
      _ind_handle_MA2==INVALID_HANDLE ||
      _ind_handle_MA3==INVALID_HANDLE ||
      _ind_handle_ADXWilder==INVALID_HANDLE ||
      _ind_handle_ATR==INVALID_HANDLE)
     {
      //--- tell about the failure && output the error code
      PrintFormat("Failed to create HANDLE of the indicator for the symbol %s, error code %d",
                  Symbol(),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
//---
   _obj_panel_name_prefix=OBJ_SIGN_NAME_PREFIX+"panel";  _obj_panel_name_prefix_len=StringLen(_obj_panel_name_prefix);
   _obj_emoji_name_prefix=OBJ_SIGN_NAME_PREFIX+"emoji";  _obj_emoji_name_prefix_len=StringLen(_obj_emoji_name_prefix);
   _obj_text_name_prefix=OBJ_SIGN_NAME_PREFIX+"text";    _obj_text_name_prefix_len=StringLen(_obj_text_name_prefix);
        
//---
   EventSetMillisecondTimer(100);
   
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+  
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,OBJ_SIGN_NAME_PREFIX);
  }  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ExtBuf_K2,true);
   ArraySetAsSeries(ExtBuf_K2Clr,true);
   ArraySetAsSeries(ExtBuf_Up,true);
   ArraySetAsSeries(ExtBuf_Dn,true);
   ArraySetAsSeries(ExtBuf_MA1,true);
   ArraySetAsSeries(ExtBuf_MA2,true);
   ArraySetAsSeries(ExtBuf_MA3,true);
   ArraySetAsSeries(ExtBuf_pDI,true);
   ArraySetAsSeries(ExtBuf_mDI,true);
   ArraySetAsSeries(ExtBuf_ATR,true);
   ArraySetAsSeries(ExtBuf_RenkoStep,true);
   ArraySetAsSeries(ExtBuf_RenkoLevel,true);
   ArraySetAsSeries(ExtBuf_RenkoTrend,true);
   ArraySetAsSeries(ExtBuf_CondUp,true);
   ArraySetAsSeries(ExtBuf_CondDn,true);

//--- number of values copied from the iMA indicator
   int handles[5]={_ind_handle_MA1,_ind_handle_MA2,_ind_handle_MA3,_ind_handle_ADXWilder,_ind_handle_ATR}; 
   int values_to_copy;
   int calculated; 
//--- determine the number of values calculated in the indicator
   for(int i=0;i<5;i++)
     {
      calculated=BarsCalculated(handles[i]); 
      if(calculated<=0) 
        { 
         PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError()); 
         return(0); 
        }
        
      //--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed 
      //---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)         
      if(prev_calculated==0 || calculated!=_barsCalculatedArr[i] || rates_total>prev_calculated+1) 
        { 
         //--- if the array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything  
         //--- otherwise, we copy less than the size of indicator buffers 
         if(calculated>rates_total) values_to_copy=rates_total; 
         else                       values_to_copy=calculated; 
        } 
      else 
        { 
         //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
         //--- for calculation not more than one bar is added 
         values_to_copy=(rates_total-prev_calculated)+1; 
        }
      
      //--- fill the array with values of the indicator 
      //--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
      switch(i)
        {
         case  0:
           if(!FillArrayFromBuffer(ExtBuf_MA1,0,handles[i],values_to_copy)) return(0);     
           break;
         case  1:
           if(!FillArrayFromBuffer(ExtBuf_MA2,0,handles[i],values_to_copy)) return(0);     
           break;  
         case  2:
           if(!FillArrayFromBuffer(ExtBuf_MA3,0,handles[i],values_to_copy)) return(0);     
           break;
         case  3:
          {
           double buf_ADX[];
           if(!FillArraysFromBuffers(buf_ADX,ExtBuf_pDI,ExtBuf_mDI,handles[i],values_to_copy)) return(0); 
           break;    
          }
         case 4:
           if(!FillArrayFromBuffer(ExtBuf_ATR,0,handles[i],values_to_copy)) return(0);     
           break;  
         default:
           break;
        }
      //--- memorize the number of values in indicator 
      _barsCalculatedArr[i]=calculated;   
     }
     
//---
   int limit;   
//---
   if(prev_calculated==0)
     {
      limit=rates_total-MathMax(10*InpStrength,14)-1;
      
      ArrayInitialize(ExtBuf_RenkoStep,EMPTY_VALUE);
      ArrayInitialize(ExtBuf_RenkoLevel,EMPTY_VALUE);
      ArrayInitialize(ExtBuf_RenkoTrend,EMPTY_VALUE);
     }
   else
      limit=rates_total-prev_calculated-1;
         
   int length=20;
   int len2=10;
   
   for(int i=limit;i>=0;i--)
     {
      //--- K2 calculation
      double lastHighest=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,length,i+1));
      double lastLowest=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,length,i+1));
      double highest=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,len2,i));
      double lowest=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,len2,i));
      
      ExtBuf_CondUp[i]=high[i]>=lastHighest;
      ExtBuf_CondDn[i]=low[i]<=lastLowest;
      
      int barsSinceUp=barssince_Pine_4series(rates_total,i,ExtBuf_CondUp);
      int barsSinceDn=barssince_Pine_4series(rates_total,i,ExtBuf_CondDn);
      if(barsSinceUp==-1 || barsSinceDn==-1)
         continue;
      
      if(barsSinceUp<=barsSinceDn)
         ExtBuf_K2[i]=lowest;
      else
         ExtBuf_K2[i]=highest;
      
      ExtBuf_K2Clr[i]=close[i]>ExtBuf_K2[i+1] ? 0 : (close[i]<ExtBuf_K2[i+1] ? 1 : 2);
      
      //--- Up&Dn Sign      
      bool  up1=false,
            dn1=false,
            up2=false,
            dn2=false,
            up3=false,
            dn3=false;
         
      if(ExtBuf_MA1[i]>ExtBuf_MA2[i] && ExtBuf_MA2[i]>ExtBuf_MA3[i])          up1=true;
      else if(ExtBuf_MA1[i]<ExtBuf_MA2[i] && ExtBuf_MA2[i]<ExtBuf_MA3[i])     dn1=true;
         
      if(ExtBuf_pDI[i]-ExtBuf_mDI[i]>5+InpStrength)                           up2=true;
      else if(ExtBuf_mDI[i]-ExtBuf_pDI[i]>5+InpStrength)                      dn2=true;
      
      ExtBuf_RenkoStep[i]=ExtBuf_RenkoStep[i+1]==EMPTY_VALUE ? ExtBuf_ATR[i] : ExtBuf_RenkoStep[i+1];
      ExtBuf_RenkoLevel[i]=ExtBuf_RenkoLevel[i+1]==EMPTY_VALUE ? MathFloor(close[i]/ExtBuf_RenkoStep[i])*ExtBuf_RenkoStep[i] : ExtBuf_RenkoLevel[i+1];
      ExtBuf_RenkoTrend[i]=TREND_NA;
      if(ExtBuf_RenkoStep[i]<close[i]-ExtBuf_RenkoLevel[i])
        {
         ExtBuf_RenkoLevel[i]=ExtBuf_RenkoLevel[i]+ExtBuf_RenkoStep[i];
         ExtBuf_RenkoTrend[i]=TREND_UP;
        }
      if(close[i]-ExtBuf_RenkoLevel[i]<-ExtBuf_RenkoStep[i])
        {
         ExtBuf_RenkoLevel[i]=ExtBuf_RenkoLevel[i]-ExtBuf_RenkoStep[i];
         ExtBuf_RenkoTrend[i]=TREND_DN;
        }        
      up3=ExtBuf_RenkoTrend[i]==TREND_UP;
      dn3=ExtBuf_RenkoTrend[i]==TREND_DN;
      
      bool condUp=(_lastTrend==TREND_NA || _lastTrend==TREND_DN) && up1 && up2 && up3,
           condDn=(_lastTrend==TREND_NA || _lastTrend==TREND_UP) && dn1 && dn2 && dn3;
      
      if(condUp)  _lastTrend=TREND_UP;
      if(condDn)  _lastTrend=TREND_DN;
      
      ExtBuf_Up[i]=EMPTY_VALUE;
      ExtBuf_Dn[i]=EMPTY_VALUE;                     
      if(close[i]>ExtBuf_K2[i] && condUp)
         ExtBuf_Up[i]=low[i];
      else if(close[i]<ExtBuf_K2[i] && condDn)
         ExtBuf_Dn[i]=high[i];                  
     }
     
   //--- Alert
   if(InpAlert && _lastAlertTime!=time[0])
     {
      bool GHI=crossover_Pine_4series(close,ExtBuf_K2,0);
      bool JKL=crossunder_Pine_4series(close,ExtBuf_K2,0);
      bool cond_L=ExtBuf_Up[0]!=EMPTY_VALUE;
      bool cond_S=ExtBuf_Dn[0]!=EMPTY_VALUE;
      
      if(GHI || JKL)
        {
         Alert("現在価格がSTBラインを抜けました");
         _lastAlertTime=time[0];
        }
      
      if(cond_L || cond_S)
        {
         Alert("STBサインが出ました");
         _lastAlertTime=time[0];
         
         if(cond_L)
           {
            Alert("買いサインが出ました");
           }
         else if(cond_S)   
           {
            Alert("売りサインが出ました");
           }
        }  
     }
     
//--- return value of prev_calculated for next call
   return(rates_total-1);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   redrawSignLabels();
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   //if(id==CHARTEVENT_CHART_CHANGE)
      //redrawSignLabels();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the MA indicator                  | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values 
                         int shift,          // shift 
                         int ind_handle,     // handle of the iMA indicator 
                         int amount          // number of copied values 
                         ) 
  { 
//--- reset error code 
   ResetLastError(); 
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
//--- everything is fine 
   return(true); 
  } 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iADX indicator                | 
//+------------------------------------------------------------------+ 
bool FillArraysFromBuffers(double &adx_values[],      // indicator buffer of the ADX line 
                           double &DIplus_values[],   // indicator buffer for DI+ 
                           double &DIminus_values[],  // indicator buffer for DI- 
                           int ind_handle,            // handle of the iADX indicator 
                           int amount                 // number of copied values 
                           ) 
  { 
//--- reset error code 
   ResetLastError(); 
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,adx_values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
  
//--- fill a part of the DI_plusBuffer array with values from the indicator buffer that has index 1 
   if(CopyBuffer(ind_handle,1,0,amount,DIplus_values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
  
//--- fill a part of the DI_minusBuffer array with values from the indicator buffer that has index 2 
   if(CopyBuffer(ind_handle,2,0,amount,DIminus_values)<0) 
     { 
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError()); 
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false); 
     } 
//--- everything is fine 
   return(true); 
  } 
  
//+------------------------------------------------------------------+
//| PineScript Function                                              |
//| barssince                                                        |
//+------------------------------------------------------------------+
int barssince_Pine_4series(int bars,int pos,const double &condSeries[])
  {
   int   barsCount=-1;
   bool  seriesFlg=ArrayGetAsSeries(condSeries);

   for(int i=0;i<bars;i++)
     {
      if((bool)condSeries[pos+i])
        {
         barsCount=i+1;
         break;
        }
     }
     
   ArraySetAsSeries(condSeries,seriesFlg);
   return(barsCount);
  }

//+------------------------------------------------------------------+
//| PineScript Function                                                |
//| crossover                                                        |
//+------------------------------------------------------------------+
bool crossover_Pine_4series(const double &series1[],const double &series2[],const int pos)
  {
   bool seriesFlg1=ArrayGetAsSeries(series1);
   bool seriesFlg2=ArrayGetAsSeries(series2);
   
   bool crossed=series1[pos+1]<=series2[pos+1] && series1[pos]>series2[pos];
   
   ArraySetAsSeries(series1,seriesFlg1);
   ArraySetAsSeries(series2,seriesFlg2);
   
   return(crossed);
  }
  
//+------------------------------------------------------------------+
//| PineScript Function                                              |
//| crossunder                                                       |
//+------------------------------------------------------------------+
bool crossunder_Pine_4series(const double &series1[],const double &series2[],const int pos)
  {
   bool seriesFlg1=ArrayGetAsSeries(series1);
   bool seriesFlg2=ArrayGetAsSeries(series2);
   
   bool crossed=series1[pos+1]>=series2[pos+1] && series1[pos]<series2[pos];
   
   ArraySetAsSeries(series1,seriesFlg1);
   ArraySetAsSeries(series2,seriesFlg2);
   
   return(crossed);
  }  
  
//---
void redrawSignLabels()
  {
   bool upSeriesFlg=ArrayGetAsSeries(ExtBuf_Up);
   bool dnSeriesFlg=ArrayGetAsSeries(ExtBuf_Dn);
   
   int firstBarIndex=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);
   int chartBarsTotal=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   
   int chartSignsTotal=0;   
   for(int i=0;i<chartBarsTotal;i++)
     {
      int signUpDn=TREND_NA;
      
      if(firstBarIndex-i<0)
         continue;
         
      if(ExtBuf_Up[firstBarIndex-i]!=EMPTY_VALUE)
         signUpDn=TREND_UP;
      else if(ExtBuf_Dn[firstBarIndex-i]!=EMPTY_VALUE)   
         signUpDn=TREND_DN;
         
      if(signUpDn!=TREND_NA)
        {
         chartSignsTotal++;         
         
         //---
         datetime time=iTime(NULL,0,firstBarIndex-i);
         double price=signUpDn==TREND_UP ? iLow(NULL,0,firstBarIndex-i) : iHigh(NULL,0,firstBarIndex-i);
         int x, y;
         ChartTimePriceToXY(0,0,time,price,x,y);
         
         drawSign(chartSignsTotal,signUpDn,x,y);
        }
     }
   
   for(int i=0;i<ObjectsTotal(0);i++)
     {
      string objName=ObjectName(0,i);
      
      if(StringFind(objName,_obj_panel_name_prefix)==0)
        {
         string indexStr=StringSubstr(objName,_obj_panel_name_prefix_len);
         if(StringToInteger(indexStr)>chartSignsTotal)
           {
            ObjectSetInteger(0,objName,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
            continue;
           }
        }
      if(StringFind(objName,_obj_emoji_name_prefix)==0)
        {
         string indexStr=StringSubstr(objName,_obj_emoji_name_prefix_len);
         if(StringToInteger(indexStr)>chartSignsTotal)
           { 
            ObjectSetInteger(0,objName,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
            continue;
           }
        }
      if(StringFind(objName,_obj_text_name_prefix)==0)
        {
         string indexStr=StringSubstr(objName,_obj_text_name_prefix_len);
         if(StringToInteger(indexStr)>chartSignsTotal)
           {
            ObjectSetInteger(0,objName,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
            continue;
           }
        }    
     }
   
   ArraySetAsSeries(ExtBuf_Up,upSeriesFlg);  
   ArraySetAsSeries(ExtBuf_Dn,dnSeriesFlg);
   
   //---
   ChartRedraw();    
  }  
  
void drawSign(int index,int trendUpDn,int x,int y)
  {
   string panelName=OBJ_SIGN_NAME_PREFIX+"panel"+IntegerToString(index);
   string emojiName=OBJ_SIGN_NAME_PREFIX+"emoji"+IntegerToString(index);
   string textName=OBJ_SIGN_NAME_PREFIX+"text"+IntegerToString(index);
   
   //---
   if(trendUpDn==TREND_NA)
     {
      ObjectSetInteger(0,panelName,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
      ObjectSetInteger(0,emojiName,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
      ObjectSetInteger(0,textName,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
      return;
     }
     
   //---
   if(ObjectFind(0,panelName)<0)
     {
      ObjectCreate(0,panelName,OBJ_RECTANGLE_LABEL,0,0,0);
     }
   if(ObjectFind(0,emojiName)<0)
     {
      ObjectCreate(0,emojiName,OBJ_LABEL,0,0,0);
     }
   if(ObjectFind(0,textName)<0)
     {
      ObjectCreate(0,textName,OBJ_LABEL,0,0,0);
     }
   
   int updnK=trendUpDn==TREND_UP ? 1 : -1;
   int panelOffset_Y=trendUpDn==TREND_UP ? 0 : 35;
   int emojOffset_Y=trendUpDn==TREND_UP ? 0 : 25;
   int textOffset_X=trendUpDn==TREND_UP ? 0 : 1;
   int textOffset_Y=trendUpDn==TREND_UP ? 0 : 17;
   
   color bgColorUp=(color)PlotIndexGetInteger(0,PLOT_LINE_COLOR,0);
   color bgColorDn=(color)PlotIndexGetInteger(0,PLOT_LINE_COLOR,1);
         
   ObjectSetInteger(0,panelName,OBJPROP_XDISTANCE,x-10);
   ObjectSetInteger(0,panelName,OBJPROP_YDISTANCE,y+updnK*15-panelOffset_Y);
   ObjectSetInteger(0,panelName,OBJPROP_XSIZE,20);
   ObjectSetInteger(0,panelName,OBJPROP_YSIZE,35);
   ObjectSetInteger(0,panelName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,panelName,OBJPROP_BGCOLOR,trendUpDn==TREND_UP ? bgColorUp : bgColorDn);
   ObjectSetInteger(0,panelName,OBJPROP_BACK,true);
   ObjectSetInteger(0,panelName,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
        
   ObjectSetInteger(0,emojiName,OBJPROP_XDISTANCE,x-6);
   ObjectSetInteger(0,emojiName,OBJPROP_YDISTANCE,y+updnK*11-emojOffset_Y);   
   ObjectSetInteger(0,emojiName,OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,emojiName,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetString(0,emojiName,OBJPROP_TEXT,"👽");
   
   ObjectSetInteger(0,textName,OBJPROP_XDISTANCE,x-4-textOffset_X);
   ObjectSetInteger(0,textName,OBJPROP_YDISTANCE,y+updnK*30-textOffset_Y);   
   ObjectSetInteger(0,textName,OBJPROP_COLOR,trendUpDn==TREND_UP ? InpLabelColor_L : InpLabelColor_S);
   ObjectSetInteger(0,textName,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetString(0,textName,OBJPROP_TEXT,trendUpDn==TREND_UP ? "L" : "S");
  }  