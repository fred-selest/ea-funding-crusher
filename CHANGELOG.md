# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

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
