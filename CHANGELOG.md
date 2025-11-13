# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [1.2.0] - 2025-11-13

### 🚨 CORRECTIF CRITIQUE - Calcul du Lot Size

#### Problème découvert en backtest
**CATASTROPHIQUE**: Le calcul du lot size produisait des tailles démesurées (66.31 lots sur un compte de 100k$), causant des pertes de plus de 100% du compte sur un seul trade.

**Exemple du bug**:
- Compte: 100,000$
- Risque configuré: 1% = 1,000$
- Lot calculé: **66.31 lots** (au lieu de ~0.5 lots)
- Perte réelle: **-110,605$** (110% du compte!)
- Cause: Formule de calcul incorrecte pour les CFDs sur indices

#### Solution implémentée

**Nouvelle fonction `CalculateLotSize()` dans RiskManager.mqh**:

1. **Calcul correct de la valeur par point**:
   ```mql5
   valuePerPoint = (tickValue / tickSize) × point
   ```
   - Gère correctement les spécifications US30/DJ30
   - Valeur par défaut: 100$ par point par lot (typique pour US30 CFD)

2. **Vérifications multicouches**:
   - ✅ Calcul de la perte maximale théorique avant ouverture
   - ✅ Si perte possible > 2× risque prévu → réduction automatique de 50%
   - ✅ Si perte possible > 5% compte → **REFUSE le trade**
   - ✅ Logging détaillé de tous les calculs

3. **Informations du symbole**:
   - Récupération: `tickSize`, `tickValue`, `contractSize`, `point`
   - Affichage dans les logs pour debugging
   - Détection automatique des valeurs aberrantes

4. **Logs améliorés**:
   ```
   📊 Infos symbole: TickSize=X TickValue=Y ContractSize=Z Point=W
   📐 Valeur par point (1 lot): 100.00$
   🔢 Lot calculé brut: 0.5000
   🛡️ Perte max théorique: 1000.00$ (1.00%)
   ✅ Lot final: 0.50 | Risque: 1000.00$ | SL: 20.0 points
   ```

#### Impact
- **AVANT**: Risque de ruine du compte en 1 trade
- **APRÈS**: Risque strictement limité à 1-5% max du compte
- **CRITIQUE**: Cette mise à jour est **OBLIGATOIRE** avant tout trading réel

---

## [1.1.0] - 2025-11-13

### 🐛 Corrections critiques

#### Problème de détection du breakout (Bug majeur)
**Symptôme**: L'EA ne prenait aucun trade malgré des conditions de marché favorables.

**Cause**: La fonction `UpdateSessionHighLow()` mettait à jour continuellement le high/low de session avec chaque nouvelle bougie. Résultat: le prix ne pouvait jamais "casser" un niveau qui venait d'être mis à jour avec la dernière bougie elle-même.

**Solution**:
- Fixation du range de session après les X premières minutes (défini par `BreakoutPeriod`)
- Le high/low n'est plus mis à jour après cette période initiale
- Ajout d'un compteur de barres (`g_barsInSession`) pour contrôler la période d'initialisation
- Message de confirmation quand le range est fixé

### ✨ Améliorations

#### Logging amélioré
- Ajout de logs détaillés pour chaque étape de détection du breakout:
  - Détection initiale du breakout (potentiel BUY/SELL)
  - Validation de la taille du breakout
  - Confirmation du volume
  - Messages de rejet avec raisons spécifiques

#### Optimisation des paramètres
- Réduction de `MinBreakoutPoints` de 50 à 30 points par défaut
  - Plus de signaux potentiels
  - Meilleure capture des mouvements sur DJ30/US30
  - Toujours assez restrictif pour éviter les faux signaux

### 🔧 Changements techniques

**Nouvelles variables globales**:
```mql5
datetime g_sessionStartTime = 0;  // Heure de début de session
int g_barsInSession = 0;          // Compteur de barres depuis le début de session
```

**Logique modifiée**:
- `InitializeSession()`: Initialise maintenant avec la première bougie et démarre le compteur
- `OnTick()`: Logique conditionnelle pour ne mettre à jour le range que pendant `BreakoutPeriod` barres
- `CheckForTradingOpportunity()`: Ajout de logs informatifs à chaque étape

### 📝 Documentation mise à jour
- README.md: Mise à jour de `MinBreakoutPoints` à 30
- Presets: Mise à jour des configurations prédéfinies
- Ajout de ce CHANGELOG

---

## [1.0.0] - 2025-11-12

### ✨ Version initiale

#### Fonctionnalités principales
- Stratégie de breakout à l'ouverture du marché US (9h30 EST)
- Risk management strict conforme aux règles FTMO
- Break-even et trailing stop automatiques
- Ajustement automatique DST (heure d'été/hiver US)
- Calcul automatique de la taille du lot basé sur le risque

#### Composants
- **DJ30_FundingCrusher.mq5**: EA principal
- **RiskManager.mqh**: Gestion du risque pour propfirms
- **TimeFilter.mqh**: Filtre temporel avec ajustement DST
- **TradeManager.mqh**: Gestion des positions, BE, trailing stop

#### Documentation
- Guide d'installation complet
- Guide de configuration détaillé avec FAQ
- Configurations prédéfinies pour FTMO Phase 1 & 2

---

## Types de changements
- `✨ Ajouté` : pour les nouvelles fonctionnalités
- `🔧 Modifié` : pour les changements dans les fonctionnalités existantes
- `⚠️  Déprécié` : pour les fonctionnalités bientôt supprimées
- `🗑️  Supprimé` : pour les fonctionnalités supprimées
- `🐛 Corrigé` : pour les corrections de bugs
- `🔒 Sécurité` : en cas de vulnérabilités
