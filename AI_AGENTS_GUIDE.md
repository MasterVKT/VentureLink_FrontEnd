# 🤖 Guide AI Agents - Règles VentureLink

**Pour tous les agents AI travaillant sur le projet VentureLink**

---

## 🚀 Démarrage Rapide

### Pour GitHub Copilot
1. Lire: [`.github/copilot-instructions.md`](.github/copilot-instructions.md)
2. Consulter les sections pertinentes avant chaque action
3. Suivre les checklists pré-commit
4. **C'est la source de vérité** pour toutes les règles

### Pour KiloCode / Autres Agents
1. Lire: [`.kilocode/rules/rules.md`](.kilocode/rules/rules.md)
2. Pour détails complets: Aller à [`.github/copilot-instructions.md`](.github/copilot-instructions.md)
3. Même checklist pré-commit que GitHub Copilot

---

## 📚 Documents Clés par Domaine

### Architecture & Design
- **Frontend:** `doc_frontEnd/Architecture_FrontEnd_VentureLink.txt`
- **Backend:** `contrat/MODELES_DONNEES_BACKEND_VENTURELINK_PHASE5_FINAL.md`
- **Harmonisation:** `contrat/GUIDE_HARMONISATION_FRONTEND_BACKEND_VENTURELINK_PHASE5_FINAL.md`

### Conventions & Standards
- **Code:** `doc_frontEnd/Conventions_et_Standards_VentureLink.txt`
- **API:** `doc_frontEnd/Contrats_API_RESTFul_VentureLink.txt`
- **UI:** `doc_frontEnd/doc_UI_VentureLink.txt`, `doc_frontEnd/Charte_Graphique_VentureLink.txt`

### Implémentation
- **Plan de dev:** `doc_frontEnd/Plan_Dev_Frontend_VentureLink.txt`
- **Exécution:** `EXECUTION_GUIDE.md`
- **Prompt final:** `PROMPT_IMPLEMENTATION_FRONTEND_FLUTTER_VENTURELINK_FINAL.md`

### Paiements
- **My-CoolPay:** `doc_frontEnd/My-CoolPay API Docs.pdf`
- **Intégration:** `doc_frontEnd/Implementation_Paiement_MyCoolPay.md`

### Data & Formats
- **Modèles:** `doc_frontEnd/DATA_MODELS.md`
- **Endpoints:** `doc_frontEnd/ENDPOINTS_REFERENCE.md`
- **Formats échangés:** `doc_frontEnd/Format_Données_Echangees_VentureLink.txt`

---

## 🎯 Règles Essentielles (Rappel Rapide)

### Avant Chaque Action
- [ ] Vérifier conformité avec plan de développement
- [ ] Vérifier conformité avec spécifications (fichiers de référence)
- [ ] Disposer de toutes les informations nécessaires
- [ ] Poser questions si infos manquantes

### Après Chaque Action
- [ ] Synthèse de ce qui a été fait
- [ ] Liste de ce qui reste à faire
- [ ] Identification des blocages
- [ ] Prochaines étapes recommandées

### Pré-Commit
- [ ] `dart format` appliqué
- [ ] `dart analyze` 0 erreur/warning
- [ ] Tests passent (>80% couverture)
- [ ] Pas d'imports/code mort
- [ ] Documentation complète
- [ ] Conventions de nommage respectées
- [ ] Gestion d'erreurs complète
- [ ] Pas de secrets en dur

---

## 💡 Exemples de Questions & Réponses

### Q: Où trouver les conventions de nommage?
**R:** Section "Conventions et Normes Techniques" dans `.github/copilot-instructions.md`
- API: `/api/v1/projects` (pluriel minuscules)
- Django: `ProjectModel`, `project_owner` (PascalCase classe, snake_case champ)
- Flutter: `ProjectCard` (classe), `projectsList` (variable)

### Q: Comment gérer les devises?
**R:** Section "Best Practices Spécifiques VentureLink" → "Multi-Devises"
- Devises supportées: EUR, XAF, USD
- I18n requis: FR et EN
- Définir devise selon préférences utilisateur

### Q: Quelles technologies Flutter utiliser?
**R:** Section "Architecture Frontend - MVVM"
- Provider pour état
- Dio + Retrofit pour API
- Hive + SharedPreferences pour cache local
- Firebase Auth + Secure Storage

### Q: Comment structurer le code?
**R:** Section "Architecture et Design" → "MVVM"
- Models: `lib/data/models/`
- Services/Repos: `lib/data/services/` + `lib/data/providers/`
- Screens: `lib/presentation/screens/`
- Widgets: `lib/presentation/widgets/`

### Q: Que faire si modification backend nécessaire?
**R:** Section "Règles Fondamentales" → Point 4
1. **Idéal:** Résoudre sans modifier backend
2. **Si nécessaire:** Présenter de façon détaillée, précise, structurée
3. Justifier chaque modification proposée
4. Évaluer impact sur architecture

---

## 🔍 Structure du Repository

```
venturelink/
├── .github/
│   └── copilot-instructions.md  ← RÉFÉRENCE COMPLÈTE
├── .kilocode/
│   └── rules/
│       └── rules.md             ← Référence rapide KiloCode
├── doc_frontEnd/                ← Documents de spécifications
│   ├── Architecture_FrontEnd_VentureLink.txt
│   ├── Conventions_et_Standards_VentureLink.txt
│   ├── Contrats_API_RESTFul_VentureLink.txt
│   ├── Plan_Dev_Frontend_VentureLink.txt
│   ├── My-CoolPay API Docs.pdf
│   └── ...
├── contrat/                     ← Documents d'harmonisation
│   ├── GUIDE_HARMONISATION_FRONTEND_BACKEND_VENTURELINK_PHASE5_FINAL.md
│   ├── MODELES_DONNEES_BACKEND_VENTURELINK_PHASE5_FINAL.md
│   └── ...
├── lib/                         ← Code Frontend Flutter
├── CONSOLIDATION_RULES_AI.md    ← Synthèse consolidation
├── EXECUTION_GUIDE.md           ← Guide exécution pratique
└── ...
```

---

## ⚙️ Processus de Travail

### 1. Avant de Commencer
```
1. Lire la règle pertinente dans copilot-instructions.md
2. Consulter document source si besoin
3. Vérifier plan de développement
4. Identifier toutes les informations nécessaires
5. Poser questions si besoin
```

### 2. Pendant l'Exécution
```
1. Suivre les patterns et conventions
2. Commenter le code complexe
3. Gérer les erreurs proprement
4. Tester régulièrement
5. Vérifier la qualité
```

### 3. Avant le Commit
```
1. Appliquer checklist pré-commit
2. Vérifier format et qualité
3. Documenter les changements
4. Écrire message commit explicite
5. Comparer avec règles une dernière fois
```

---

## 🆘 Aide & Support

### Je suis bloqué
1. ✅ Vérifiez la documentation du projet
2. ✅ Consultez les exemples de code
3. ✅ Vérifiez les logs et stack traces
4. ✅ Relisez la section pertinente dans copilot-instructions.md
5. 📧 Si toujours bloqué: Escalader précisément

### Je trouve une contradiction
1. Documentez exactement quelle est la contradiction
2. Identifiez les documents conflictuels
3. Proposez une résolution
4. Escalader pour mise à jour

### Je veux proposer une amélioration
1. Documentez le changement proposé
2. Justifiez pourquoi c'est une amélioration
3. Vérifiez cohérence avec autres règles
4. Mettez à jour copilot-instructions.md
5. Informez l'équipe

---

## 📊 Matrice de Référence Rapide

| Besoin | Document |
|--------|----------|
| Conventions code | Conventions_et_Standards_VentureLink.txt |
| Architecture Flutter | Architecture_FrontEnd_VentureLink.txt |
| Endpoints API | Contrats_API_RESTFul_VentureLink.txt |
| Modèles données | DATA_MODELS.md |
| Plan de développement | Plan_Dev_Frontend_VentureLink.txt |
| Paiements My-CoolPay | My-CoolPay API Docs.pdf |
| Harmonisation F/B | GUIDE_HARMONISATION_FRONTEND_BACKEND_VENTURELINK_PHASE5_FINAL.md |
| Exécution pratique | EXECUTION_GUIDE.md |
| All Rules | .github/copilot-instructions.md |

---

## 🔐 Sécurité - Points Clés

**JAMAIS FAIRE:**
- ❌ Commiter des secrets (API keys, tokens, passwords)
- ❌ Stocker tokens JWT en SharedPreferences non chiffré
- ❌ Retourner données sensibles en clair
- ❌ Ignorer validations/sanitization
- ❌ Faire requêtes API sans authentification

**TOUJOURS FAIRE:**
- ✅ Utiliser Flutter Secure Storage pour tokens
- ✅ Valider tous les inputs utilisateur
- ✅ Sanitizer les données avant envoi
- ✅ Utiliser HTTPS/WSS seulement
- ✅ Implémenter rate limiting côté app
- ✅ Logger les tentatives suspectes

---

## 📞 Contacts & Escalade

**Questions techniques:**
1. Consulter la documentation du projet
2. Vérifier les exemples de code
3. Si bloqué: Escalader avec détails

**Changements de règles:**
1. Discuter des changements pertinents
2. Mettre à jour copilot-instructions.md
3. Communiquer aux équipes

**Rapports de bugs/issues:**
1. Documenter précisément
2. Fournir code minimal reproduisant
3. Inclure logs et stack traces
4. Référencer document ou règle pertinente

---

**Version:** 1.0  
**Date:** 17 Janvier 2026  
**Statut:** ✅ Actif

*Bienvenue sur VentureLink! Utilisez `.github/copilot-instructions.md` comme votre guide principal.*
