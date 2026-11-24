class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;
  final String? imageUrl;

  String get fullName => '$prenom $postnom $nom'.trim();
  String get initials => [prenom, nom]
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase())
      .take(2)
      .join();

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
    id: int.parse(json['id'].toString()),
    nom: json['nom']?.toString() ?? '',
    postnom: json['postnom']?.toString() ?? '',
    prenom: json['prenom']?.toString() ?? '',
    lieuNaissance: json['lieu_naissance']?.toString() ?? '',
    dateNaissance: json['date_naissance']?.toString() ?? '',
    parente: json['parente']?.toString() ?? '',
    imageUrl: json['image_url']?.toString(),
  );

  Map<String, String> toJson() => {
    'nom': nom,
    'postnom': postnom,
    'prenom': prenom,
    'lieu_naissance': lieuNaissance,
    'date_naissance': dateNaissance,
    'parente': parente,
  };
}
