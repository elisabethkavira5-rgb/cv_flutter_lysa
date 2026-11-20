class EducationItem {
  const EducationItem({
    required this.institution,
    required this.degree,
    required this.years,
    required this.description,
  });
  final String institution;
  final String degree;
  final String years;
  final String description;
}

// Remplacez les exemples par vos établissements, diplômes et années réels.
const educationItems = <EducationItem>[
  EducationItem(
    institution: 'Établissement à renseigner',
    degree: 'Diplôme / formation à personnaliser',
    years: 'Année – Année',
    description:
        'Ajoutez ici les matières principales, projets et acquis pertinents.',
  ),
];
