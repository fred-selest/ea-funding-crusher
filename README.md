# 🚀 DJ30 Funding Crusher - Expert Advisor MT5

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![MT5](https://img.shields.io/badge/MetaTrader-5-blue.svg)](https://www.metatrader5.com/)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)

Expert Advisor (EA) pour MetaTrader 5 optimisé pour passer les challenges des **propfirms** (FTMO, FTUK, The5ers, etc.) en tradant le **DJ30/US30** pendant l'ouverture du marché américain.

## 📋 Table des matières

- [Caractéristiques](#-caractéristiques)
- [Stratégie](#-stratégie)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Documentation](#-documentation)
- [Avertissement](#️-avertissement)
- [License](#-license)

---

## ✨ Caractéristiques

### 🎯 Optimisé pour les Propfirms

- ✅ **Risk Management strict** conforme aux règles FTMO
- ✅ **Limitation perte journalière** (5% max)
- ✅ **Limitation perte totale** (10% max)
- ✅ **Contrôle du risque par trade** (1% recommandé)
- ✅ **Limite du nombre de positions** simultanées
- ✅ **Limite du nombre de trades** par jour

### 📊 Stratégie Solide

- 🎯 **Breakout à l'ouverture US** (9h30 EST)
- 📈 **Confirmation par volume** (optionnel)
- 📏 **Stop Loss et Take Profit adaptatifs** (basés sur ATR)
- 🎚️ **Break-even automatique** pour sécuriser les profits
- 📉 **Trailing Stop** pour maximiser les gains
- 🕐 **Filtre temporel** pour trader uniquement aux meilleurs moments

### 🛡️ Gestion Avancée

- 🔄 **Ajustement automatique DST** (heure d'été/hiver US)
- 🎲 **Calcul automatique de la taille du lot** selon le risque
- 📊 **Statistiques en temps réel** (P&L journalier et total)
- 🔒 **Magic Number unique** pour éviter les conflits
- 📝 **Logs détaillés** pour suivi et debugging

---

## 🎲 Stratégie

### Concept

L'EA utilise une **stratégie de breakout** pendant les premières heures de l'ouverture du marché américain, période de forte volatilité sur le DJ30/US30.

### Fonctionnement

1. **Initialisation de la session** (9h30 EST)
   - Définit le high et low des 5 premières minutes

2. **Détection du breakout**
   - **Signal ACHAT**: Prix casse le high de session + confirmation volume
   - **Signal VENTE**: Prix casse le low de session + confirmation volume

3. **Validation**
   - Breakout doit être d'au moins X points (configurable)
   - Volume de la bougie doit être supérieur au volume précédent

4. **Entrée en position**
   - Taille du lot calculée selon le risque
   - Stop Loss = Prix d'entrée ± (ATR × 2)
   - Take Profit = Prix d'entrée ± (ATR × 3)

5. **Gestion de la position**
   - **Break-even**: Après 50 points de profit, déplace le SL au BE +10 points
   - **Trailing Stop**: Après 100 points, trailing par pas de 20 points
   - **Fermeture**: En fin de session ou au TP/SL

### Avantages

- ✅ Capture les mouvements forts à l'ouverture
- ✅ Risk/Reward favorable (1:1.5 minimum)
- ✅ Pas de trading overnight (moins de risque)
- ✅ Adapté aux règles strictes des propfirms

---

## 📥 Installation

### Prérequis

- **MetaTrader 5** (Build 3260+)
- **Windows** 7 ou supérieur
- **Compte de trading** compatible (propfirm ou broker)
- **Symbole**: DJ30, US30, ou équivalent

### Installation rapide

1. **Télécharger le projet**
   ```bash
   git clone https://github.com/fred-selest/ea-funding-crusher.git
   ```

2. **Copier les fichiers dans MT5**

   Ouvrir le dossier de données MT5 : `Fichier → Ouvrir le dossier de données`

   Copier:
   ```
   ea-funding-crusher/MQL5/Include/FundingCrusher/
   → [MT5]/MQL5/Include/FundingCrusher/

   ea-funding-crusher/MQL5/Experts/DJ30_FundingCrusher.mq5
   → [MT5]/MQL5/Experts/DJ30_FundingCrusher.mq5
   ```

3. **Compiler l'EA**
   - Ouvrir MetaEditor (F4)
   - Localiser `Experts/DJ30_FundingCrusher.mq5`
   - Compiler (F7)
   - Vérifier: `0 error(s), 0 warning(s)`

4. **Attacher au graphique**
   - Ouvrir un graphique US30 M5
   - Glisser-déposer l'EA depuis le Navigateur
   - Activer le trading automatique

📚 **Guide complet**: Voir [docs/INSTALLATION.md](docs/INSTALLATION.md)

---

## ⚙️ Configuration

### Configuration FTMO Phase 1 (Recommandée)

```mql5
// Risque
RiskPerTrade        = 1.0%    // Risque par trade
MaxDailyLoss        = 4.0%    // Limite journalière (marge de sécurité)
MaxTotalLoss        = 8.0%    // Limite totale (marge de sécurité)
MaxPositions        = 1       // Une position à la fois
MaxTradesPerDay     = 3       // Max 3 trades/jour

// Temps
StartHour           = 13      // 13h30 UTC = 9h30 EST (été)
StartMinute         = 30
EndHour             = 18      // 18h00 UTC
EndMinute           = 0
AutoAdjustDST       = true    // Ajustement auto DST

// Stratégie
BreakoutPeriod      = 5       // 5 premières minutes
MinBreakoutPoints   = 30      // 30 points minimum
ATRMultiplierSL     = 2.0     // SL = 2x ATR
ATRMultiplierTP     = 3.0     // TP = 3x ATR
UseVolume           = true    // Confirmation volume

// Gestion
BreakEvenPoints     = 50      // BE après 50 points
TrailingStart       = 100     // Trailing après 100 points
CloseAtEndOfSession = true    // Fermer en fin de session
```

📚 **Guide complet**: Voir [docs/CONFIGURATION.md](docs/CONFIGURATION.md)

---

## 📚 Documentation

- 📘 [**Guide d'installation**](docs/INSTALLATION.md) - Installation pas à pas
- 📗 [**Guide de configuration**](docs/CONFIGURATION.md) - Paramètres détaillés, optimisation, FAQ

### Structure du projet

```
ea-funding-crusher/
├── MQL5/
│   ├── Experts/
│   │   └── DJ30_FundingCrusher.mq5      # EA principal
│   └── Include/
│       └── FundingCrusher/
│           ├── RiskManager.mqh           # Gestion du risque
│           ├── TimeFilter.mqh            # Filtre temporel
│           └── TradeManager.mqh          # Gestion des trades
├── docs/
│   ├── INSTALLATION.md                   # Guide d'installation
│   └── CONFIGURATION.md                  # Guide de configuration
├── LICENSE
└── README.md
```

---

## 📊 Résultats obtenus

### 🚀 Configuration ULTIME - Profit Factor 2.64 (Swing Trading)

**Période testée** : Jan 1 - Nov 1, 2025 (10 MOIS)

| Métrique | Résultat | FTMO | Status |
|----------|----------|------|--------|
| **Profit Factor** | **2.64** 🏆🏆 | > 1.0 | ✅ EXCEPTIONNEL |
| **ROI Net (1.5% risque)** | **+22.30%** (10 mois) | - | ✅ EXCELLENT |
| **ROI Annualisé** | **~26.76%** | - | ✅ EXCELLENT |
| **ROI Mensuel** | **~2.23%** | - | ✅ STABLE |
| **Drawdown Max** | **3.92%** | < 10% | ✅ |
| **Sharpe Ratio** | **19.87** | - | ✅ EXTRAORDINAIRE |
| **Recovery Factor** | **4.09** | - | ✅ |
| **Total Trades** | **71** (~7/mois) | - | ✅ Ultra-sélectif |

**Configuration utilisée (Swing Trading)** :
- `BreakoutPeriod = 34` (range optimal)
- `MinBreakoutPoints = 4025` (filtre ultra-strict)
- `ATRMultiplierSL = 4.2` (SL large swing)
- `ATRMultiplierTP = 7.8` (TP très éloigné)
- `ATRPeriod = 138` (ATR long terme)
- `BreakEvenPoints = 290` (protection active)
- `TrailingStart = 980` (ultra-tardif)
- `CloseAtEndOfSession = false` (positions overnight)

📁 **Preset recommandé** : `MQL5/Presets/FTMO_SwingTrading_PF264_OPTIMAL.set`

### 🎯 Deux stratégies disponibles

| Critère | Swing Trading (v1.5) | Day Trading (v1.4) |
|---------|---------------------|-------------------|
| **Preset** | `FTMO_SwingTrading_PF264_OPTIMAL.set` | `FTMO_DayTrading_PF174.set` |
| **Profit Factor** | **2.64** 🏆 | 1.74 |
| **Trades/mois** | ~7 (ultra-sélectif) | ~44 (actif) |
| **ROI Mensuel** | 2.23% (stable) | ~4.3% (variable) |
| **Drawdown** | 3.92% (10 mois) | 1.85% (6 sem) |
| **Sharpe** | 19.87 | N/A |
| **Robustesse** | ✅ Validé 10 mois | ⚠️ Fragile cross-période |
| **FTMO Phase 1** | ⚠️ Difficile (2.2%/mois) | ✅ Possible (4.3%/mois) |
| **FTMO Phase 2** | ✅ IDÉAL (4.5% en 60j) | ✅ OK |
| **Comptes Fundés** | ✅ OPTIMAL (26% annuel) | ✅ Bon |
| **Temps écran** | Faible | Élevé |
| **Stress** | Faible | Élevé |

### 💡 Recommandations par objectif

**Pour FTMO Phase 1 (10% en 30 jours)** :
- ⚠️ **Objectif agressif**, difficile avec swing trading
- **Recommandation** : Utiliser `FTMO_DayTrading_PF174.set`
- Configurer `RiskPerTrade = 2.0%`
- Profit projeté : ~8-12%/mois
- Drawdown estimé : ~3.7%

**Pour FTMO Phase 2 (5% en 60 jours)** :
- ✅ **IDÉAL** avec swing trading
- **Recommandation** : Utiliser `FTMO_SwingTrading_PF264_OPTIMAL.set`
- Garder `RiskPerTrade = 1.5%`
- Profit projeté : ~4.5% en 60 jours
- Drawdown estimé : ~3.92%

**Pour comptes fundés** :
- 🏆 **OPTIMAL** avec swing trading
- **Recommandation** : Utiliser `FTMO_SwingTrading_PF264_OPTIMAL.set`
- Garder `RiskPerTrade = 1.5%`
- ROI annuel projeté : ~26.76%
- Sharpe 19.87 = excellent rendement/risque

### 🔍 Évolution de l'optimisation

Parcours complet pour atteindre la configuration ultime :

| Version | Type | PF | ROI/mois | DD | Robustesse |
|---------|------|----|----|----|----|
| v1.0 (Baseline) | Day | 1.01 | 0.23% | 3.94% | ⚠️ Faible |
| v1.3 | Day | 1.33 | 2.79% | 1.87% | ⚠️ Moyen |
| v1.4 | Day | 1.74 | 4.3% | 1.85% | ⚠️ Fragile |
| **v1.5** | **Swing** | **2.64** | **2.23%** | **3.92%** | ✅ **Validé 10 mois** |

**Découvertes clés** :
1. **Optimisation multi-période** (Sept+Oct+Nov) → élimine sur-optimisation
2. **Swing > Day** pour robustesse → PF 2.64 stable sur 10 mois
3. **Qualité > Quantité** → 7 trades/mois meilleur que 44 trades/mois
4. **ATR long terme (138)** → filtre optimal trouvé par algorithme MT5
5. **Filtrage ultra-strict (4025 pts)** → capture uniquement vrais breakouts majeurs

⚠️ **Disclaimer**: Les performances passées ne garantissent pas les résultats futurs.

---

## 🛠️ Développement

### Technologies

- **MQL5**: Langage de programmation MetaTrader 5
- **MetaEditor**: IDE pour développement
- **Git**: Gestion de version

### Architecture

- **Modularité**: Classes séparées pour chaque fonctionnalité
- **Réutilisabilité**: Classes utilisables dans d'autres EAs
- **Maintenabilité**: Code commenté et structuré
- **Performance**: Optimisé pour exécution en temps réel

---

## ⚠️ Avertissement

### Risques

- ❗ Le trading comporte des **risques de perte en capital**
- ❗ Les performances passées ne garantissent **pas** les résultats futurs
- ❗ Utilisez cet EA **à vos propres risques**
- ❗ Cet EA est fourni à titre **éducatif**

### Recommandations

- ✅ **Testez TOUJOURS sur compte démo** avant compte réel
- ✅ **Comprenez la stratégie** avant d'utiliser l'EA
- ✅ **Respectez les règles** de votre propfirm
- ✅ **Surveillez régulièrement** les performances
- ✅ **Utilisez un VPS** pour éviter les interruptions
- ✅ **Adaptez les paramètres** à votre style

### Support

- 🐛 **Bugs**: Ouvrir une issue sur GitHub
- 💬 **Questions**: Consulter la documentation
- 📧 **Contact**: Via GitHub Issues

---

## 📄 License

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🙏 Contributions

Les contributions sont les bienvenues! N'hésitez pas à:

- 🐛 Signaler des bugs
- 💡 Proposer des améliorations
- 📝 Améliorer la documentation
- 🔧 Soumettre des pull requests

---

## 📈 Roadmap

### Version 1.0 (Actuelle)
- ✅ Stratégie de breakout à l'ouverture US
- ✅ Risk management pour propfirms
- ✅ Break-even et trailing stop
- ✅ Ajustement automatique DST

### Version 1.1 (À venir)
- 🔄 Filtre de news économiques
- 🔄 Multi-symboles (NAS100, S&P500)
- 🔄 Dashboard visuel sur graphique
- 🔄 Notifications Telegram

### Version 2.0 (Futur)
- 🔮 Machine Learning pour optimisation
- 🔮 Gestion multi-phases (Phase 1/2/Funded)
- 🔮 Backtesting automatisé
- 🔮 API pour monitoring externe

---

## 📞 Contact

- **GitHub**: https://github.com/fred-selest/ea-funding-crusher
- **Issues**: https://github.com/fred-selest/ea-funding-crusher/issues

---

<div align="center">

**⭐ Si ce projet vous a aidé, n'oubliez pas de lui donner une étoile! ⭐**

Made with ❤️ for the trading community

</div>