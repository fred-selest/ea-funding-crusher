//+------------------------------------------------------------------+
//|                                                   TimeFilter.mqh |
//|                                       EA Funding Crusher MT5     |
//|                          Filtre temporel pour ouverture marché US|
//+------------------------------------------------------------------+
#property copyright "EA Funding Crusher"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Class TimeFilter                                                 |
//| Gestion des horaires de trading optimaux                        |
//+------------------------------------------------------------------+
class TimeFilter
{
private:
   int      m_startHour;          // Heure de début (UTC)
   int      m_startMinute;        // Minute de début
   int      m_endHour;            // Heure de fin (UTC)
   int      m_endMinute;          // Minute de fin
   bool     m_tradeMondayOpen;    // Trading à l'ouverture du lundi
   bool     m_tradeFridayClose;   // Trading à la clôture du vendredi
   int      m_brokerUTCOffset;    // Décalage UTC du broker

public:
   //--- Constructor
   TimeFilter(int startHour = 13,        // 13h30 UTC = 9h30 EST (heure d'été)
              int startMinute = 30,
              int endHour = 18,          // 18h00 UTC = 14h00 EST
              int endMinute = 0,
              int brokerOffset = 0)
   {
      m_startHour = startHour;
      m_startMinute = startMinute;
      m_endHour = endHour;
      m_endMinute = endMinute;
      m_tradeMondayOpen = false;
      m_tradeFridayClose = false;
      m_brokerUTCOffset = brokerOffset;
   }

   //--- Vérifie si on est dans la plage horaire de trading
   bool IsTimeToTrade()
   {
      MqlDateTime currentTime;
      TimeToStruct(TimeCurrent(), currentTime);

      // Vérifier le jour de la semaine
      if(!IsTradingDay(currentTime))
         return false;

      // Convertir l'heure courante en minutes depuis minuit
      int currentMinutes = (currentTime.hour * 60) + currentTime.min;
      int startMinutes = (m_startHour * 60) + m_startMinute;
      int endMinutes = (m_endHour * 60) + m_endMinute;

      // Vérifier si on est dans la plage horaire
      bool inTimeRange = (currentMinutes >= startMinutes && currentMinutes < endMinutes);

      return inTimeRange;
   }

   //--- Vérifie si le jour est valide pour trader
   bool IsTradingDay(MqlDateTime &time)
   {
      // Pas de trading le weekend
      if(time.day_of_week == 0 || time.day_of_week == 6)
         return false;

      // Vérification spéciale pour lundi
      if(time.day_of_week == 1 && !m_tradeMondayOpen)
      {
         // Ne pas trader dans les 2 premières heures du lundi
         if(time.hour < 2)
            return false;
      }

      // Vérification spéciale pour vendredi
      if(time.day_of_week == 5 && !m_tradeFridayClose)
      {
         // Ne pas trader dans les 2 dernières heures du vendredi
         if(time.hour >= 20)
            return false;
      }

      return true;
   }

   //--- Calcule le temps restant avant la fenêtre de trading
   int MinutesUntilTradingTime()
   {
      MqlDateTime currentTime;
      TimeToStruct(TimeCurrent(), currentTime);

      int currentMinutes = (currentTime.hour * 60) + currentTime.min;
      int startMinutes = (m_startHour * 60) + m_startMinute;

      if(currentMinutes < startMinutes)
         return startMinutes - currentMinutes;
      else
         return (1440 - currentMinutes) + startMinutes; // Attendre le lendemain
   }

   //--- Calcule le temps restant dans la fenêtre de trading
   int MinutesUntilEndOfTrading()
   {
      MqlDateTime currentTime;
      TimeToStruct(TimeCurrent(), currentTime);

      int currentMinutes = (currentTime.hour * 60) + currentTime.min;
      int endMinutes = (m_endHour * 60) + m_endMinute;

      if(currentMinutes < endMinutes)
         return endMinutes - currentMinutes;
      else
         return 0;
   }

   //--- Vérifie si on approche de la fin de la session
   bool IsNearSessionEnd(int minutesBuffer = 30)
   {
      return (MinutesUntilEndOfTrading() <= minutesBuffer);
   }

   //--- Affiche les informations de temps
   void PrintTimeInfo()
   {
      MqlDateTime currentTime;
      TimeToStruct(TimeCurrent(), currentTime);

      Print("🕐 Informations temporelles:");
      Print("   Heure actuelle: ", TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES));
      Print("   Jour de la semaine: ", GetDayName(currentTime.day_of_week));
      Print("   Trading actif: ", (IsTimeToTrade() ? "OUI" : "NON"));

      if(!IsTimeToTrade())
      {
         int minutesUntil = MinutesUntilTradingTime();
         Print("   Prochaine session dans: ", minutesUntil, " minutes");
      }
      else
      {
         int minutesLeft = MinutesUntilEndOfTrading();
         Print("   Temps restant: ", minutesLeft, " minutes");
      }
   }

   //--- Retourne le nom du jour
   string GetDayName(int dayOfWeek)
   {
      switch(dayOfWeek)
      {
         case 0: return "Dimanche";
         case 1: return "Lundi";
         case 2: return "Mardi";
         case 3: return "Mercredi";
         case 4: return "Jeudi";
         case 5: return "Vendredi";
         case 6: return "Samedi";
         default: return "Inconnu";
      }
   }

   //--- Setters
   void SetStartTime(int hour, int minute)
   {
      m_startHour = hour;
      m_startMinute = minute;
   }

   void SetEndTime(int hour, int minute)
   {
      m_endHour = hour;
      m_endMinute = minute;
   }

   void SetMondayTrading(bool allow) { m_tradeMondayOpen = allow; }
   void SetFridayTrading(bool allow) { m_tradeFridayClose = allow; }

   //--- Ajustement automatique heure d'été/hiver US
   void AdjustForDST()
   {
      MqlDateTime currentTime;
      TimeToStruct(TimeCurrent(), currentTime);

      // Heure d'été US (mars-novembre): 13h30 UTC = 9h30 EST
      // Heure d'hiver US (novembre-mars): 14h30 UTC = 9h30 EST

      bool isDST = IsDaylightSavingTime(currentTime);

      if(isDST)
      {
         m_startHour = 13;    // 9h30 EST en UTC (été)
      }
      else
      {
         m_startHour = 14;    // 9h30 EST en UTC (hiver)
      }

      Print("🌍 Ajustement DST: ", (isDST ? "Heure d'été" : "Heure d'hiver"),
            " - Début: ", m_startHour, ":", StringFormat("%02d", m_startMinute), " UTC");
   }

   //--- Détecte si on est en heure d'été US
   bool IsDaylightSavingTime(MqlDateTime &time)
   {
      // L'heure d'été US commence le 2ème dimanche de mars
      // et se termine le 1er dimanche de novembre

      if(time.mon < 3 || time.mon > 11)
         return false;
      if(time.mon > 3 && time.mon < 11)
         return true;

      // Mars: vérifier si on est après le 2ème dimanche
      if(time.mon == 3)
      {
         int secondSunday = GetNthDayOfMonth(time.year, 3, 0, 2);
         return (time.day >= secondSunday);
      }

      // Novembre: vérifier si on est avant le 1er dimanche
      if(time.mon == 11)
      {
         int firstSunday = GetNthDayOfMonth(time.year, 11, 0, 1);
         return (time.day < firstSunday);
      }

      return false;
   }

   //--- Trouve le Nième jour de la semaine dans un mois
   int GetNthDayOfMonth(int year, int month, int dayOfWeek, int n)
   {
      MqlDateTime firstDay;
      firstDay.year = year;
      firstDay.mon = month;
      firstDay.day = 1;
      firstDay.hour = 0;
      firstDay.min = 0;
      firstDay.sec = 0;

      datetime firstDayTime = StructToTime(firstDay);
      TimeToStruct(firstDayTime, firstDay);

      int firstDayOfWeek = firstDay.day_of_week;
      int daysUntilTarget = (dayOfWeek - firstDayOfWeek + 7) % 7;

      return 1 + daysUntilTarget + ((n - 1) * 7);
   }
};
