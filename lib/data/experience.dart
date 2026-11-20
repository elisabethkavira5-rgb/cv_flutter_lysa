class ExperienceItem {
  const ExperienceItem({
    required this.title,
    required this.organization,
    required this.period,
    required this.description,
  });
  final String title;
  final String organization;
  final String period;
  final String description;
}

// Remplacez les exemples par vos stages, projets académiques ou emplois.
const experienceItems = <ExperienceItem>[
  ExperienceItem(
    title: 'Projet académique à présenter',
    organization: 'Projet personnel / établissement',
    period: 'Année à préciser',
    description:
        'Décrivez votre rôle, les outils utilisés et le résultat obtenu.',
  ),
];
