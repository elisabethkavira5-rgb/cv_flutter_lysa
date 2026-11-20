class FamilyMember {
  const FamilyMember({
    required this.name,
    required this.relationship,
    this.activity = '',
    this.description = '',
    required this.initials,
  });
  final String name;
  final String relationship;
  final String activity;
  final String description;
  final String initials;
}

// Profils fictifs de démonstration. Remplacez-les et ajoutez les photos dans
// assets/images/ avant de publier ou présenter le CV.
const familyMembers = <FamilyMember>[
  FamilyMember(
    name: 'Nom à remplacer',
    relationship: 'Parent',
    activity: 'Profession à préciser',
    description: 'Une courte présentation à personnaliser.',
    initials: 'P',
  ),
  FamilyMember(
    name: 'Nom à remplacer',
    relationship: 'Parent',
    activity: 'Profession à préciser',
    description: 'Une courte présentation à personnaliser.',
    initials: 'P',
  ),
  FamilyMember(
    name: 'Nom à remplacer',
    relationship: 'Frère / sœur',
    activity: 'Activité à préciser',
    initials: 'F',
  ),
  FamilyMember(
    name: 'Nom à remplacer',
    relationship: 'Frère / sœur',
    activity: 'Activité à préciser',
    initials: 'F',
  ),
];
