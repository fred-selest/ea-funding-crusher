//+------------------------------------------------------------------+
//|                                         DJ30_FundingCrusher.mq5 |
//|                                       EA Funding Crusher MT5     |
//|                   Stratégie US Market Opening pour DJ30/US30     |
//+------------------------------------------------------------------+
#property copyright "EA Funding Crusher"
#property link      "https://github.com/fred-selest/ea-funding-crusher"
#property version   "1.00"
#property description "EA optimisé pour passer les challenges des propfirms (FTMO, etc.)"
#property description "Stratégie: Breakout à l'ouverture du marché US sur DJ30/US30"

#include <FundingCrusher/RiskManager.mqh>
#include <FundingCrusher/TimeFilter.mqh>
#include <FundingCrusher/TradeManager.mqh>

//+------------------------------------------------------------------+
//| Paramètres d'entrée                                             |
//+------------------------------------------------------------------+

//--- Paramètres de risque (Propfirm)
input group "═══════ Gestion du Risque ═══════"
input double   RiskPerTrade = 1.0;           // Risque par trade (% du compte)
input double   MaxDailyLoss = 5.0;           // Perte journalière max (%)
input double   MaxTotalLoss = 10.0;          // Perte totale max (%)
input int      MaxPositions = 1;             // Nombre max de positions simultanées
input int      MaxTradesPerDay = 3;          // Nombre max de trades par jour

//--- Paramètres de temps
input group "═══════ Filtre Temporel ═══════"
input int      StartHour = 13;               // Heure de début (UTC) - 13h30 = 9h30 EST été
input int      StartMinute = 30;             // Minute de début
input int      EndHour = 18;                 // Heure de fin (UTC)
input int      EndMinute = 0;                // Minute de fin
input bool     AutoAdjustDST = true;         // Ajustement auto heure d'été/hiver

//--- Paramètres de stratégie
input group "═══════ Stratégie de Trading ═══════"
input int      BreakoutPeriod = 5;           // Période pour détecter le breakout (minutes)
input double   MinBreakoutPoints = 50;       // Points minimum pour valider un breakout
input double   ATRMultiplierSL = 2.0;        // Multiplicateur ATR pour Stop Loss
input double   ATRMultiplierTP = 3.0;        // Multiplicateur ATR pour Take Profit
input int      ATRPeriod = 14;               // Période ATR
input bool     UseVolume = true;             // Utiliser le volume comme confirmation

//--- Paramètres de gestion des positions
input group "═══════ Gestion des Positions ═══════"
input double   BreakEvenPoints = 50;         // Points pour activer break-even
input double   BreakEvenProfit = 10;         // Profit à laisser au break-even
input double   TrailingStart = 100;          // Points pour activer trailing stop
input double   TrailingStep = 20;            // Pas du trailing stop
input bool     CloseAtEndOfSession = true;   // Fermer positions en fin de session

//--- Paramètres généraux
input group "═══════ Paramètres Généraux ═══════"
input ulong    MagicNumber = 202411;         // Magic number unique
input string   TradeComment = "DJ30_Crusher";// Commentaire des trades

//+------------------------------------------------------------------+
//| Variables globales                                               |
//+------------------------------------------------------------------+
RiskManager*   g_riskManager = NULL;
TimeFilter*    g_timeFilter = NULL;
TradeManager*  g_tradeManager = NULL;

int            g_atrHandle = INVALID_HANDLE;
double         g_atrBuffer[];

datetime       g_lastBarTime = 0;
int            g_tradesOpenedToday = 0;
datetime       g_lastTradeDay = 0;

double         g_sessionHigh = 0;
double         g_sessionLow = 0;
bool           g_sessionInitialized = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("═══════════════════════════════════════════════════════════");
   Print("         DJ30 FUNDING CRUSHER - Initialisation");
   Print("═══════════════════════════════════════════════════════════");

   // Vérifier le symbole
   string symbol = _Symbol;
   if(StringFind(symbol, "US30") == -1 && StringFind(symbol, "DJ30") == -1 &&
      StringFind(symbol, "DOW") == -1)
   {
      Print("⚠️  ATTENTION: Cet EA est optimisé pour le DJ30/US30");
      Print("    Symbole actuel: ", symbol);
   }

   // Initialiser les gestionnaires
   g_riskManager = new RiskManager(RiskPerTrade, MaxDailyLoss, MaxTotalLoss);
   g_timeFilter = new TimeFilter(StartHour, StartMinute, EndHour, EndMinute);
   g_tradeManager = new TradeManager(symbol, MagicNumber);

   // Configuration du break-even et trailing stop
   g_tradeManager.SetBreakEven(BreakEvenPoints, BreakEvenProfit);
   g_tradeManager.SetTrailingStop(TrailingStart, TrailingStep);

   // Ajustement automatique DST
   if(AutoAdjustDST)
      g_timeFilter.AdjustForDST();

   // Créer l'indicateur ATR
   g_atrHandle = iATR(symbol, PERIOD_M5, ATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
   {
      Print("❌ Erreur: Impossible de créer l'indicateur ATR");
      return INIT_FAILED;
   }

   ArraySetAsSeries(g_atrBuffer, true);

   // Afficher les paramètres
   PrintConfiguration();

   Print("✅ Initialisation réussie!");
   Print("═══════════════════════════════════════════════════════════");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("═══════════════════════════════════════════════════════════");
   Print("         DJ30 FUNDING CRUSHER - Arrêt");
   Print("         Raison: ", GetUninitReasonText(reason));
   Print("═══════════════════════════════════════════════════════════");

   // Libérer les ressources
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);

   delete g_riskManager;
   delete g_timeFilter;
   delete g_tradeManager;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Vérifier si on a une nouvelle bougie
   datetime currentBarTime = iTime(_Symbol, PERIOD_M5, 0);
   bool isNewBar = (currentBarTime != g_lastBarTime);

   if(isNewBar)
   {
      g_lastBarTime = currentBarTime;

      // Réinitialiser le compteur de trades quotidiens
      MqlDateTime currentTime;
      TimeToStruct(TimeCurrent(), currentTime);
      datetime currentDay = StringToTime(IntegerToString(currentTime.year) + "." +
                                          IntegerToString(currentTime.mon) + "." +
                                          IntegerToString(currentTime.day));

      if(currentDay != g_lastTradeDay)
      {
         g_tradesOpenedToday = 0;
         g_lastTradeDay = currentDay;
         g_sessionInitialized = false;
         Print("📅 Nouveau jour de trading - Compteurs réinitialisés");
      }

      // Vérifier les conditions de trading
      if(!g_riskManager.CanTrade())
         return;

      if(!g_timeFilter.IsTimeToTrade())
      {
         // Fermer les positions en fin de session si activé
         if(CloseAtEndOfSession && g_tradeManager.CountOpenPositions() > 0)
         {
            if(g_timeFilter.MinutesUntilEndOfTrading() <= 0)
            {
               Print("⏰ Fin de session - Fermeture des positions");
               g_tradeManager.CloseAllPositions();
            }
         }
         return;
      }

      // Initialiser la session (high/low du début)
      if(!g_sessionInitialized)
      {
         InitializeSession();
      }

      // Mettre à jour le high/low de la session
      UpdateSessionHighLow();

      // Chercher des opportunités de trading
      if(g_tradesOpenedToday < MaxTradesPerDay &&
         g_tradeManager.CountOpenPositions() < MaxPositions)
      {
         CheckForTradingOpportunity();
      }
   }

   // Gestion des positions ouvertes (à chaque tick)
   if(g_tradeManager.CountOpenPositions() > 0)
   {
      g_tradeManager.ManageBreakEven();
      g_tradeManager.ManageTrailingStop();
   }
}

//+------------------------------------------------------------------+
//| Initialise la session de trading                                |
//+------------------------------------------------------------------+
void InitializeSession()
{
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   if(CopyHigh(_Symbol, PERIOD_M5, 0, BreakoutPeriod, high) > 0 &&
      CopyLow(_Symbol, PERIOD_M5, 0, BreakoutPeriod, low) > 0)
   {
      g_sessionHigh = high[ArrayMaximum(high)];
      g_sessionLow = low[ArrayMinimum(low)];
      g_sessionInitialized = true;

      Print("🎯 Session initialisée - High: ", g_sessionHigh, " Low: ", g_sessionLow);
   }
}

//+------------------------------------------------------------------+
//| Met à jour le high/low de la session                            |
//+------------------------------------------------------------------+
void UpdateSessionHighLow()
{
   double currentHigh = iHigh(_Symbol, PERIOD_M5, 1);
   double currentLow = iLow(_Symbol, PERIOD_M5, 1);

   if(currentHigh > g_sessionHigh)
      g_sessionHigh = currentHigh;

   if(currentLow < g_sessionLow)
      g_sessionLow = currentLow;
}

//+------------------------------------------------------------------+
//| Recherche des opportunités de trading                           |
//+------------------------------------------------------------------+
void CheckForTradingOpportunity()
{
   double currentClose = iClose(_Symbol, PERIOD_M5, 1);
   double currentOpen = iOpen(_Symbol, PERIOD_M5, 1);

   // Copier les valeurs ATR
   if(CopyBuffer(g_atrHandle, 0, 0, 3, g_atrBuffer) <= 0)
      return;

   double atr = g_atrBuffer[0];

   // Signal ACHAT: Breakout au-dessus du high de session
   if(currentClose > g_sessionHigh)
   {
      double breakoutSize = currentClose - g_sessionHigh;

      if(breakoutSize >= MinBreakoutPoints * _Point)
      {
         // Confirmation par volume si activé
         if(UseVolume)
         {
            long volume[];
            ArraySetAsSeries(volume, true);
            if(CopyTickVolume(_Symbol, PERIOD_M5, 0, 3, volume) > 0)
            {
               if(volume[1] <= volume[2]) // Volume décroissant = pas de confirmation
                  return;
            }
         }

         // Calculer SL et TP basés sur ATR
         double sl = currentClose - (atr * ATRMultiplierSL);
         double tp = currentClose + (atr * ATRMultiplierTP);

         double stopLossPoints = MathAbs(currentClose - sl);
         double lot = g_riskManager.CalculateLotSize(_Symbol, stopLossPoints);

         if(lot > 0)
         {
            if(g_tradeManager.OpenBuy(lot, sl, tp, TradeComment + " Breakout"))
            {
               g_tradesOpenedToday++;
               Print("🚀 SIGNAL BUY - Breakout confirmé");
               g_riskManager.PrintRiskStats();
            }
         }
      }
   }

   // Signal VENTE: Breakout en-dessous du low de session
   else if(currentClose < g_sessionLow)
   {
      double breakoutSize = g_sessionLow - currentClose;

      if(breakoutSize >= MinBreakoutPoints * _Point)
      {
         // Confirmation par volume si activé
         if(UseVolume)
         {
            long volume[];
            ArraySetAsSeries(volume, true);
            if(CopyTickVolume(_Symbol, PERIOD_M5, 0, 3, volume) > 0)
            {
               if(volume[1] <= volume[2]) // Volume décroissant = pas de confirmation
                  return;
            }
         }

         // Calculer SL et TP basés sur ATR
         double sl = currentClose + (atr * ATRMultiplierSL);
         double tp = currentClose - (atr * ATRMultiplierTP);

         double stopLossPoints = MathAbs(sl - currentClose);
         double lot = g_riskManager.CalculateLotSize(_Symbol, stopLossPoints);

         if(lot > 0)
         {
            if(g_tradeManager.OpenSell(lot, sl, tp, TradeComment + " Breakout"))
            {
               g_tradesOpenedToday++;
               Print("🚀 SIGNAL SELL - Breakout confirmé");
               g_riskManager.PrintRiskStats();
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Affiche la configuration de l'EA                                |
//+------------------------------------------------------------------+
void PrintConfiguration()
{
   Print("");
   Print("📋 Configuration:");
   Print("   Symbole: ", _Symbol);
   Print("   Timeframe: M5");
   Print("   Magic Number: ", MagicNumber);
   Print("");
   Print("💰 Gestion du Risque:");
   Print("   Risque par trade: ", RiskPerTrade, "%");
   Print("   Perte journalière max: ", MaxDailyLoss, "%");
   Print("   Perte totale max: ", MaxTotalLoss, "%");
   Print("   Max positions: ", MaxPositions);
   Print("   Max trades/jour: ", MaxTradesPerDay);
   Print("");
   Print("🕐 Horaires de Trading:");
   Print("   Début: ", StartHour, ":", StringFormat("%02d", StartMinute), " UTC");
   Print("   Fin: ", EndHour, ":", StringFormat("%02d", EndMinute), " UTC");
   Print("   Ajustement DST: ", (AutoAdjustDST ? "OUI" : "NON"));
   Print("");
   Print("📈 Stratégie:");
   Print("   Période breakout: ", BreakoutPeriod, " minutes");
   Print("   Points min breakout: ", MinBreakoutPoints);
   Print("   ATR période: ", ATRPeriod);
   Print("   SL: ATR x ", ATRMultiplierSL);
   Print("   TP: ATR x ", ATRMultiplierTP);
   Print("");
   Print("🎯 Gestion Positions:");
   Print("   Break-even: ", BreakEvenPoints, " points (+", BreakEvenProfit, ")");
   Print("   Trailing: ", TrailingStart, " points (pas: ", TrailingStep, ")");
   Print("   Fermeture fin session: ", (CloseAtEndOfSession ? "OUI" : "NON"));
   Print("");
}

//+------------------------------------------------------------------+
//| Retourne le texte de la raison de désinitialisation             |
//+------------------------------------------------------------------+
string GetUninitReasonText(int reason)
{
   switch(reason)
   {
      case REASON_PROGRAM: return "Programme arrêté";
      case REASON_REMOVE: return "EA retiré du graphique";
      case REASON_RECOMPILE: return "EA recompilé";
      case REASON_CHARTCHANGE: return "Changement de symbole/période";
      case REASON_CHARTCLOSE: return "Graphique fermé";
      case REASON_PARAMETERS: return "Paramètres modifiés";
      case REASON_ACCOUNT: return "Compte changé";
      default: return "Raison inconnue";
   }
}
