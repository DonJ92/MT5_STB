//+------------------------------------------------------------------+
//|                                            SAT's TREND BREAK.mq5 |
//|                                             Copyright 2020, SEL. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, SEL."
#property version   "1.00"
#property indicator_chart_window

//#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots 3

#property indicator_type1 DRAW_COLOR_LINE
#property indicator_width1 2
#property indicator_color1 C'28, 213, 255', C'224, 237, 38' , clrGray
#property indicator_label1 "TP/SL目安ライン"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 2
#property indicator_color2 C'28, 213, 255'
#property indicator_label2 "Buy"

#property indicator_type3 DRAW_ARROW
#property indicator_width3 2
#property indicator_color3 C'224, 237, 38' 
#property indicator_label3 "Sell"


input int Inpstrength = 2; // フィルター強度(1ずつ変更してください)
input bool InpAlert = false; // Enable Alert

ENUM_APPLIED_PRICE Inpsrc = PRICE_CLOSE;
bool showUpTrend = true;
bool showDownTrend = true;

double ExpEMA1[];
double ExpEMA2[];
double ExpEMA3[];
double ExpSrc[];

// ---DMI---
double ExpplusDM[];
double ExpminusDM[];
double Exptrur[];
double ExpTr[];
double ExpRmaPlus[];
double ExpRmaMinus[];
double ExpPlustmp[];
double ExpMinustmp[];
double ExpRmaADX[];
double ExpSrcADX[];
double ExpADX[];
double ExpPlus[];
double ExpMinus[];
// ---DMI---

double ExpTrueRange[];
double ExpRma[];
double ExpClose[];

double ExprenkoStep[];
double ExprenkoLevel[];
string lastTrend = "";
double Expupp[];
double Expdownn[];
bool ExpbarsSinceCond1[];
bool ExpbarsSinceCond2[];


double ExpK2[];
double ExpK2Clr[];
double Explong[];
double Expshort[];

bool m_newbar = false;
datetime m_OldTime;
double renkoStep = EMPTY_VALUE;
double renkoLevel = EMPTY_VALUE;

// 許可口座一覧
bool accountControlEnable = true;
int accountList[] = {
79793,
26778375,
   9108484,
   70000876,
   70001166,
   70005950,
   70103222,
   70073745,
   70001644,
   70000930,
   70000976,
   70000854,
   70001052,
   70085204,
   70103534,
   70011430,
   70032653,
   70022887,
   70022848,
   70031562,
   70011723,
   70103187,
   70073741,
   70103718,
   70103917,
   70103918,
   70103898,
   70103919,
   70103913,
   70103939,
   70103936,
   70103741,
   70104028,
   70104010,
   70104339,
   70000839,
   70104619,
   943000719,
   70104944,
   70105185,
   59046627,
   70106957,
   70031562,
   70009088,
   70011360,
   70110307,
   70111837,
   70011569,
   70111837,
   48206,
   70121911,
   70115784,
   70128682,
70128714,
70128676,
70128730,
70128722,
70128647,
70128674,
70128644,
70103918,
70128660,
70128699,
70128684,
70128697,
70128707,
70128634,
70128806,
70005950,
70128687,
70128649,
70128696,
70128738,
70128643,
70128646,
70128784,
70128880,
70128646,
70128675,
70128891,
70128928,
70128837,
70128809,
70128942,
70128673,
70128838,
70128665,
70129020,
70128909,
70128812,
70128976,
70128986,
70128709,
70129032,
70128712,
70128758,
70129052,
70128992,
70128635,
70128752,
70128648,
70128958,
70104028,
70128636,
70129154,
70128669,
70128785,
70129037,
70128821,
70128741,
70128694,
70128814,
70128962,
70128642,
70129036,
70129186,
70128890,
70129282,
70128686,
70128721,
70128962,
70128698,
70128742,
70129406,
70129386,
70129475,
70128984,
70032653,
70128866,
70129409,
70128903,
70128863,
70129770,
70129564,
70128683,
70128657,
70129108,
70128774,
70129753,
70129831,
70129077,
70128999,
70129884,
70129187,
70129996,
70129488,
70130056,
70129187,
70129062,
70128641, 
70130179,
70128840,
70128652,
70130371,
70128777,
70130191,
70130153,
70130457,
70129870,
70129116,
70128677,
70130567,
70129988,
70130331,
70130416,
70129118,
70130849,
70130957,
70128906,
70128749,
70128848,
70130986,
70131188,
70131169,
70130818,
70130567,
70131334,
70128816,
70130773,
70130412,
70130437, 
70131466,
70104619,
70131213,
70131111, 
70128841,
70131562,
70130975,
70128829,
70131062,
70129217,
70131661,
70131169,
70128816,
70130818,
70131213,
70131466,
70129217,
70104619,
70130567,
70130975,
70131562,
70131334,
70128841,
70130437,
70129049,
70128829,
70130412, 
70128708,
70131318,
70131043,
70130325,
70130168,
70131563,
70130583,
70131041,
70129034,
70128764,
70129096, 
70128790,
70130825,
70130182,
70129341,
70132344,
70132147,
70129042,
70132525,
70132989,
70132048,
70133151,
70128726,
70132950,
70128869,
70132987,
70131111,
70133952,
70133663,
70128917,
70133913,
70130198,
70133952,
70133520,
70133931, 
70134434,
70134343,
70131738,
70134929,  
70128767,
70132339,
70134814,
70135761,
70135437,
70136363,
70134385,
70134875,
70136574,
70131562,
70011430,
70131308,
70131188,
70129488,
70136796,
70136879,
70133998,
70135993,
70135991,
70128660,
70133998,
70134131,
70128992,
70130056,
70129131,
70128657,
70136879,
70135350,
70129032,
70137539,
70137204,
70137626,
70130371,
70137333,
70137307,
70128890,
70130412,
70103741,
70136522,
70137715, 
70137769,
70129488,
70134343,
70137431,
70137300,
70128785,
70128722,
70137486,
70129565,
70137924,
70128777,
70129156,
70131269,
70138253,
70138149,
70138366,
70138336,
70138501,
70138274,
70129251,
70022887,
70130849,
70138404,
70129688,
70129895,
70121911,
70131268,
70139120,
70128766,
70128648,
70128714,
70137688,
70130168,
70133939,
70139559,
70139868,
70139798,
603068,
70129341,
70139930,
70139022,
70139948,
70140277,
70129221,
70140367,
70129067,
70140311,
70137204,
70138130,
70140936,
70141017,
70140906,
70141108,
70139913,
70140580,
70128913,
70141195,
70141360,
70131129,
70129205,
70142327,
70129089,
70140051,
70142704,
70141659,
70142462,
70128669,
70140982,
70141901,
70140441,
70143881,
70143143,
70131306,
70143830,
70140580,
70143412,
70131305,
70144354,
70144432,
70144173,
70144510,
70128740,
70143147,
70132888,
70144085,
70144934,
70128973,
70139744,
70143830,
70145978,
70140297,	
70129394,	
70145714,
70129131,
70141858,
70128696,
70146063,
70144141,
70146290,
70146800,
70130416,
70147904,
70147949,
70145588,
70145718,
70148344,
70148018,
70148890,
70149014,
70146331,
70149313,
70128648,
70147154,
70149347,
70149655,
70133520,
70149811,
70149051,
70150289,
70147265,
70150443,
70150484,
70130567,
70150779,
70150802,
70149266,
70151047,
70150280,
70134589,
70119658,
70131797,
70144364,
70130567,
70145588,
70152085,
70152360,
70151839,
70128914,
70149693,
70129032,
70153077,
70128752,
70153568,
70128647,
70150341,
70128746,
70154541,
70154712,
70154010,
70132147,
70154519,
70154998,
70154882,
70155271,
70155684,
70155661,
70155842,
70150931,
70131523,
70155761,
70155792,
70150848,
70155809,
70156065,
70155867,
70155708,
70156109,
70156253,
70156396,
70153024,
70156529,
70156651,
70128647,
70130431,
70153850,
70155539,
70138336,
70156706,
70157266,
70155867,
70157701,
70157545,
70157568,
70158186,
70157239,
70158514,
70158601,
70158928,
70159027,
70129345,
70158655,
70160698,
70128716,
70158655,
70151014,
70161092,
70128714,
70157600,
70162008,
70160870,
70163029,
70163303,
70133757,
70163525,
70163580,
70163672,
70161961,
70164291,
70163066,
70164667,
70166061,
70165840,
70166362,
70166340,
70166966,
70166837,
70166792,
70136230,
70166458,
70166484,
70167698,
70167796,
70167978,
70156045,
70169004,
70168924,
70170154,
70170612,
70161961,
70171182,
70169147,
70171808,
70167852,
70171889,
70136177,
70154686,
70172773,
70170852,
70155290,
70141858,
70173740,
70174477,
70174290,
70174739,
70175064,
70155572,
70157302,
70175662,
70175128,
70176020,
70176346,
70176425,
70176447,
70177044,
70175282,
70176754,
70166484,
70177356,
70146291,
70175282,
70176539,
70178277,
70178363,
70178482,
70140136,
70178562,
70177847,
70156310,
70146290,
70129475,
5608940,
194782,
9112296,
70178737,
70180668,
70180668,
70180748,
70181222,
70177702,
70178978,
70180880,
70184115,
70183950,
70180582,
70185158,
70185128,
70148676,
70186016,
70185985,
70154890,
70186366,
70184319,
};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NewArray(int totals)
  {
   ResizeBuffer(ExpEMA1, totals);
   ResizeBuffer(ExpEMA2, totals);
   ResizeBuffer(ExpEMA3, totals);
   ResizeBuffer(ExpSrc, totals);

   ResizeBuffer(ExpplusDM, totals);
   ResizeBuffer(ExpminusDM, totals);
   ResizeBuffer(Exptrur, totals);
   ResizeBuffer(ExpTr, totals);
   ResizeBuffer(ExpRmaPlus, totals);
   ResizeBuffer(ExpRmaMinus, totals);
   ResizeBuffer(ExpPlustmp, totals);
   ResizeBuffer(ExpMinustmp, totals);
   ResizeBuffer(ExpRmaADX, totals);
   ResizeBuffer(ExpSrcADX, totals);
   ResizeBuffer(ExpADX, totals);
   ResizeBuffer(ExpPlus, totals);
   ResizeBuffer(ExpMinus, totals);

   ResizeBuffer(ExpTrueRange, totals);
   ResizeBuffer(ExpRma, totals);
   ResizeBuffer(ExpClose, totals);
   ResizeBuffer(ExprenkoStep, totals);
   ResizeBuffer(ExprenkoLevel, totals);
   ResizeBuffer(Expupp, totals);
   ResizeBuffer(Expdownn, totals);
   ResizeBuffer(ExpbarsSinceCond1, totals);
   ResizeBuffer(ExpbarsSinceCond2, totals);

   
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
  
     // 許可している口座か
  if(!chkTradeAccount())
  {
    printf("Error Account Error");
    return(INIT_FAILED);
   }
//--- indicator buffers mapping
   SetIndexBuffer(0,ExpK2,INDICATOR_DATA);
   SetIndexBuffer(1,ExpK2Clr,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,Explong,INDICATOR_DATA);
   SetIndexBuffer(3,Expshort,INDICATOR_DATA);

   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   PlotIndexSetInteger(2, PLOT_ARROW, 234);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT,20);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT,-20);
   
   ArrayInitialize(ExpK2, EMPTY_VALUE);
   ArrayInitialize(ExpK2Clr, EMPTY_VALUE);
   ArrayInitialize(Explong, EMPTY_VALUE);
   ArrayInitialize(Expshort, EMPTY_VALUE);

   ArraySetAsSeries(ExpK2, true);
   ArraySetAsSeries(ExpK2Clr, true);
   ArraySetAsSeries(Explong, true);
   ArraySetAsSeries(Expshort, true);

   IndicatorSetString(INDICATOR_SHORTNAME, "STB");
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ProcDMI(int i, int diLen, int adxLen)
  {
   double up = iHigh(_Symbol, _Period, i) - iHigh(_Symbol, _Period, i+1);
   double down = -(iLow(_Symbol, _Period, i) - iLow(_Symbol, _Period, i+1));

   ExpplusDM[i] = up > down && up > 0 ? up : 0;
   ExpminusDM[i] = down > up && down > 0 ? down : 0;
   ExpTr[i] = TrueRange(_Symbol, _Period, i, false);
   if(ExpTr[i] == EMPTY_VALUE || ExpTr[i] == 0.0)
      return;
   Exptrur[i] = RelatedMA(i, diLen, Exptrur[i+1], ExpTr);

   ExpRmaPlus[i] = RelatedMA(i, diLen, ExpRmaPlus[i+1], ExpplusDM);
   ExpRmaMinus[i] = RelatedMA(i, diLen, ExpRmaMinus[i+1], ExpminusDM);

   ExpPlustmp[i] = 100* ExpRmaPlus[i]/Exptrur[i];
   ExpMinustmp[i] = 100* ExpRmaMinus[i]/Exptrur[i];

   ExpPlus[i] = FixNan(i, ExpPlustmp);
   ExpMinus[i] = FixNan(i, ExpMinustmp);

   double sum = ExpPlus[i] + ExpMinus[i];

   ExpSrcADX[i] = MathAbs(ExpPlus[i] - ExpMinus[i]) / (sum == 0 ? 1 : sum);

   ExpRmaADX[i] = RelatedMA(i, adxLen, ExpRmaADX[i+1], ExpSrcADX);
   ExpADX[i] = 100 * ExpRmaADX[i];
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
   IsNewBar();
   int limit=rates_total-prev_calculated-1;

   if(limit >= 0)
      NewArray(rates_total);
   else
      limit = 0;

   int maxLen = (int)MathMax(14, 10 * Inpstrength);

   
   if(prev_calculated == 0)
     {
      for(int i = 0; i < rates_total; i++)
        {
         ExpK2[i]   =EMPTY_VALUE;
         ExpK2Clr[i]   =EMPTY_VALUE;
         Explong[i]   =EMPTY_VALUE;
         Expshort[i]   =EMPTY_VALUE;
        }
     }

   for(int i = limit; i >=0; i--)
     {
      if(i > rates_total -  2)
         continue;

      Process(i);
     }

   ChartRedraw();
//--- return value of prev_calculated for next call
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Process(int i)
  {
   ExpSrc[i] = GetPrice(i, Inpsrc);
   

   ExpEMA1[i] = ExponentMA(i, 2 * Inpstrength, ExpEMA1[i+1], ExpSrc);
   ExpEMA2[i] = ExponentMA(i, 5 * Inpstrength, ExpEMA2[i+1], ExpSrc);
   ExpEMA3[i] = ExponentMA(i, 10 * Inpstrength, ExpEMA3[i+1], ExpSrc);

   ProcDMI(i, 14, 1);
   /*
   if(renkoStep == EMPTY_VALUE)
     {
      renkoStep = GetATR(_Symbol, _Period, i, 14);
      if (renkoStep  == 0) 
      {
         renkoStep = EMPTY_VALUE;
         return;
      }
      ExprenkoStep[i] = renkoStep;
     }
   else
      ExprenkoStep[i] = ExprenkoStep[i+1];
   
  
   if(ExprenkoStep[i] == 0)
      return;

   if(renkoLevel == EMPTY_VALUE)
     {
      renkoLevel = floor(ExpSrc[i] / ExprenkoStep[i]) * ExprenkoStep[i];
      if (renkoLevel  == 0) 
      {
         renkoLevel = EMPTY_VALUE;
         return;
      }
      ExprenkoLevel[i] = renkoLevel;
     }
   else
      ExprenkoLevel[i] = ExprenkoLevel[i+1];
   
   
   string renkoTrend = "";
   if(ExprenkoStep[i] < (ExpSrc[i] - ExprenkoLevel[i]))
     {
      ExprenkoLevel[i] = ExprenkoLevel[i] + ExprenkoStep[i];
      renkoTrend = "u";
     }

   if((ExpSrc[i] - ExprenkoLevel[i]) < -ExprenkoStep[i])
     {
      ExprenkoLevel[i] = ExprenkoLevel[i] - ExprenkoStep[i];
      renkoTrend = "d";
     }
   */
   bool up1 = ExpEMA1[i] > ExpEMA2[i] && ExpEMA2[i] > ExpEMA3[i];
   bool down1 = ExpEMA1[i] < ExpEMA2[i] && ExpEMA2[i] < ExpEMA3[i];
   bool up2 = (ExpPlus[i] - ExpMinus[i]) > (5 + Inpstrength);
   bool down2 = (ExpMinus[i] - ExpPlus[i]) > (5 + Inpstrength);
   bool up3 = true; //renkoTrend == "u";
   bool down3 = true; //renkoTrend == "d";


   bool up = (lastTrend == "" || lastTrend == "down") && up1 && up2 && up3;
   bool down = (lastTrend == "" || lastTrend == "up") && down1 && down2 && down3;

   if(up)
      lastTrend = "up";
   if(down)
      lastTrend = "down";


   int length = 20;
   int len2 = 10;
   double lower = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, length, i));
   double upper = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, length, i));
   Expupp[i]=iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, length, i));
   Expdownn[i]=iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, length, i));
   double sup=iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, len2, i));
   double sdown=iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, len2, i));

   ExpbarsSinceCond1[i] = iHigh(_Symbol, _Period, i) >= Expupp[i+1];
   ExpbarsSinceCond2[i] = iLow(_Symbol, _Period, i) <= Expdownn[i+1];

   int barsince1 = barssince(i, ExpbarsSinceCond1);
   int barsince2 = barssince(i, ExpbarsSinceCond2);
   if(barsince1 == -1 || barsince2 == -1)
      return;

   ExpK2[i]= barsince1 <= barsince2 ? sdown : sup;
   ExpClose[i]=iClose(_Symbol,_Period,i);

   bool GHI = crossover(ExpClose,ExpK2,i);
   bool JKL = crossunder(ExpClose,ExpK2,i);

   if(ExpSrc[i] > ExpK2[i+1])
     {
      // clrLime
      ExpK2Clr[i] = 0;
     }
   else
      if(ExpSrc[i] < ExpK2[i+1])
        {
         // clrPink
         ExpK2Clr[i] = 1;
        }
      else
        {
         // clrGray
         ExpK2Clr[i] = 2;
        }

   bool longs = ExpK2[i] < ExpClose[i];
   bool shorts = ExpK2[i] > ExpClose[i];
   bool longflag = longs && showUpTrend ? up : false;
   bool shortflag = shorts && showDownTrend ? down : false;


   if(longflag)
      Explong[i]= iLow(_Symbol, _Period, i);

   if(shortflag)
      Expshort[i]= iHigh(_Symbol, _Period, i);


   if(InpAlert)
     {
      if(i == 0 && m_newbar == false)
        {
         if(GHI || JKL)
           {
            Alert("現在価格がTP/SLラインを抜けました");
            m_newbar = true;
           }

         //if(longflag || shortflag)
          // {
           // Alert("STBサインが出ました");
           // m_newbar = true;
         //  }

         if(longflag)
           {
            Alert("買いサインが出ました");
            m_newbar = true;
           }

         if(shortflag)
           {
            Alert("売りサインが出ました");
            m_newbar = true;
           }
        }
     }

  }
bool chkTradeAccount()
{
   if(!accountControlEnable)
   {
      return true;
   }

   int account_no = AccountInfoInteger(ACCOUNT_LOGIN);

   int Size=ArraySize(accountList);
   for(int i=0;i<Size;i++){
      if(accountList[i]==account_no)
         return true;
   }

   return false;
}





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ExponentMA(const int position, const int period, const double prev_value, const double &price[])
  {
   double result = 0.0;
   if(period > 0)
     {
      double alpha = 2.0/(period + 1);
      result = price[position]*alpha + (1-alpha)*prev_value;
     }
   return(result);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ResizeBuffer(double& buffer[], int size)
  {
   if(ArrayRange(buffer,0) != size)            // ArrayRange allows 1D or 2D arrays
     {
      ArraySetAsSeries(buffer, false);    // Shift values B[2]=B[1]; B[1]=B[0]
      if(ArrayResize(buffer, size) <= 0)
        {
         return(false);
        }
      ArraySetAsSeries(buffer, true);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPrice(int i, ENUM_APPLIED_PRICE src)
  {
//----
   double res;
//----
   switch(src)
     {
      case PRICE_OPEN:
         res=iOpen(_Symbol, _Period, i);
         break;
      case PRICE_HIGH:
         res=iHigh(_Symbol, _Period, i);
         break;
      case PRICE_LOW:
         res=iLow(_Symbol, _Period, i);
         break;
      case PRICE_MEDIAN:
         res=(iHigh(_Symbol, _Period, i)+iLow(_Symbol, _Period, i))/2.0;
         break;
      case PRICE_TYPICAL:
         res=(iHigh(_Symbol, _Period, i)+iLow(_Symbol, _Period, i)+iClose(_Symbol, _Period, i))/3.0;
         break;
      case PRICE_WEIGHTED:
         res=(iHigh(_Symbol, _Period, i)+iLow(_Symbol, _Period, i)+2*iClose(_Symbol, _Period, i))/4.0;
         break;
      case PRICE_CLOSE:
      default:
         res=iClose(_Symbol, _Period, i);
         break;
     }

   return(res);

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RelatedMA(const int position, const int period, const double prev_value, const double &price[])
  {
   double result = 0.0;
   if(period > 0)
     {
      double alpha = 1.0/period;
      result = price[position]*alpha + (1-alpha)*prev_value;
     }
   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool crossover(const double &xPrice[], const double &yPrice[], const int index)
  {

   bool bCross = xPrice[index+1] < yPrice[index+1] && xPrice[index] > yPrice[index];
   return(bCross);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool crossunder(const double &xPrice[], const double &yPrice[], const int index)
  {
   bool bCross = xPrice[index+1] > yPrice[index+1] && xPrice[index] < yPrice[index];
   return(bCross);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FixNan(const int position, const double &price[])
  {
   for(int i=position; i<ArraySize(price); i++)
     {
      if(price[i]!=EMPTY_VALUE)
        {
         return price[i];
        }
     }
   return EMPTY_VALUE;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TrueRange(string symbol, ENUM_TIMEFRAMES timeframe, const int i, bool bhandle_na)
  {
   if(i == iBars(symbol, timeframe)-1)
     {
      if(bhandle_na == true)
        {
         double tr = iHigh(symbol, timeframe, i) - iLow(symbol, timeframe, i);
         return(tr);
        }

      else
         return EMPTY_VALUE;
     }

   double a = iHigh(symbol, timeframe, i) - iLow(symbol, timeframe,i);
   double b = MathAbs(iHigh(symbol, timeframe,i) - iClose(symbol, timeframe, i+1));
   double c = MathAbs(iLow(symbol, timeframe, i) - iClose(symbol, timeframe, i+1));

   double max = MathMax(a, b);
   max = MathMax(max, c);

   return(max);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetATR(string symbol, ENUM_TIMEFRAMES tf, int i, int leng)
  {
   ExpTrueRange[i] = TrueRange(symbol, tf, i, true);
   ExpRma[i] = RelatedMA(i, leng, ExpRma[i+1], ExpTrueRange);
   double atr = ExpRma[i];
   return atr;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int barssince(int position,const bool &condition[])
  {
   int _Bars=Bars(_Symbol,_Period)-position;

   for(int i=0; i<_Bars; i++)
     {
      if(condition[position+i])
         return i;
     }
   return -1;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   if(m_OldTime!=iTime(Symbol(),Period(),0))
     {
      m_OldTime=iTime(Symbol(),Period(),0);
      m_newbar = false;
      return(true);
     }
   return(false);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ResizeBuffer(bool & buffer[], int size)
  {
   if(ArrayRange(buffer,0) != size)            // ArrayRange allows 1D or 2D arrays
     {
      ArraySetAsSeries(buffer, false);    // Shift values B[2]=B[1]; B[1]=B[0]
      if(ArrayResize(buffer, size) <= 0)
        {
         return(false);
        }
      ArraySetAsSeries(buffer, true);
     }
   return(true);
  }
//+------------------------------------------------------------------+
