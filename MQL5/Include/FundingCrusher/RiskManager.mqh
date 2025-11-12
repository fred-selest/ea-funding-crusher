//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|                                       EA Funding Crusher MT5     |
//|                                   Risk Management for Propfirms  |
//+------------------------------------------------------------------+
#property copyright "EA Funding Crusher"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Class RiskManager                                                |
//| Gestion du risque adaptée aux règles des propfirms (FTMO, etc.) |
//+------------------------------------------------------------------+
class RiskManager
{
private:
   double   m_maxDailyLossPercent;      // Perte journalière max (%)
   double   m_maxTotalLossPercent;      // Perte totale max (%)
   double   m_riskPerTradePercent;      // Risque par trade (%)
   double   m_startingBalance;          // Solde initial du compte
   double   m_dailyStartBalance;        // Solde au début de la journée
   datetime m_lastCheckDate;            // Dernière date de vérification

public:
   //--- Constructor
   RiskManager(double riskPerTrade = 1.0,
               double maxDailyLoss = 5.0,
               double maxTotalLoss = 10.0)
   {
      m_riskPerTradePercent = riskPerTrade;
      m_maxDailyLossPercent = maxDailyLoss;
      m_maxTotalLossPercent = maxTotalLoss;
      m_startingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_dailyStartBalance = m_startingBalance;
      m_lastCheckDate = TimeCurrent();
   }

   //--- Vérifie si on peut trader selon les limites de risque
   bool CanTrade()
   {
      UpdateDailyBalance();

      // Vérifier la perte journalière
      double dailyLoss = m_dailyStartBalance - AccountInfoDouble(ACCOUNT_BALANCE);
      double dailyLossPercent = (dailyLoss / m_dailyStartBalance) * 100.0;

      if(dailyLossPercent >= m_maxDailyLossPercent)
      {
         Print("⛔ Trading bloqué: Perte journalière max atteinte (",
               DoubleToString(dailyLossPercent, 2), "%)");
         return false;
      }

      // Vérifier la perte totale
      double totalLoss = m_startingBalance - AccountInfoDouble(ACCOUNT_BALANCE);
      double totalLossPercent = (totalLoss / m_startingBalance) * 100.0;

      if(totalLossPercent >= m_maxTotalLossPercent)
      {
         Print("⛔ Trading bloqué: Perte totale max atteinte (",
               DoubleToString(totalLossPercent, 2), "%)");
         return false;
      }

      return true;
   }

   //--- Calcule la taille du lot basée sur le risque et le stop loss
   double CalculateLotSize(string symbol, double stopLossPoints)
   {
      if(stopLossPoints <= 0)
      {
         Print("❌ Erreur: Stop loss invalide");
         return 0.0;
      }

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * (m_riskPerTradePercent / 100.0);

      // Obtenir les informations du symbole
      double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      // Calculer le lot
      double lotSize = (riskAmount / (stopLossPoints * tickValue / tickSize));

      // Normaliser le lot
      lotSize = MathFloor(lotSize / lotStep) * lotStep;
      lotSize = MathMax(lotSize, minLot);
      lotSize = MathMin(lotSize, maxLot);

      Print("💰 Calcul lot: Risk=", DoubleToString(riskAmount, 2),
            " SL=", DoubleToString(stopLossPoints, 1),
            " Lot=", DoubleToString(lotSize, 2));

      return lotSize;
   }

   //--- Met à jour le solde quotidien si nouveau jour
   void UpdateDailyBalance()
   {
      MqlDateTime currentTime, lastCheckTime;
      TimeToStruct(TimeCurrent(), currentTime);
      TimeToStruct(m_lastCheckDate, lastCheckTime);

      // Si on change de jour, réinitialiser le solde quotidien
      if(currentTime.day != lastCheckTime.day)
      {
         m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_lastCheckDate = TimeCurrent();
         Print("📅 Nouveau jour: Solde de référence = ",
               DoubleToString(m_dailyStartBalance, 2));
      }
   }

   //--- Obtenir les statistiques de risque
   void PrintRiskStats()
   {
      UpdateDailyBalance();

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double dailyPL = balance - m_dailyStartBalance;
      double dailyPLPercent = (dailyPL / m_dailyStartBalance) * 100.0;
      double totalPL = balance - m_startingBalance;
      double totalPLPercent = (totalPL / m_startingBalance) * 100.0;

      Print("📊 Statistiques de Risque:");
      Print("   Balance: ", DoubleToString(balance, 2));
      Print("   P&L Journalier: ", DoubleToString(dailyPL, 2),
            " (", DoubleToString(dailyPLPercent, 2), "%)");
      Print("   P&L Total: ", DoubleToString(totalPL, 2),
            " (", DoubleToString(totalPLPercent, 2), "%)");
      Print("   Limite journalière: ", DoubleToString(m_maxDailyLossPercent, 2), "%");
      Print("   Limite totale: ", DoubleToString(m_maxTotalLossPercent, 2), "%");
   }

   //--- Setters pour ajuster les paramètres
   void SetRiskPerTrade(double risk) { m_riskPerTradePercent = risk; }
   void SetMaxDailyLoss(double loss) { m_maxDailyLossPercent = loss; }
   void SetMaxTotalLoss(double loss) { m_maxTotalLossPercent = loss; }
   void ResetStartingBalance() { m_startingBalance = AccountInfoDouble(ACCOUNT_BALANCE); }
};
