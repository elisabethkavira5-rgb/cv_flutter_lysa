# cv_flutter_elisabeth

Application Flutter de présentation d’un CV, d’une famille et de coordonnées. Le projet est un support académique personnalisable : les données fournies sont des exemples fictifs clairement identifiés et ne décrivent pas une personne réelle.

## Objectifs

- Présenter un profil, une formation, des expériences et des compétences dans une interface mobile professionnelle.
- Proposer une connexion de démonstration, une navigation simple et des actions de contact.
- Garder les données dans des fichiers dédiés afin de faciliter leur remplacement.

## Fonctionnalités

- Écran de connexion avec validation, visibilité du mot de passe et message d’erreur.
- Accueil avec profil et aperçu des informations.
- CV avec formation, expériences/projets, compétences, langues et centres d’intérêt.
- Présentation responsive de la famille.
- Contact : appel téléphonique, e-mail, carte et liens LinkedIn/GitHub via `url_launcher`.
- Barre de navigation à quatre onglets, transitions et déconnexion.

## Technologies

- Flutter 3.44.8 / Dart 3.12.2
- Material 3
- Packages : `cupertino_icons`, `url_launcher`

## Installation et lancement

```bash
flutter pub get
flutter run
```

Pour contrôler le code :

```bash
flutter analyze
```

## Connexion de démonstration

- Identifiant : `elisabeth`
- Mot de passe : `cv2026`

Ces identifiants sont définis dans `lib/data/personal_info.dart`. Il s’agit d’un accès local de démonstration, pas d’un système d’authentification destiné à la production.

## Personnalisation

Remplacez les exemples dans les fichiers suivants :

- `lib/data/personal_info.dart` : nom, titre, présentation et identifiants.
- `lib/data/education.dart` : établissements, diplômes, années et descriptions.
- `lib/data/experience.dart` : stages, emplois et projets.
- `lib/data/skills.dart` : niveaux, langues et intérêts.
- `lib/data/family.dart` : noms, liens de parenté, activités et descriptions.
- `lib/data/contact.dart` : téléphone, e-mail, adresse, localisation et profils.
- `assets/images/` : portraits personnels et photos de la famille. Les avatars actuels sont des initiales, pas des photos.

Le thème est défini dans `lib/theme/app_theme.dart`. Les écrans et composants réutilisables sont actuellement regroupés dans `lib/main.dart`.

## Structure

```text
lib/
├── data/          # Informations personnalisables
├── theme/         # Palette et thème Material 3
└── main.dart      # Connexion, navigation, écrans et widgets partagés
assets/images/     # Photos locales à ajouter
screenshots/       # Captures de l’application exécutée
```

## Captures d’écran

Les captures doivent provenir de l’application exécutée sur un appareil ou un émulateur. Aucun émulateur Android n’est installé dans l’environnement et le rendu Flutter dans Chrome headless est resté blanc. Les quatre captures réelles ne sont donc pas disponibles. Après lancement sur un appareil, enregistrez ces fichiers ici :

- Connexion : `screenshots/01-login.png`
- Accueil / CV : `screenshots/02-accueil.png`
- Famille : `screenshots/03-famille.png`
- Contact : `screenshots/04-contact.png`

## GitHub

Le projet local porte le nom `cv_flutter_elisabeth`. Aucun dépôt GitHub n’a été créé ou publié dans cette livraison.
