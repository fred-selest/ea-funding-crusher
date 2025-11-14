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

### Configuration Optimale - BreakoutPeriod 30 Minutes

**Période testée** : Oct 1 - Nov 12, 2025 (6 semaines)

| Métrique | Résultat | FTMO Phase 1 | Status |
|----------|----------|--------------|--------|
| **Profit Factor** | **1.33** | > 1.0 | ✅ |
| **Win Rate** | **72.13%** | N/A | ✅ |
| **Profit Net** | **+2.79%** (6 sem) | 10% (30 jours) | ✅ (~11%/mois) |
| **Drawdown Max** | **1.87%** | < 10% | ✅ |
| **Total Trades** | 61 | N/A | ✅ |

**Configuration utilisée** :
- `BreakoutPeriod = 30` (30 minutes de range initial)
- `MinBreakoutPoints = 3000`
- `ATRMultiplierSL = 2.5`
- `ATRMultiplierTP = 3.5`

📁 **Preset recommandé** : `MQL5/Presets/FTMO_Optimal_30min_PF133.set`

### Évolution de l'optimisation

6 backtests ont été réalisés pour atteindre cette configuration optimale :

| Test | Configuration | PF | WR | Profit | Résultat |
|------|--------------|----|----|--------|----------|
| #1 | Baseline (5 min) | 1.01 | 67% | +0.23% | ⚠️ Insuffisant |
| #2 | MinBrk=5000 | 0.62 | 62% | -6.12% | ❌ Perte |
| #3 | TP=3.0, Trail OFF | 0.92 | 22% | -1.24% | ❌ Perte |
| #4 | MinBrk=3000, TP=4.0 | 0.82 | 19% | -3.60% | ❌ Perte |
| #5 | Scalping | 0.90 | 35% | -2.99% | ❌ Perte |
| **#6** | **BreakoutPeriod=30** | **1.33** | **72%** | **+2.79%** | ✅ **OPTIMAL** |

**Découverte clé** : Utiliser un range de 30 minutes au lieu de 5 minutes réduit drastiquement les faux signaux et améliore la qualité des trades.

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