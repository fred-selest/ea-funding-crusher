# ⚙️ Guide de Configuration - DJ30 Funding Crusher

## Table des matières
- [Vue d'ensemble](#vue-densemble)
- [Paramètres détaillés](#paramètres-détaillés)
- [Configurations prédéfinies](#configurations-prédéfinies)
- [Optimisation](#optimisation)
- [FAQ](#faq)

---

## Vue d'ensemble

L'EA **DJ30 Funding Crusher** utilise une stratégie de **breakout à l'ouverture du marché US** pour capturer les mouvements forts du Dow Jones 30.

### 🎯 Philosophie de la stratégie

1. **Timing optimal**: Trading pendant les premières heures de l'ouverture US (haute volatilité)
2. **Breakout confirmé**: Attend une cassure significative des niveaux de la session
3. **Risk management strict**: Conforme aux règles des propfirms (FTMO, etc.)
4. **Protection des profits**: Break-even et trailing stop automatiques

---

## Paramètres détaillés

### 💰 Gestion du Risque

#### `RiskPerTrade` (défaut: 1.0%)
- **Description**: Pourcentage du compte risqué par trade
- **Recommandations**:
  - FTMO Phase 1: 1.0% (conservateur)
  - FTMO Phase 2: 0.5% (très conservateur)
  - Compte financé: 0.5-1.0%
  - Trading agressif: 1.5-2.0% (NON recommandé pour propfirms)

#### `MaxDailyLoss` (défaut: 5.0%)
- **Description**: Perte maximale autorisée par jour
- **Recommandations**:
  - FTMO: 4.0% (marge de sécurité, limite officielle: 5%)
  - Autres propfirms: Vérifier leurs règles et retirer 1%
  - **IMPORTANT**: Si cette limite est atteinte, l'EA arrête de trader pour la journée

#### `MaxTotalLoss` (défaut: 10.0%)
- **Description**: Perte maximale totale depuis le début
- **Recommandations**:
  - FTMO: 8.0% (marge de sécurité, limite officielle: 10%)
  - **IMPORTANT**: Si atteint, l'EA arrête complètement de trader

#### `MaxPositions` (défaut: 1)
- **Description**: Nombre maximum de positions simultanées
- **Recommandations**:
  - Débutant: 1 (une position à la fois)
  - Avancé: 2-3 (si vous comprenez bien la corrélation)
  - **Note**: Plus de positions = plus de risque

#### `MaxTradesPerDay` (défaut: 3)
- **Description**: Nombre maximum de trades par jour
- **Recommandations**:
  - Conservateur: 2-3 trades/jour
  - Normal: 3-5 trades/jour
  - **Note**: Sur DJ30 à l'ouverture, la qualité > quantité

---

### 🕐 Filtre Temporel

#### `StartHour` et `StartMinute` (défaut: 13h30 UTC)
- **Description**: Heure de début de la session de trading
- **Configuration selon saison**:
  - **Heure d'été US** (mars-novembre): 13h30 UTC = 9h30 EST
  - **Heure d'hiver US** (novembre-mars): 14h30 UTC = 9h30 EST
- **Note**: Si `AutoAdjustDST = true`, l'EA ajuste automatiquement

#### `EndHour` et `EndMinute` (défaut: 18h00 UTC)
- **Description**: Heure de fin de la session de trading
- **Recommandations**:
  - Court terme: 18h00 UTC (4-5h de trading)
  - Moyen terme: 21h00 UTC (journée complète)

#### `AutoAdjustDST` (défaut: true)
- **Description**: Ajustement automatique heure d'été/hiver
- **Recommandation**: Laisser à `true` pour éviter les erreurs

**⚠️ IMPORTANT**: Vérifiez le fuseau horaire de votre broker!
Certains brokers affichent l'heure du serveur (souvent GMT+2/+3).

---

### 📈 Stratégie de Trading

#### `BreakoutPeriod` (défaut: 5 minutes)
- **Description**: Nombre de bougies pour définir le range initial
- **Recommandations**:
  - Scalping: 3-5 minutes
  - Intraday: 5-10 minutes
  - **Note**: Plus court = plus de signaux, mais plus de faux signaux

#### `MinBreakoutPoints` (défaut: 50)
- **Description**: Points minimum pour valider un breakout
- **Recommandations**:
  - DJ30 volatile: 50-100 points
  - DJ30 calme: 30-50 points
  - **Calcul**: 1 point = 1 dollar de mouvement sur DJ30

#### `ATRMultiplierSL` (défaut: 2.0)
- **Description**: Multiplicateur ATR pour le Stop Loss
- **Recommandations**:
  - Conservateur: 2.5-3.0 (SL plus large, moins de stop-outs)
  - Normal: 2.0
  - Agressif: 1.5 (SL plus serré, plus de stop-outs)
- **Exemple**: Si ATR = 100, SL = 100 × 2.0 = 200 points

#### `ATRMultiplierTP` (défaut: 3.0)
- **Description**: Multiplicateur ATR pour le Take Profit
- **Recommandations**:
  - Ratio risque/rendement idéal: 1:1.5 à 1:3
  - Si SL = 2.0, TP devrait être 3.0-4.0
  - **Note**: TP trop loin = moins de trades gagnants

#### `ATRPeriod` (défaut: 14)
- **Description**: Période pour le calcul de l'ATR
- **Recommandations**:
  - Standard: 14 périodes
  - Plus réactif: 10 périodes
  - Plus lisse: 20 périodes

#### `UseVolume` (défaut: true)
- **Description**: Confirmer les breakouts avec le volume
- **Recommandations**:
  - `true`: Meilleure qualité de signaux (recommandé)
  - `false`: Plus de signaux, mais plus de faux positifs

---

### 🎯 Gestion des Positions

#### `BreakEvenPoints` (défaut: 50)
- **Description**: Points de profit pour déplacer le SL au break-even
- **Recommandations**:
  - DJ30: 50-100 points
  - **Formule**: ATR × 0.5 à ATR × 1.0

#### `BreakEvenProfit` (défaut: 10)
- **Description**: Profit à laisser au break-even
- **Recommandations**:
  - Spread DJ30: 5-10 points
  - Laisser 10-20 points pour éviter un BE puis reversal

#### `TrailingStart` (défaut: 100)
- **Description**: Points de profit pour activer le trailing stop
- **Recommandations**:
  - DJ30: 100-150 points
  - **Formule**: ATR × 1.0 à ATR × 1.5

#### `TrailingStep` (défaut: 20)
- **Description**: Distance du trailing stop par rapport au prix
- **Recommandations**:
  - Serré: 10-15 points (sécurise rapidement, coupe les grandes vagues)
  - Normal: 20-30 points
  - Large: 40-50 points (laisse respirer, risque de rendre plus)

#### `CloseAtEndOfSession` (défaut: true)
- **Description**: Fermer toutes les positions en fin de session
- **Recommandations**:
  - `true`: Évite le risque overnight (recommandé pour challenges)
  - `false`: Garde les positions overnight (nécessite surveillance)

---

### ⚙️ Paramètres Généraux

#### `MagicNumber` (défaut: 202411)
- **Description**: Identifiant unique de l'EA
- **Usage**: Change uniquement si vous utilisez plusieurs EAs

#### `TradeComment` (défaut: "DJ30_Crusher")
- **Description**: Commentaire attaché aux trades
- **Usage**: Pour identifier vos trades dans l'historique

---

## Configurations prédéfinies

### 🥇 Configuration FTMO Phase 1 (Objectif: 10% en 30 jours)

```mql5
// Risque
RiskPerTrade        = 1.0
MaxDailyLoss        = 4.0
MaxTotalLoss        = 8.0
MaxPositions        = 1
MaxTradesPerDay     = 3

// Temps
StartHour           = 13
StartMinute         = 30
EndHour             = 18
EndMinute           = 0
AutoAdjustDST       = true

// Stratégie
BreakoutPeriod      = 5
MinBreakoutPoints   = 50
ATRMultiplierSL     = 2.0
ATRMultiplierTP     = 3.0
ATRPeriod           = 14
UseVolume           = true

// Gestion
BreakEvenPoints     = 50
BreakEvenProfit     = 10
TrailingStart       = 100
TrailingStep        = 20
CloseAtEndOfSession = true
```

### 🥈 Configuration FTMO Phase 2 (Objectif: 5% en 60 jours)

```mql5
// Risque - TRÈS CONSERVATEUR
RiskPerTrade        = 0.5    // ⬇️ Réduit
MaxDailyLoss        = 3.0    // ⬇️ Réduit
MaxTotalLoss        = 7.0    // ⬇️ Réduit
MaxPositions        = 1
MaxTradesPerDay     = 2      // ⬇️ Réduit

// Reste identique à Phase 1
```

### 🎖️ Configuration Compte Financé (Trading conservateur)

```mql5
// Risque
RiskPerTrade        = 0.5    // Très conservateur
MaxDailyLoss        = 3.0
MaxTotalLoss        = 5.0
MaxPositions        = 1
MaxTradesPerDay     = 5      // Plus de trades autorisés

// Temps - Session plus longue
EndHour             = 21     // ⬆️ Étendu
EndMinute           = 0

// Gestion - Trailing plus agressif
TrailingStart       = 80     // ⬇️ Démarre plus tôt
TrailingStep        = 15     // ⬇️ Plus serré
CloseAtEndOfSession = false  // ⬇️ Positions overnight OK
```

### 🔥 Configuration Agressive (NON recommandé pour propfirms)

```mql5
// ⚠️ ATTENTION: Haut risque!
RiskPerTrade        = 2.0    // ⚠️
MaxDailyLoss        = 6.0    // ⚠️
MaxPositions        = 2      // ⚠️
MaxTradesPerDay     = 5      // ⚠️

// Breakout plus réactif
MinBreakoutPoints   = 30     // ⬇️
ATRMultiplierSL     = 1.5    // ⬇️ SL plus serré
```

---

## Optimisation

### 📊 Backtesting

#### Préparation
1. Ouvrez le **Strategy Tester** dans MT5 (Ctrl+R)
2. Sélectionnez l'EA `DJ30_FundingCrusher`
3. Symbole: US30 ou DJ30
4. Période: M5 (5 minutes)
5. Dates: Minimum 3 mois de données

#### Paramètres de test
```
Mode: "Every tick" ou "Every tick based on real ticks"
Optimisation: Désactivé (pour test simple)
Balance initiale: 100,000 (FTMO standard)
```

#### Métriques à surveiller
- **Profit Factor**: > 1.5 (bon), > 2.0 (excellent)
- **Drawdown**: < 10% (pour FTMO)
- **Win Rate**: 40-60% (avec bon ratio RR)
- **Nombre de trades**: Minimum 30 pour statistiques valides

### 🔧 Optimisation des paramètres

**Paramètres à optimiser** (par ordre d'importance):
1. `MinBreakoutPoints`: 30 à 100, pas de 10
2. `ATRMultiplierSL`: 1.5 à 3.0, pas de 0.5
3. `ATRMultiplierTP`: 2.0 à 5.0, pas de 0.5
4. `BreakoutPeriod`: 3 à 10, pas de 1

**Paramètres à NE PAS optimiser**:
- `RiskPerTrade`: Fixer à 1% maximum
- `MaxDailyLoss`: Fixer selon règles propfirm
- `MagicNumber`: Ne jamais toucher

### ⚠️ Attention à l'over-optimization

- Ne pas optimiser sur moins de 3 mois de données
- Tester les résultats sur période différente (forward testing)
- Un bon EA doit fonctionner sur plusieurs configurations

---

## FAQ

### ❓ Questions fréquentes

#### Quel est le meilleur moment pour trader?
**R**: Les 2-3 premières heures de l'ouverture US (9h30-12h30 EST) offrent la meilleure volatilité.

#### Combien de temps pour passer FTMO Phase 1?
**R**: Avec cette stratégie et une bonne discipline:
- Conservateur: 20-30 jours
- Normal: 10-20 jours
- **Important**: Ne pas forcer! Qualité > vitesse

#### L'EA fonctionne-t-il sur d'autres symboles?
**R**: L'EA est optimisé pour DJ30/US30. Pour d'autres symboles:
- Ajuster `MinBreakoutPoints` selon la volatilité
- Ajuster les multiplicateurs ATR
- **Tester sur démo d'abord!**

#### Puis-je utiliser plusieurs EAs simultanément?
**R**: Oui, mais:
- Utilisez des `MagicNumber` différents
- Surveillez le risque total (cumul des EAs)
- Assurez-vous qu'ils ne se contredisent pas

#### L'EA trade pendant les news?
**R**: L'EA ne filtre pas automatiquement les news. Recommandations:
- Désactiver l'EA 15 minutes avant les news majeures (NFP, FOMC, etc.)
- Ou ajuster `MinBreakoutPoints` plus haut pendant ces périodes

#### Faut-il un VPS?
**R**: Fortement recommandé pour:
- Éviter les coupures de connexion
- Trading 24/7 sans interruption
- Latence réduite = meilleure exécution

#### Quel broker choisir?
**R**: Pour les propfirms, utiliser leur broker fourni. Sinon:
- Régulation sérieuse (FCA, ASIC, etc.)
- Spread bas sur DJ30 (< 5 points)
- Exécution rapide
- Historique fiable pour backtesting

---

## 📞 Support

Des questions? Besoin d'aide?

- **GitHub Issues**: https://github.com/fred-selest/ea-funding-crusher/issues
- **Documentation**: Consultez `INSTALLATION.md` pour l'installation

---

## ⚠️ Disclaimer

Cet EA est fourni à titre éducatif. Le trading comporte des risques. Testez toujours sur démo avant d'utiliser de l'argent réel.
