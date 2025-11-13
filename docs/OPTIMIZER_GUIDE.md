# 🔧 Guide d'Optimisation Automatique MT5

## 📊 Contexte

Après de nombreux tests manuels, le meilleur résultat obtenu est :
- **Profit Factor : 1.01** (+0.23% sur 6 semaines)
- **Win Rate : 67%**
- **Drawdown : 3.94%**

Pour atteindre **PF > 1.5** (requis pour FTMO), l'optimisation automatique est nécessaire.

---

## 🚀 Guide pas à pas - Optimiseur MT5

### Étape 1 : Ouvrir l'optimiseur

1. **Strategy Tester** (Ctrl+R)
2. Sélectionner l'EA : `DJ30_FundingCrusher`
3. Symbole : `US30.cash` (ou votre symbole DJ30)
4. Période : **M5**
5. **Mode** : Sélectionner **"Optimization"** (au lieu de "Single run")

### Étape 2 : Configurer la période

- **From** : 2025.10.01
- **To** : 2025.11.12
- **Forward** : Désactivé (pour l'instant)

### Étape 3 : Sélectionner les paramètres à optimiser

Dans l'onglet **"Settings"**, pour chaque paramètre :

#### Paramètres FIXES (ne PAS optimiser)

```
RiskPerTrade = 1.0          (ne pas cocher "Optimize")
MaxDailyLoss = 4.0          (ne pas cocher)
MaxTotalLoss = 8.0          (ne pas cocher)
MaxPositions = 1            (ne pas cocher)
MaxTradesPerDay = 3         (ne pas cocher)
StartHour = 13              (ne pas cocher)
StartMinute = 30            (ne pas cocher)
EndHour = 18                (ne pas cocher)
EndMinute = 0               (ne pas cocher)
AutoAdjustDST = 1           (ne pas cocher)
ATRPeriod = 14              (ne pas cocher)
MagicNumber = 202411        (ne pas cocher)
```

#### Paramètres à OPTIMISER (cocher "Optimize")

**1. MinBreakoutPoints** ✅
```
☑ Optimize
Value : 1000
Start : 1000
Step  : 500
Stop  : 10000
```

**2. ATRMultiplierSL** ✅
```
☑ Optimize
Value : 1.5
Start : 1.5
Step  : 0.5
Stop  : 3.0
```

**3. ATRMultiplierTP** ✅
```
☑ Optimize
Value : 2.0
Start : 2.0
Step  : 0.5
Stop  : 6.0
```

**4. BreakoutPeriod** ✅
```
☑ Optimize
Value : 5
Start : 3
Step  : 1
Stop  : 10
```

**5. BreakEvenPoints** ✅
```
☑ Optimize
Value : 0
Start : 0
Step  : 25
Stop  : 100
```

**6. TrailingStart** ✅
```
☑ Optimize
Value : 0
Start : 0
Step  : 50
Stop  : 200
```

**7. UseVolume** ✅
```
☑ Optimize
Value : 0
Start : 0
Step  : 1
Stop  : 1
```

**8. CloseAtEndOfSession** ✅
```
☑ Optimize
Value : 0
Start : 0
Step  : 1
Stop  : 1
```

### Étape 4 : Critère d'optimisation

Dans **"Optimization"** :
- **Criterion** : Sélectionner **"Profit Factor"** (ou "Custom max")
- **Optimization method** : **"Complete Algorithm"** (si temps disponible) ou **"Genetic Algorithm"** (plus rapide)

### Étape 5 : Contraintes (optionnel mais recommandé)

Si MT5 le permet, ajouter des contraintes :
- **Max Drawdown** < 10%
- **Total Trades** > 30
- **Win Rate** > 30%

### Étape 6 : Lancer l'optimisation

1. **Vérifier** que tous les paramètres sont corrects
2. **Start** (bouton en bas à droite)
3. **Attendre** 10-30 minutes (selon la puissance de votre PC)

### Étape 7 : Analyser les résultats

Une fois terminé, onglet **"Optimization Results"** :

1. **Trier par Profit Factor** (cliquer sur la colonne)
2. **Sélectionner** la ligne avec le meilleur PF
3. **Vérifier** :
   - ✅ Profit Factor > 1.5
   - ✅ Drawdown < 10%
   - ✅ Total Trades > 30
   - ✅ Win Rate > 30% (ou Ratio Win/Loss > 2.5)

4. **Double-cliquer** sur la ligne → Les paramètres sont appliqués
5. **Relancer un backtest simple** pour vérifier

### Étape 8 : Forward Testing

**IMPORTANT** : Ne jamais utiliser des paramètres optimisés sans forward test !

1. **Changer la période** : 2025.11.13 - 2025.12.31 (ou une autre période)
2. **Lancer** un backtest simple avec les paramètres optimisés
3. **Vérifier** que le PF reste > 1.3 minimum

Si le PF s'effondre en forward test → Les paramètres sont **sur-optimisés**.

---

## 📋 Exemple de résultat attendu

### Avant optimisation
```
MinBreakoutPoints = 60
ATRMultiplierSL = 2.5
ATRMultiplierTP = 5.0
→ Profit Factor = 1.01
```

### Après optimisation (exemple)
```
MinBreakoutPoints = 3500
ATRMultiplierSL = 2.0
ATRMultiplierTP = 3.5
BreakEvenPoints = 50
TrailingStart = 100
→ Profit Factor = 1.78 ✅
```

---

## ⚠️ Pièges à éviter

### 1. Sur-optimisation

**Symptôme** : PF = 3.5 sur le backtest, mais 0.8 en forward test

**Cause** : Paramètres trop spécifiques à une période

**Solution** :
- Limiter le nombre de paramètres optimisés (max 5-6)
- Toujours faire un forward test
- Préférer des valeurs "rondes" (50, 100, 2.0, 3.0)

### 2. Trop peu de trades

**Symptôme** : PF = 2.0 mais seulement 15 trades

**Cause** : Variance statistique élevée

**Solution** : Rejeter les résultats avec < 30 trades

### 3. Drawdown trop élevé

**Symptôme** : PF = 2.0 mais Drawdown = 15%

**Cause** : Paramètres trop agressifs

**Solution** : Ajouter une contrainte sur le drawdown max

---

## 🎯 Checklist post-optimisation

Avant d'utiliser les paramètres optimisés :

- [ ] Profit Factor > 1.5 sur backtest
- [ ] Profit Factor > 1.3 sur forward test
- [ ] Drawdown < 10% (les deux périodes)
- [ ] Minimum 30 trades (les deux périodes)
- [ ] Win Rate cohérent entre backtest et forward (±10%)
- [ ] Paramètres "raisonnables" (pas de valeurs extrêmes)
- [ ] Test sur compte démo 1 semaine minimum

---

## 💡 Conseils pratiques

### Optimisation rapide (30 min)

Optimiser seulement 3 paramètres :
- MinBreakoutPoints
- ATRMultiplierSL
- ATRMultiplierTP

### Optimisation complète (2-3h)

Optimiser tous les 8 paramètres listés ci-dessus.

### Si l'optimisation échoue

Si aucun résultat n'atteint PF > 1.5 :

1. **Tester une période différente** (Sept-Oct au lieu d'Oct-Nov)
2. **Revoir la stratégie** (peut-être que le breakout simple ne fonctionne pas sur DJ30)
3. **Considérer un autre symbole** (NAS100, S&P500)
4. **Ajouter des filtres** (ADX, volatilité, etc.)

---

## 📞 Support

Des questions sur l'optimisation ?
- Consultez la doc MT5 : https://www.mql5.com/en/docs/trading_optimization
- GitHub Issues du projet

---

## ⚡ Quick Start

**Pour démarrer rapidement** :

1. Strategy Tester → Mode "Optimization"
2. Cocher "Optimize" sur : MinBreakoutPoints, ATRMultiplierSL, ATRMultiplierTP
3. Criterion : "Profit Factor"
4. Start
5. Sélectionner le meilleur résultat
6. Forward test sur période différente

**Bonne optimisation ! 🚀**
