# Analyse Hiérarchique et Ergonomique - Page de Création de Projet VentureLink

## 1. Structure Hiérarchique Complète

### 1.1 Architecture Générale
```
ProjectCreateScreen
├── Scaffold
│   ├── backgroundColor: DesignConstants.lightGrey
│   ├── VLAppBar
│   │   ├── title: appLocalizations.create
│   │   ├── automaticallyImplyLeading: true
│   │   ├── showLanguageButton: true
│   │   └── onNotificationTap → NotificationsRoute
│   │
│   ├── body: SingleChildScrollView
│   │   └── padding: EdgeInsets.all(paddingMedium)
│   │       └── Form (key: _formKey)
│   │           └── Column (crossAxisAlignment: start)
│   │               ├── Section Introduction
│   │               ├── VLCard - Informations de base
│   │               ├── VLCard - Description détaillée
│   │               ├── VLCard - Financement et partenaires
│   │               ├── VLCard - Tags et catégorisation
│   │               ├── Section Boutons d'action
│   │               └── Container Premium Note
│   │
│   └── VLBottomNavBar
│       ├── currentIndex: 2 (création)
│       └── onTap: _onNavBarTap → Navigation routes
```

### 1.2 Section Introduction
```
Introduction
├── Text "Partagez votre projet avec la communauté"
│   └── style: fontSize titleSmall, fontWeight semiBold
├── SizedBox(height: 8)
├── Text descriptif
│   └── style: bodyMedium, color darkGrey
└── SizedBox(height: 24)
```

### 1.3 VLCard - Informations de Base
```
VLCard (padding: paddingLarge)
├── Text "Informations de base" (titre section)
├── SizedBox(height: 16)
├── VLTextField - Titre du projet
│   ├── label: "Titre du projet"
│   ├── hintText: "Ex: Application mobile..."
│   ├── controller: _titleController
│   └── validator: requis + longueur
├── SizedBox(height: 16)
├── VLTextField - Description courte
│   ├── label: "Description courte"
│   ├── maxLines: 2
│   ├── controller: _shortDescriptionController
│   └── validator: requis + max 200 caractères
├── SizedBox(height: 16)
├── Dropdown - Secteur d'activité
│   ├── Text label
│   ├── Container (decoration + padding)
│   └── DropdownButton<String>
│       ├── value: _selectedSector
│       ├── isExpanded: true
│       ├── items: _sectors (10 options)
│       └── onChanged: setState
├── SizedBox(height: 16)
└── Dropdown - Stade du projet
    ├── Text label
    ├── Container (decoration + padding)
    └── DropdownButton<String>
        ├── value: _selectedStage
        ├── items: _stages (4 options)
        └── onChanged: setState
```

### 1.4 VLCard - Description Détaillée
```
VLCard (padding: paddingLarge)
├── Text "Description détaillée" (titre section)
├── SizedBox(height: 16)
└── VLTextField - Description complète
    ├── label: "Description complète du projet"
    ├── hintText: "Décrivez en détail..."
    ├── maxLines: 8
    ├── controller: _detailedDescriptionController
    └── validator: requis
```

### 1.5 VLCard - Financement et Partenaires
```
VLCard (padding: paddingLarge)
├── Text "Financement et partenaires" (titre section)
├── SizedBox(height: 16)
├── VLTextField - Fourchette de financement
│   ├── label: "Fourchette de financement recherché"
│   ├── hintText: "Ex: 50K - 100K €"
│   ├── controller: _fundingRangeController
│   └── validator: requis
├── SizedBox(height: 16)
├── Section Types de partenaires
│   ├── Text label
│   ├── SizedBox(height: 8)
│   └── Wrap (spacing: 8, runSpacing: 8)
│       └── FilterChip[] pour _partnerTypes (3 options)
│           ├── label: Text(type)
│           ├── selected: isSelected
│           ├── onSelected: setState
│           ├── backgroundColor: lightGrey
│           ├── selectedColor: primaryBlue.withOpacity(0.2)
│           └── labelStyle: couleur conditionnelle
├── SizedBox(height: 16)
└── Section Compétences recherchées
    ├── Text label
    ├── SizedBox(height: 8)
    └── Wrap (spacing: 8, runSpacing: 8)
        └── FilterChip[] pour _skills (10 options)
            └── [même structure que partenaires]
```

### 1.6 VLCard - Tags et Catégorisation
```
VLCard (padding: paddingLarge)
├── Text "Tags et catégorisation" (titre section)
├── SizedBox(height: 16)
└── VLTextField - Tags
    ├── label: "Tags (séparés par des virgules)"
    ├── hintText: "Ex: innovation, écologie, mobile"
    └── controller: _tagsController
```

### 1.7 Section Boutons d'Action
```
Column (crossAxisAlignment: stretch)
├── VLButton - Sauvegarder comme brouillon
│   ├── text: appLocalizations.saveAsDraft
│   ├── onPressed: TODO message SnackBar
│   ├── type: VLButtonType.secondary
│   └── isFullWidth: true
├── SizedBox(height: 12)
└── VLButton - Publier le projet
    ├── text: appLocalizations.publishProject
    ├── onPressed: _submitProject
    ├── isLoading: _isLoading
    └── isFullWidth: true
```

### 1.8 Container Premium Note
```
Container (note Premium)
├── padding: EdgeInsets.all(paddingMedium)
├── decoration: BoxDecoration
│   ├── color: Color(0xFFFFD700).withOpacity(0.1)
│   ├── borderRadius: BorderRadius.circular(radiusSmall)
│   └── border: Border.all (couleur or)
└── Column
    ├── Row
    │   ├── Icon(Icons.star) - couleur or
    │   ├── SizedBox(width: 12)
    │   └── Text "Premium" - style bold + couleur or
    ├── SizedBox(height: 8)
    └── Text descriptif Premium
```

## 2. Flux de Données et Navigation

### 2.1 Contrôleurs de Formulaire
```dart
final TextEditingController _titleController
final TextEditingController _shortDescriptionController
final TextEditingController _detailedDescriptionController
final TextEditingController _fundingRangeController
final TextEditingController _tagsController
```

### 2.2 État Local
```dart
String _selectedSector = 'Technologie'
String _selectedStage = 'Idée'
List<String> _selectedPartnerTypes = []
List<String> _selectedSkills = []
bool _isLoading = false
int _currentIndex = 2
```

### 2.3 Données Statiques
```dart
List<String> _sectors (10 secteurs)
List<String> _stages (4 stades)
List<String> _partnerTypes (3 types)
List<String> _skills (10 compétences)
```

### 2.4 Flux de Soumission
```
_submitProject() →
├── Validation formulaire (_formKey.currentState!.validate())
├── Vérification accès Premium (PremiumUtils.checkPremiumAccess)
├── setState(_isLoading = true)
├── Simulation API (Future.delayed 2s)
├── SnackBar succès
├── Navigation vers Routes.home
└── Gestion erreur + setState(_isLoading = false)
```

### 2.5 Navigation Bottom Bar
```
_onNavBarTap(index) →
├── setState(_currentIndex = index)
└── switch(index):
    ├── 0 → HomeRoute
    ├── 1 → SearchRoute
    ├── 2 → [Écran actuel]
    ├── 3 → NotificationsRoute
    └── 4 → ProfileRoute
```

### 2.6 Vérification Premium
```
initState() → _checkPremiumAccess() →
├── PremiumUtils.checkPremiumAccess(projectCreation)
└── Si pas d'accès → context.router.pop()
```

## 3. Problèmes Ergonomiques Identifiés

### 3.1 Problèmes de Layout (7 problèmes)

#### 3.1.1 Espacements Rigides
**Localisation :** Lignes 206, 225, 252, 268
```dart
const SizedBox(height: 24)  // Espacement fixe non hiérarchisé
const SizedBox(height: 16)  // Répétition sans logique responsive
```
**Impact :** Manque de hiérarchie visuelle, problème responsive sur petits écrans
**Priorité :** Moyenne

#### 3.1.2 Padding Identique sur Toutes les Cards
**Localisation :** Lignes 223, 358, 381, 506
```dart
padding: const EdgeInsets.all(DesignConstants.paddingLarge)
```
**Impact :** Monotonie visuelle, pas de distinction entre sections importantes
**Priorité :** Faible

#### 3.1.3 Largeur Fixe Non Responsive des Dropdowns
**Localisation :** Lignes 275-295, 315-335
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  // Pas de contraintes de largeur responsive
)
```
**Impact :** Problème d'affichage sur écrans étroits
**Priorité :** Moyenne

#### 3.1.4 Structure Column Sans Contraintes de Hauteur
**Localisation :** Ligne 202
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [...] // Pas de mainAxisSize
)
```
**Impact :** Risque d'overflow vertical sur petits écrans
**Priorité :** Moyenne

#### 3.1.5 Gestion Inadéquate des FilterChips
**Localisation :** Lignes 429-457, 477-505
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  // Pas de contraintes sur le nombre de lignes
)
```
**Impact :** Interface peut devenir très haute avec beaucoup de sélections
**Priorité :** Moyenne

#### 3.1.6 Margin Bottom Automatique des VLCard
**Localisation :** Composant VLCard ligne 34
```dart
margin: const EdgeInsets.only(bottom: AppTheme.defaultPadding)
```
**Impact :** Espacement non contrôlé entre les sections
**Priorité :** Faible

#### 3.1.7 Container Premium Note Sans Contraintes
**Localisation :** Lignes 557-602
```dart
Container(
  padding: const EdgeInsets.all(DesignConstants.paddingMedium),
  // Pas de width ou de flexibilité définie
)
```
**Impact :** Peut déborder sur petits écrans
**Priorité :** Faible

### 3.2 Problèmes d'Accessibilité (6 problèmes)

#### 3.2.1 FilterChips Sans Sémantique Appropriée
**Localisation :** Lignes 429-457, 477-505
```dart
FilterChip(
  label: Text(type),
  // Manque semanticsLabel pour screen readers
)
```
**Impact :** Navigation difficile pour utilisateurs avec déficience visuelle
**Priorité :** Haute

#### 3.2.2 Dropdowns Sans Labels Accessibles
**Localisation :** Lignes 275-295, 315-335
```dart
DropdownButton<String>(
  // Manque de hint ou semanticsLabel
)
```
**Impact :** Screen readers ne peuvent pas identifier le contenu
**Priorité :** Haute

#### 3.2.3 Contraste Insuffisant sur Labels
**Localisation :** Lignes 268, 308, 417, 470
```dart
color: DesignConstants.darkGrey
// Peut ne pas respecter WCAG 2.1 AA (4.5:1)
```
**Impact :** Lisibilité réduite pour utilisateurs malvoyants
**Priorité :** Moyenne

#### 3.2.4 Zone de Touch Insuffisante sur FilterChips
**Localisation :** Lignes 429-457
```dart
FilterChip(
  // Taille minimale 48x48px non garantie
)
```
**Impact :** Difficile à toucher sur mobile pour utilisateurs avec difficultés motrices
**Priorité :** Moyenne

#### 3.2.5 Messages d'Erreur Non Persistants
**Localisation :** Lignes 119-130
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Erreur lors de la création du projet...'),
    // Pas de durée personnalisée ou action
  ),
)
```
**Impact :** Messages peuvent disparaître avant d'être lus
**Priorité :** Moyenne

#### 3.2.6 Navigation Keyboard Non Optimisée
**Localisation :** Ensemble du formulaire
```dart
// Pas de textInputAction optimisés pour navigation séquentielle
// Pas de FocusNode pour contrôler l'ordre de focus
```
**Impact :** Navigation clavier difficile
**Priorité :** Moyenne

### 3.3 Problèmes d'Expérience Utilisateur (8 problèmes)

#### 3.3.1 **CRITIQUE** - Fonctionnalité Brouillon Non Implémentée
**Localisation :** Lignes 530-540
```dart
onPressed: () {
  // TODO: Implémenter la sauvegarde comme brouillon
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Projet enregistré comme brouillon'),
    ),
  );
}
```
**Impact :** Fonctionnalité promise à l'utilisateur mais non fonctionnelle
**Priorité :** **CRITIQUE**

#### 3.3.2 **CRITIQUE** - Simulation API au Lieu d'Intégration Réelle
**Localisation :** Lignes 104-108
```dart
try {
  // Simuler une requête d'API
  await Future.delayed(const Duration(seconds: 2));
  // Pas d'appel réel à l'API
}
```
**Impact :** Données non sauvegardées, faux sentiment d'accomplissement
**Priorité :** **CRITIQUE**

#### 3.3.3 Validation de Fourchette de Financement Faible
**Localisation :** Lignes 403-413
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez entrer une fourchette de financement';
  }
  return null; // Pas de validation du format
}
```
**Impact :** Utilisateur peut entrer format invalide ("abc" au lieu de "50K-100K €")
**Priorité :** Haute

#### 3.3.4 Pas de Sauvegarde Automatique ou de Persistance
**Localisation :** Ensemble du formulaire
```dart
// Aucun mécanisme de sauvegarde automatique
// Perte de données si l'app se ferme
```
**Impact :** Frustration utilisateur si perte de données
**Priorité :** Haute

#### 3.3.5 Gestion d'Erreur Générique
**Localisation :** Lignes 119-127
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Erreur lors de la création du projet. Veuillez réessayer.'),
    // Message générique sans détail
  ),
);
```
**Impact :** Utilisateur ne sait pas pourquoi ça a échoué
**Priorité :** Moyenne

#### 3.3.6 Pas de Prévisualisation du Projet
**Localisation :** Absence de fonctionnalité
```dart
// Pas de bouton "Aperçu" pour voir le rendu final
```
**Impact :** Utilisateur ne peut pas valider l'apparence avant publication
**Priorité :** Moyenne

#### 3.3.7 Limitation Premium Peu Claire
**Localisation :** Lignes 81-87
```dart
Future<void> _checkPremiumAccess() async {
  // Vérification mais feedback peu clair à l'utilisateur
}
```
**Impact :** Utilisateur découvre la limitation après avoir commencé
**Priorité :** Moyenne

#### 3.3.8 Pas d'Indicateur de Progression
**Localisation :** Ensemble du formulaire
```dart
// Pas d'indicateur de pourcentage de completion
// Pas de section "étapes" du formulaire
```
**Impact :** Utilisateur ne sait pas combien il reste à remplir
**Priorité :** Faible

### 3.4 Problèmes de Performance (4 problèmes)

#### 3.4.1 Vérification Premium Répétée
**Localisation :** Lignes 92-100, 75-87
```dart
// Vérification à initState ET à _submitProject
final hasAccess = await PremiumUtils.checkPremiumAccess(
  context,
  PremiumFeature.projectCreation,
);
```
**Impact :** Appels redondants, latence inutile
**Priorité :** Moyenne

#### 3.4.2 Rebuild Inutiles des FilterChips
**Localisation :** Lignes 429-505
```dart
children: _skills.map((skill) {
  // Reconstruction complète à chaque setState
}).toList(),
```
**Impact :** Performance dégradée avec beaucoup de chips
**Priorité :** Faible

#### 3.4.3 Validation Synchrone Lourde
**Localisation :** Lignes 248-264
```dart
validator: (value) {
  if (value.length > 200) {
    return 'La description courte ne doit pas dépasser 200 caractères';
  }
  // Validation à chaque caractère tapé
}
```
**Impact :** Interface peut laguer sur texte long
**Priorité :** Faible

#### 3.4.4 Navigation setState Inutile
**Localisation :** Lignes 140-159
```dart
void _onNavBarTap(int index) {
  setState(() {
    _currentIndex = index; // setState inutile avant navigation
  });
}
```
**Impact :** Rebuild inutile avant changement de page
**Priorité :** Faible

### 3.5 Problèmes de Responsivité (5 problèmes)

#### 3.5.1 SingleChildScrollView Sans Contraintes
**Localisation :** Ligne 182
```dart
body: SingleChildScrollView(
  padding: const EdgeInsets.all(DesignConstants.paddingMedium),
  // Pas de contraintes min/max height
)
```
**Impact :** Problème sur écrans très petits ou très grands
**Priorité :** Moyenne

#### 3.5.2 FilterChips Non Responsive
**Localisation :** Lignes 429-505
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  // Pas d'adaptation à la largeur d'écran
)
```
**Impact :** Chips peuvent être trop petits sur tablette, trop grands sur mobile
**Priorité :** Moyenne

#### 3.5.3 VLTextField MaxLines Fixes
**Localisation :** Lignes 250, 372
```dart
maxLines: 2,  // Description courte
maxLines: 8,  // Description détaillée
```
**Impact :** Ne s'adapte pas à la taille d'écran
**Priorité :** Faible

#### 3.5.4 Padding Uniforme Non Adaptatif
**Localisation :** Ligne 182
```dart
padding: const EdgeInsets.all(DesignConstants.paddingMedium)
```
**Impact :** Même padding sur mobile et tablette
**Priorité :** Faible

#### 3.5.5 Premium Note Container Non Flexible
**Localisation :** Lignes 557-602
```dart
Container(
  padding: const EdgeInsets.all(DesignConstants.paddingMedium),
  // Pas de flexibilité pour différentes tailles
)
```
**Impact :** Peut déborder ou être disproportionné
**Priorité :** Faible

### 3.6 Problèmes de Cohérence (6 problèmes)

#### 3.6.1 Mélange de Constantes de Design
**Localisation :** Lignes 275, 315 vs autres
```dart
// Tantôt DesignConstants.radiusSmall
// Tantôt BorderRadius.circular(DesignConstants.radiusSmall)
// Incohérence dans l'usage
```
**Impact :** Design system non uniforme
**Priorité :** Moyenne

#### 3.6.2 Couleurs Premium Codées en Dur
**Localisation :** Lignes 560-562, 578
```dart
color: const Color(0xFFFFD700).withOpacity(0.1)
border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))
color: Color(0xFFFFD700)
```
**Impact :** Non maintenable, incohérent avec le design system
**Priorité :** Moyenne

#### 3.6.3 Messages Non Localisés
**Localisation :** Lignes 206-214, 536-538
```dart
'Partagez votre projet avec la communauté'
'Projet enregistré comme brouillon'
// Textes français codés dur
```
**Impact :** Problème d'internationalisation annoncée
**Priorité :** Haute

#### 3.6.4 Styles de Texte Inconsistants
**Localisation :** Lignes 229, 363, 387, 512
```dart
// Tantôt const TextStyle(...)
// Tantôt TextStyle(fontSize: Theme.of(context)...)
```
**Impact :** Apparence incohérente entre sections
**Priorité :** Moyenne

#### 3.6.5 Gestion d'État Navigation Incohérente
**Localisation :** Lignes 140-159
```dart
// setState puis navigation immédiate
// Logique différente d'autres écrans
```
**Impact :** Comportement imprévisible entre pages
**Priorité :** Faible

#### 3.6.6 Validation FormField Incohérente
**Localisation :** Champs de formulaire
```dart
// Certains champs avec validation complexe
// D'autres avec validation basique
// Tags sans validation du tout
```
**Impact :** Expérience utilisateur inégale
**Priorité :** Moyenne

## 4. Recommandations d'Amélioration

### 4.1 Corrections Critiques (À implémenter immédiatement)

#### 4.1.1 Implémentation Réelle de la Sauvegarde Brouillon
```dart
// Intégrer avec provider/repository pattern
void _saveDraft() async {
  final projectData = _buildProjectData();
  await projectRepository.saveDraft(projectData);
  // Feedback utilisateur approprié
}
```

#### 4.1.2 Intégration API Réelle
```dart
void _submitProject() async {
  // Remplacer simulation par vraie intégration
  final response = await projectApiService.createProject(projectData);
  // Gestion appropriée des réponses et erreurs
}
```

#### 4.1.3 Validation Avancée du Financement
```dart
String? _validateFundingRange(String? value) {
  if (value == null || value.isEmpty) return 'Champ requis';
  
  // Regex pour formats acceptés: "50K-100K €", "50000-100000 €", etc.
  final regex = RegExp(r'^\d+[KMk]?\s*-\s*\d+[KMk]?\s*€?$');
  if (!regex.hasMatch(value)) {
    return 'Format invalide. Ex: 50K-100K € ou 50000-100000 €';
  }
  return null;
}
```

### 4.2 Améliorations UX Prioritaires

#### 4.2.1 Ajout d'un Système de Sauvegarde Automatique
```dart
Timer? _autoSaveTimer;

void _startAutoSave() {
  _autoSaveTimer = Timer.periodic(Duration(minutes: 2), (_) {
    _saveDraft();
  });
}
```

#### 4.2.2 Indicateur de Progression du Formulaire
```dart
Widget _buildProgressIndicator() {
  final completedFields = _getCompletedFieldsCount();
  final totalFields = _getTotalFieldsCount();
  return LinearProgressIndicator(
    value: completedFields / totalFields,
    backgroundColor: Colors.grey[300],
    valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
  );
}
```

#### 4.2.3 Mode Prévisualisation
```dart
void _showPreview() {
  final projectData = _buildProjectData();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => ProjectPreviewWidget(data: projectData),
  );
}
```

### 4.3 Améliorations d'Accessibilité

#### 4.3.1 Labels Sémantiques pour FilterChips
```dart
FilterChip(
  label: Text(skill),
  tooltip: 'Compétence: $skill. ${isSelected ? "Sélectionnée" : "Non sélectionnée"}',
  semanticsLabel: 'Compétence $skill, ${isSelected ? "sélectionnée" : "appuyer pour sélectionner"}',
)
```

#### 4.3.2 Ordre de Focus Optimisé
```dart
// Ajouter FocusNodes pour chaque champ
final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

// Dans VLTextField
textInputAction: _getNextTextInputAction(index),
focusNode: _focusNodes[index],
onSubmitted: (_) => _focusNext(index),
```

### 4.4 Améliorations de Performance

#### 4.4.1 Cache de Vérification Premium
```dart
class PremiumCache {
  static bool? _hasProjectCreationAccess;
  static DateTime? _lastCheck;
  
  static Future<bool> checkAccess(BuildContext context) async {
    if (_lastCheck != null && 
        DateTime.now().difference(_lastCheck!) < Duration(minutes: 5) &&
        _hasProjectCreationAccess != null) {
      return _hasProjectCreationAccess!;
    }
    
    _hasProjectCreationAccess = await PremiumUtils.checkPremiumAccess(
      context, PremiumFeature.projectCreation
    );
    _lastCheck = DateTime.now();
    return _hasProjectCreationAccess!;
  }
}
```

#### 4.4.2 Optimisation FilterChips avec const
```dart
Widget _buildSkillChips() {
  return Wrap(
    children: _skills.map((skill) => _SkillChip(
      key: ValueKey(skill),
      skill: skill,
      isSelected: _selectedSkills.contains(skill),
      onChanged: (selected) => _toggleSkill(skill, selected),
    )).toList(),
  );
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({Key? key, required this.skill, required this.isSelected, required this.onChanged}) : super(key: key);
  // Implémentation optimisée...
}
```

### 4.5 Améliorations de Design Responsive

#### 4.5.1 Layout Adaptatif
```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return _buildTabletLayout();
      } else {
        return _buildMobileLayout();
      }
    },
  );
}
```

#### 4.5.2 Espacement Responsive
```dart
double _getResponsivePadding(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 600) return 24.0;
  if (screenWidth > 400) return 16.0;
  return 12.0;
}
```

## 5. Synthèse des Priorités

### Niveau CRITIQUE (2 problèmes)
1. **Fonctionnalité brouillon non implémentée** - Impact utilisateur direct
2. **Simulation API au lieu d'intégration réelle** - Données non persistées

### Niveau HAUTE (4 problèmes)
1. **Messages non localisés** - Incohérent avec requirements d'internationalisation
2. **FilterChips sans sémantique** - Problème d'accessibilité majeur
3. **Dropdowns sans labels accessibles** - Problème d'accessibilité majeur  
4. **Validation financière faible** - Données invalides possibles

### Niveau MOYENNE (15 problèmes)
- Problèmes de layout, responsivité et cohérence visuelle
- Améliorations UX non critiques
- Optimisations de performance

### Niveau FAIBLE (8 problèmes)
- Détails de polish et d'optimisation
- Améliorations mineures d'expérience

**Total identifié : 29 problèmes ergonomiques**

La page de création de projet présente des problèmes critiques de fonctionnalité (brouillon et API simulée) qui doivent être résolus en priorité, suivis des améliorations d'accessibilité et de validation pour assurer une expérience utilisateur professionnelle.