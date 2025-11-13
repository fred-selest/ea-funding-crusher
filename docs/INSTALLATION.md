# 📥 Guide d'Installation - DJ30 Funding Crusher

## Table des matières
- [Prérequis](#prérequis)
- [Installation sur MetaTrader 5](#installation-sur-metatrader-5)
- [Configuration](#configuration)
- [Vérification](#vérification)
- [Dépannage](#dépannage)

---

## Prérequis

### 🖥️ Système
- **OS**: Windows 7 ou supérieur (recommandé: Windows 10/11)
- **MetaTrader 5**: Version Build 3260 ou supérieure
- **Connexion Internet**: Stable et rapide
- **VPS** (recommandé): Pour trading 24/7 avec faible latence

### 📊 Compte de Trading
- **Type de compte**: Compatible avec les propfirms (FTMO, FTUK, The5ers, etc.)
- **Symbole**: DJ30, US30, ou équivalent (Wall Street 30)
- **Balance recommandée**: Minimum $10,000 (phase 1 FTMO)
- **Levier**: 1:100 minimum

---

## Installation sur MetaTrader 5

### Méthode 1: Installation Manuelle (Recommandée)

#### Étape 1: Localiser le dossier de données MT5

1. Ouvrez MetaTrader 5
2. Cliquez sur **Fichier** → **Ouvrir le dossier de données**
3. Une fenêtre de l'explorateur Windows s'ouvre

#### Étape 2: Copier les fichiers

1. **Copier les classes utilitaires**:
   ```
   Copiez le dossier:
   ea-funding-crusher/MQL5/Include/FundingCrusher/

   Vers:
   [Dossier MT5]/MQL5/Include/FundingCrusher/
   ```

   Vous devriez avoir:
   - `MQL5/Include/FundingCrusher/RiskManager.mqh`
   - `MQL5/Include/FundingCrusher/TimeFilter.mqh`
   - `MQL5/Include/FundingCrusher/TradeManager.mqh`

2. **Copier l'Expert Advisor**:
   ```
   Copiez le fichier:
   ea-funding-crusher/MQL5/Experts/DJ30_FundingCrusher.mq5

   Vers:
   [Dossier MT5]/MQL5/Experts/DJ30_FundingCrusher.mq5
   ```

#### Étape 3: Compiler l'EA

1. Dans MT5, ouvrez **MetaEditor** (F4 ou icône dans la barre d'outils)
2. Dans le navigateur de MetaEditor, trouvez: `Experts/DJ30_FundingCrusher.mq5`
3. Double-cliquez pour ouvrir le fichier
4. Cliquez sur **Compiler** (F7) ou icône "Compiler"
5. Vérifiez qu'il n'y a **aucune erreur** dans l'onglet "Boîte à outils"
6. Vous devriez voir: `0 error(s), 0 warning(s)`

### Méthode 2: Installation via MetaEditor

1. Ouvrez MetaEditor dans MT5
2. Créez les dossiers nécessaires dans l'arborescence
3. Copiez-collez le contenu de chaque fichier manuellement
4. Compilez l'EA

---

## Configuration

### 🎯 Configuration pour FTMO (Phase 1)

#### Paramètres de Risque Recommandés

```
═══════ Gestion du Risque ═══════
RiskPerTrade        = 1.0%      // Risque conservateur
MaxDailyLoss        = 4.0%      // Marge de sécurité (limite FTMO: 5%)
MaxTotalLoss        = 8.0%      // Marge de sécurité (limite FTMO: 10%)
MaxPositions        = 1         // Une position à la fois
MaxTradesPerDay     = 3         // Maximum 3 trades/jour
```

#### Configuration du Temps

```
═══════ Filtre Temporel ═══════
StartHour           = 13        // 13h30 UTC = 9h30 EST (été)
StartMinute         = 30
EndHour             = 18        // 18h00 UTC = 14h00 EST
EndMinute           = 0
AutoAdjustDST       = true      // Ajustement automatique heure d'été/hiver
```

#### Stratégie

```
═══════ Stratégie de Trading ═══════
BreakoutPeriod      = 5         // 5 premières minutes d'ouverture
MinBreakoutPoints   = 50        // Breakout minimum 50 points
ATRMultiplierSL     = 2.0       // Stop loss = 2x ATR
ATRMultiplierTP     = 3.0       // Take profit = 3x ATR
ATRPeriod           = 14        // Période ATR standard
UseVolume           = true      // Confirmation par volume
```

#### Gestion des Positions

```
═══════ Gestion des Positions ═══════
BreakEvenPoints     = 50        // Break-even après 50 points
BreakEvenProfit     = 10        // Laisser 10 points de profit
TrailingStart       = 100       // Trailing après 100 points
TrailingStep        = 20        // Trailing par pas de 20 points
CloseAtEndOfSession = true      // Fermer positions en fin de session
```

### 🎯 Configuration pour FTMO (Phase 2)

Pour la phase 2, utilisez les mêmes paramètres mais soyez encore plus conservateur:

```
RiskPerTrade        = 0.5%      // Risque très conservateur
MaxDailyLoss        = 3.0%      // Marge de sécurité importante
MaxTradesPerDay     = 2         // Maximum 2 trades/jour
```

---

## Vérification

### ✅ Checklist avant le premier trade

- [ ] L'EA est compilé sans erreur
- [ ] L'EA est attaché au graphique US30/DJ30 M5
- [ ] Le trading automatique est activé (bouton "AutoTrading")
- [ ] Le symbole correspond (US30, DJ30, ou équivalent)
- [ ] Les paramètres de risque sont configurés
- [ ] L'horaire de trading est correct (vérifier fuseau horaire du broker)
- [ ] Le Magic Number est unique (si vous utilisez plusieurs EAs)
- [ ] Les positions maximales sont définies
- [ ] Le journal montre l'initialisation réussie

### 📊 Test sur compte démo

**IMPORTANT**: Testez TOUJOURS sur un compte démo avant d'utiliser sur un compte de challenge!

1. **Test pendant 1 semaine** minimum sur démo
2. Vérifiez que:
   - Les trades s'ouvrent aux bons moments
   - Le risk management fonctionne correctement
   - Le break-even et trailing stop sont actifs
   - Les positions se ferment en fin de session
3. Analysez les résultats avant de passer au challenge

---

## Dépannage

### ❌ Problèmes courants

#### L'EA ne compile pas

**Erreur**: `cannot open 'FundingCrusher/RiskManager.mqh'`

**Solution**:
1. Vérifiez que le dossier `MQL5/Include/FundingCrusher/` existe
2. Vérifiez que tous les fichiers .mqh sont présents
3. Redémarrez MetaEditor
4. Recompilez

#### L'EA ne prend aucun trade

**Vérifications**:
1. Le trading automatique est-il activé?
2. Êtes-vous dans la plage horaire de trading?
3. Y a-t-il déjà des positions ouvertes (vérifier MaxPositions)?
4. Le compte a-t-il atteint les limites de perte?
5. Vérifiez le journal MT5 pour les messages

#### L'EA ouvre trop de positions

**Solutions**:
1. Réduisez `MaxPositions` à 1
2. Réduisez `MaxTradesPerDay`
3. Augmentez `MinBreakoutPoints` pour filtrer les faux signaux

#### Les trades sont fermés trop tôt

**Solutions**:
1. Désactivez `CloseAtEndOfSession` si vous voulez garder les positions overnight
2. Augmentez `BreakEvenPoints` pour laisser plus de marge
3. Augmentez `TrailingStep` pour un trailing moins agressif

#### Erreur "Trade context is busy"

**Solution**:
1. Augmentez le slippage
2. Vérifiez votre connexion Internet
3. Évitez de trader pendant les news majeures

### 📝 Journalisation

L'EA affiche des messages clairs dans le journal MT5:

- ✅ Succès (fond vert)
- ⚠️ Avertissements (fond jaune)
- ❌ Erreurs (fond rouge)
- 📊 Statistiques
- 🕐 Informations temporelles

Pour voir le journal:
1. Onglet "Boîte à outils" en bas de MT5
2. Onglet "Journal"
3. Filtrer par EA si nécessaire

---

## Support et Contact

- **GitHub**: https://github.com/fred-selest/ea-funding-crusher
- **Issues**: Reportez les bugs via GitHub Issues
- **Documentation**: Consultez `docs/CONFIGURATION.md` pour plus de détails

---

## ⚠️ Avertissement

**IMPORTANT**:
- Cet EA est fourni à titre éducatif
- Testez TOUJOURS sur démo avant d'utiliser sur compte réel
- Le trading comporte des risques de perte
- Les performances passées ne garantissent pas les résultats futurs
- Utilisez à vos propres risques

**Recommandations**:
- Utilisez un VPS pour éviter les coupures de connexion
- Surveillez régulièrement l'EA pendant les premières semaines
- Adaptez les paramètres selon votre style de trading
- Respectez les règles de votre propfirm
