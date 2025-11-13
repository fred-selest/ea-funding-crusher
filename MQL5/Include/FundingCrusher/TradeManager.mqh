//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                                       EA Funding Crusher MT5     |
//|                              Gestion des trades et des positions |
//+------------------------------------------------------------------+
#property copyright "EA Funding Crusher"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//+------------------------------------------------------------------+
//| Class TradeManager                                               |
//| Gestion des ordres, positions, trailing stop, break-even        |
//+------------------------------------------------------------------+
class TradeManager
{
private:
   CTrade         m_trade;
   CPositionInfo  m_position;
   COrderInfo     m_order;
   string         m_symbol;
   ulong          m_magicNumber;
   int            m_slippage;

   // Paramètres de gestion
   double         m_breakEvenPoints;      // Points pour activer le break-even
   double         m_breakEvenProfit;      // Profit à laisser au break-even
   double         m_trailingStartPoints;  // Points pour activer le trailing
   double         m_trailingStepPoints;   // Pas du trailing stop

public:
   //--- Constructor
   TradeManager(string symbol, ulong magicNumber = 12345)
   {
      m_symbol = symbol;
      m_magicNumber = magicNumber;
      m_slippage = 10;
      m_breakEvenPoints = 50;
      m_breakEvenProfit = 10;
      m_trailingStartPoints = 100;
      m_trailingStepPoints = 20;

      m_trade.SetExpertMagicNumber(m_magicNumber);
      m_trade.SetMarginMode();
      m_trade.SetTypeFillingBySymbol(m_symbol);
      m_trade.SetDeviationInPoints(m_slippage);
   }

   //--- Ouvre une position BUY
   bool OpenBuy(double lot, double stopLoss, double takeProfit, string comment = "")
   {
      double price = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

      // Normaliser les prix
      double sl = NormalizePrice(stopLoss);
      double tp = NormalizePrice(takeProfit);

      if(m_trade.Buy(lot, m_symbol, price, sl, tp, comment))
      {
         Print("✅ Ordre BUY ouvert: Lot=", lot, " SL=", sl, " TP=", tp);
         return true;
      }
      else
      {
         Print("❌ Erreur ouverture BUY: ", GetLastError(), " - ", m_trade.ResultRetcodeDescription());
         return false;
      }
   }

   //--- Ouvre une position SELL
   bool OpenSell(double lot, double stopLoss, double takeProfit, string comment = "")
   {
      double price = SymbolInfoDouble(m_symbol, SYMBOL_BID);

      // Normaliser les prix
      double sl = NormalizePrice(stopLoss);
      double tp = NormalizePrice(takeProfit);

      if(m_trade.Sell(lot, m_symbol, price, sl, tp, comment))
      {
         Print("✅ Ordre SELL ouvert: Lot=", lot, " SL=", sl, " TP=", tp);
         return true;
      }
      else
      {
         Print("❌ Erreur ouverture SELL: ", GetLastError(), " - ", m_trade.ResultRetcodeDescription());
         return false;
      }
   }

   //--- Ferme toutes les positions du symbole
   bool CloseAllPositions()
   {
      int total = PositionsTotal();
      int closed = 0;

      for(int i = total - 1; i >= 0; i--)
      {
         if(m_position.SelectByIndex(i))
         {
            if(m_position.Symbol() == m_symbol && m_position.Magic() == m_magicNumber)
            {
               if(m_trade.PositionClose(m_position.Ticket()))
               {
                  closed++;
                  Print("✅ Position fermée: Ticket=", m_position.Ticket());
               }
            }
         }
      }

      Print("📊 Positions fermées: ", closed, "/", total);
      return (closed > 0);
   }

   //--- Compte le nombre de positions ouvertes
   int CountOpenPositions()
   {
      int count = 0;
      int total = PositionsTotal();

      for(int i = 0; i < total; i++)
      {
         if(m_position.SelectByIndex(i))
         {
            if(m_position.Symbol() == m_symbol && m_position.Magic() == m_magicNumber)
               count++;
         }
      }

      return count;
   }

   //--- Gestion du break-even pour toutes les positions
   void ManageBreakEven()
   {
      int total = PositionsTotal();

      for(int i = 0; i < total; i++)
      {
         if(m_position.SelectByIndex(i))
         {
            if(m_position.Symbol() != m_symbol || m_position.Magic() != m_magicNumber)
               continue;

            double openPrice = m_position.PriceOpen();
            double currentSL = m_position.StopLoss();
            double currentPrice = (m_position.Type() == POSITION_TYPE_BUY) ?
                                   SymbolInfoDouble(m_symbol, SYMBOL_BID) :
                                   SymbolInfoDouble(m_symbol, SYMBOL_ASK);

            double points = MathAbs(currentPrice - openPrice);

            // Vérifier si on doit activer le break-even
            if(points >= m_breakEvenPoints * _Point)
            {
               double newSL = 0;

               if(m_position.Type() == POSITION_TYPE_BUY)
               {
                  newSL = openPrice + (m_breakEvenProfit * _Point);
                  // Ne déplacer que si le nouveau SL est meilleur
                  if(newSL > currentSL || currentSL == 0)
                  {
                     newSL = NormalizePrice(newSL);

                     // Vérifier que le SL respecte le stop level minimum
                     if(IsValidStopLevel(currentPrice, newSL, true))
                     {
                        if(m_trade.PositionModify(m_position.Ticket(), newSL, m_position.TakeProfit()))
                        {
                           Print("🎯 Break-Even BUY activé: Ticket=", m_position.Ticket(),
                                 " Nouveau SL=", newSL);
                        }
                     }
                  }
               }
               else if(m_position.Type() == POSITION_TYPE_SELL)
               {
                  newSL = openPrice - (m_breakEvenProfit * _Point);
                  // Ne déplacer que si le nouveau SL est meilleur
                  if(newSL < currentSL || currentSL == 0)
                  {
                     newSL = NormalizePrice(newSL);

                     // Vérifier que le SL respecte le stop level minimum
                     if(IsValidStopLevel(currentPrice, newSL, false))
                     {
                        if(m_trade.PositionModify(m_position.Ticket(), newSL, m_position.TakeProfit()))
                        {
                           Print("🎯 Break-Even SELL activé: Ticket=", m_position.Ticket(),
                                 " Nouveau SL=", newSL);
                        }
                     }
                  }
               }
            }
         }
      }
   }

   //--- Gestion du trailing stop pour toutes les positions
   void ManageTrailingStop()
   {
      int total = PositionsTotal();

      for(int i = 0; i < total; i++)
      {
         if(m_position.SelectByIndex(i))
         {
            if(m_position.Symbol() != m_symbol || m_position.Magic() != m_magicNumber)
               continue;

            double openPrice = m_position.PriceOpen();
            double currentSL = m_position.StopLoss();
            double currentPrice = (m_position.Type() == POSITION_TYPE_BUY) ?
                                   SymbolInfoDouble(m_symbol, SYMBOL_BID) :
                                   SymbolInfoDouble(m_symbol, SYMBOL_ASK);

            if(m_position.Type() == POSITION_TYPE_BUY)
            {
               double profit = currentPrice - openPrice;

               // Vérifier si on doit activer le trailing
               if(profit >= m_trailingStartPoints * _Point)
               {
                  double newSL = currentPrice - (m_trailingStepPoints * _Point);
                  newSL = NormalizePrice(newSL);

                  // Ne déplacer que si le nouveau SL est meilleur
                  if(newSL > currentSL && newSL < currentPrice)
                  {
                     // Vérifier que le SL respecte le stop level minimum
                     if(IsValidStopLevel(currentPrice, newSL, true))
                     {
                        if(m_trade.PositionModify(m_position.Ticket(), newSL, m_position.TakeProfit()))
                        {
                           Print("📈 Trailing Stop BUY: Ticket=", m_position.Ticket(),
                                 " Nouveau SL=", newSL);
                        }
                     }
                  }
               }
            }
            else if(m_position.Type() == POSITION_TYPE_SELL)
            {
               double profit = openPrice - currentPrice;

               // Vérifier si on doit activer le trailing
               if(profit >= m_trailingStartPoints * _Point)
               {
                  double newSL = currentPrice + (m_trailingStepPoints * _Point);
                  newSL = NormalizePrice(newSL);

                  // Ne déplacer que si le nouveau SL est meilleur
                  if(newSL < currentSL && newSL > currentPrice)
                  {
                     // Vérifier que le SL respecte le stop level minimum
                     if(IsValidStopLevel(currentPrice, newSL, false))
                     {
                        if(m_trade.PositionModify(m_position.Ticket(), newSL, m_position.TakeProfit()))
                        {
                           Print("📉 Trailing Stop SELL: Ticket=", m_position.Ticket(),
                                 " Nouveau SL=", newSL);
                        }
                     }
                  }
               }
            }
         }
      }
   }

   //--- Normalise un prix selon les spécifications du symbole
   double NormalizePrice(double price)
   {
      double tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
      return MathRound(price / tickSize) * tickSize;
   }

   //--- Vérifie si un SL/TP respecte les niveaux minimum du broker
   bool IsValidStopLevel(double currentPrice, double stopPrice, bool isBuy)
   {
      // Obtenir le stop level minimum du broker (en points)
      long stopLevel = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double minDistance = stopLevel * _Point;

      // Ajouter une marge de sécurité de 20%
      minDistance *= 1.2;

      double distance = MathAbs(currentPrice - stopPrice);

      if(distance < minDistance)
      {
         Print("⚠️  SL trop proche: Distance=", DoubleToString(distance / _Point, 1),
               " points < Minimum=", DoubleToString(minDistance / _Point, 1), " points");
         return false;
      }

      return true;
   }

   //--- Obtenir les informations des positions
   void PrintPositionsInfo()
   {
      int total = PositionsTotal();
      int count = 0;

      Print("📊 Positions ouvertes sur ", m_symbol, ":");

      for(int i = 0; i < total; i++)
      {
         if(m_position.SelectByIndex(i))
         {
            if(m_position.Symbol() == m_symbol && m_position.Magic() == m_magicNumber)
            {
               count++;
               Print("   Ticket: ", m_position.Ticket(),
                     " Type: ", (m_position.Type() == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                     " Lot: ", m_position.Volume(),
                     " Open: ", m_position.PriceOpen(),
                     " SL: ", m_position.StopLoss(),
                     " TP: ", m_position.TakeProfit(),
                     " P&L: ", m_position.Profit());
            }
         }
      }

      if(count == 0)
         Print("   Aucune position ouverte");
   }

   //--- Setters
   void SetBreakEven(double activationPoints, double profitPoints)
   {
      m_breakEvenPoints = activationPoints;
      m_breakEvenProfit = profitPoints;
   }

   void SetTrailingStop(double startPoints, double stepPoints)
   {
      m_trailingStartPoints = startPoints;
      m_trailingStepPoints = stepPoints;
   }

   void SetSlippage(int slippage) { m_slippage = slippage; }

   //--- Getters
   int GetSlippage() { return m_slippage; }
};
