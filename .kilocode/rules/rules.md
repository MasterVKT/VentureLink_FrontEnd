# 🤖 Règles KiloCode - Agent AI VentureLink
*Règles spécifiques pour KiloCode et autres agents AI non-Copilot*

**Dernière mise à jour:** 17 Janvier 2026  
**Version:** 2.0

> ⚠️ **IMPORTANT:** Pour les directives complètes et consolidées, consultez `.github/copilot-instructions.md`
> Ce fichier contient les règles KiloCode spécifiques. Voir le fichier GitHub Copilot pour la version complète unifiée.

---

## 🎯 Règles Fondamentales Prioritaires

### 1. Vérification Pré-Actions
✅ **OBLIGATOIRE avant chaque réponse ou action:**

- Vérifier la conformité avec le **plan de développement** (`doc_frontEnd/Plan_Dev_Frontend_VentureLink.txt`)
- Vérifier la conformité avec les **spécifications projet** dans:
  - `doc_frontEnd/Architecture_FrontEnd_VentureLink.txt`
  - `doc_frontEnd/Charte_Graphique_VentureLink.txt`
  - `doc_frontEnd/Contrats_API_RESTFul_VentureLink.txt`
  - `doc_frontEnd/Conventions_et_Standards_VentureLink.txt`
  - `doc_frontEnd/doc_UI_VentureLink.txt`
  - `doc_frontEnd/Documentation_des_Services_Firebase_VentureLink.txt`
  - `doc_frontEnd/Flux_Intégration_VentureLink.txt`
  - `doc_frontEnd/Format_Données_Echangees_VentureLink.txt`
  - `contrat/GUIDE_HARMONISATION_FRONTEND_BACKEND_VENTURELINK_PHASE5_FINAL.md`
  - `contrat/MODELES_DONNEES_BACKEND_VENTURELINK_PHASE5_FINAL.md`

### 2. Complétude Informationnelle
✅ **Avant de répondre ou d'agir:**

- Disposez-vous de **toutes les informations** nécessaires?
- ⚠️ Si non: **Posez les questions nécessaires** avant de procéder
- ✅ Vérifiez la disponibilité des références documentaires

### 3. Synthèse Systématique
✅ **Après chaque action ou réponse significative:**

- 📊 Synthèse claire de ce qui a été fait
- 📋 Liste de ce qui reste à faire
- ⚠️ Identification des blocages potentiels
- 🎯 Prochaines étapes recommandées

### 4. Réduction Modifications Backend
✅ **Prioriser une résolution frontend:**

- 🎯 **Idéal:** Résolution sans modification backend
- ⚠️ Si modifications backend nécessaires:
  - Présentez-les de façon **détaillée, précise et structurée**
  - Justifiez **chaque modification**
  - Évaluez l'impact sur l'architecture globale

### 5. Multidevises Obligatoires
✅ **Pour tous les calculs financiers:**

- 💱 Devise = Préférences/devise utilisateur
- 🌍 Support: EUR, XAF, USD
- 🗣️ I18n: FR et EN
- 📍 Utiliser clés i18n pour tous les textes

### 6. Environnement Python/Pip
✅ **Pour opérations backend:**

- 🐍 **TOUJOURS** utiliser venv du projet
- 🔐 PowerShell: Exécuter d'abord: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process`
- 📦 Installer dans venv, jamais globalement

---

## 📚 Documents de Référence Clés

### My-CoolPay API
- 📄 **Documentation:** `doc_frontEnd/My-CoolPay API Docs.pdf`
- 🔑 **Obligatoire** pour tous les paiements
- 💳 **Plans:** FREE, BASIC_MONTHLY, BASIC_YEARLY, PREMIUM_MONTHLY, PREMIUM_YEARLY

### Documents Critiques Harmonisation
- 📋 `API_CONTRACT.md` - Contrat API frontend-backend
- 🗂️ `DATA_MODELS.md` - Modèles partagés
- 🔌 `ENDPOINTS_REFERENCE.md` - Référence endpoints
- 🔗 `FLUTTER_INTEGRATION_GUIDE.md` - Guide intégration Flutter
- 💰 `Implementation_Paiement_MyCoolPay.md` - Implémentation paiements

---

## 🔗 Référence Vers Règles Complètes

Pour une documentation complète et détaillée, consultez:
**`.github/copilot-instructions.md`**

Ce fichier contient la version unifiée et consolidée de toutes les règles:
- ✅ Conventions et normes techniques
- ✅ Architecture et design patterns
- ✅ Gestion d'état et données
- ✅ Performance et optimisation
- ✅ Sécurité et authentification
- ✅ Qualité du code
- ✅ Best practices VentureLink
- ✅ Checklists de vérification

---

**Version:** 2.0  
**Statut:** ✅ Actif et aligné avec `.github/copilot-instructions.md`
