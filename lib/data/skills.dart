import 'package:flutter/material.dart';

class SkillItem {
  const SkillItem(this.name, this.level);
  final String name;
  final double level;
}

class InterestItem {
  const InterestItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

// Ajustez les compétences et niveaux à votre expérience réelle.
const technicalSkills = <SkillItem>[
  SkillItem('Flutter', .65),
  SkillItem('Dart', .65),
  SkillItem('HTML & CSS', .7),
  SkillItem('JavaScript', .5),
  SkillItem('Python', .5),
  SkillItem('Bases de données', .5),
  SkillItem('Git & GitHub', .55),
];
const languageSkills = <String>[
  'Français • à préciser',
  'Anglais • à préciser',
];
const interestItems = <InterestItem>[
  InterestItem('Lecture', Icons.menu_book_outlined),
  InterestItem('Technologie', Icons.devices_outlined),
  InterestItem('Voyages', Icons.flight_takeoff_outlined),
];
