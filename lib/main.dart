import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/contact.dart';
import 'data/education.dart';
import 'data/experience.dart';
import 'data/family.dart';
import 'data/personal_info.dart';
import 'data/skills.dart';
import 'theme/app_theme.dart';

void main() => runApp(const CvApp());

class CvApp extends StatelessWidget {
  const CvApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CV • Elisabeth',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const LoginScreen(),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  String? _error;

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    if (_user.text.trim() == demoUsername && _password.text == demoPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
      );
    } else {
      setState(() => _error = 'Identifiant ou mot de passe incorrect.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xfff4f7f6), Color(0xffe7f0ed)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: AppTheme.ink,
                          child: Icon(
                            Icons.person_outline,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Bienvenue',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connectez-vous pour découvrir mon univers',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 26),
                        TextFormField(
                          controller: _user,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Identifiant',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Saisissez votre identifiant.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: _hidden,
                          onFieldSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _hidden
                                  ? 'Afficher le mot de passe'
                                  : 'Masquer le mot de passe',
                              onPressed: () =>
                                  setState(() => _hidden = !_hidden),
                              icon: Icon(
                                _hidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Saisissez votre mot de passe.'
                              : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Se connecter'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Accès de démonstration : $demoUsername / $demoPassword',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _pages = const [
    HomeScreen(),
    CvScreen(),
    FamilyScreen(),
    ContactScreen(),
  ];
  final _titles = const ['Accueil', 'Mon CV', 'Ma famille', 'Contact'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_titles[_index]),
      actions: [
        IconButton(
          tooltip: 'Se déconnecter',
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            (_) => false,
          ),
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge),
          label: 'Mon CV',
        ),
        NavigationDestination(
          icon: Icon(Icons.family_restroom_outlined),
          selectedIcon: Icon(Icons.family_restroom),
          label: 'Famille',
        ),
        NavigationDestination(
          icon: Icon(Icons.mail_outline),
          selectedIcon: Icon(Icons.mail),
          label: 'Contact',
        ),
      ],
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 38,
              backgroundColor: Color(0xffd8ebe4),
              child: Icon(Icons.person, size: 42, color: AppTheme.ink),
            ),
            const SizedBox(height: 18),
            Text(
              personName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              personTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: const Color(0xffb7d4c9)),
            ),
            const SizedBox(height: 16),
            Text(
              personSummary,
              style: const TextStyle(color: Colors.white, height: 1.5),
            ),
            const SizedBox(height: 18),
            const Text(
              '« Apprendre, créer et contribuer avec intention. »',
              style: TextStyle(
                color: Color(0xffd8ebe4),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      const SectionHeading(
        'En quelques mots',
        icon: Icons.auto_awesome_outlined,
      ),
      InfoCard(
        icon: Icons.school_outlined,
        title: 'Formation',
        subtitle: educationItems.first.degree,
      ),
      const InfoCard(
        icon: Icons.code,
        title: 'Domaine',
        subtitle: 'Développement logiciel • applications mobiles',
      ),
      const InfoCard(
        icon: Icons.place_outlined,
        title: 'Localisation',
        subtitle: contactLocation,
      ),
    ],
  );
}

class CvScreen extends StatelessWidget {
  const CvScreen({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const SectionHeading('Formation', icon: Icons.school_outlined),
      for (final item in educationItems)
        TimelineCard(
          title: item.degree,
          subtitle: '${item.institution} • ${item.years}',
          body: item.description,
          icon: Icons.school_outlined,
        ),
      const SizedBox(height: 12),
      const SectionHeading('Expériences & projets', icon: Icons.work_outline),
      for (final item in experienceItems)
        TimelineCard(
          title: item.title,
          subtitle: '${item.organization} • ${item.period}',
          body: item.description,
          icon: Icons.work_outline,
        ),
      const SizedBox(height: 12),
      const SectionHeading('Compétences techniques', icon: Icons.code),
      for (final skill in technicalSkills) SkillTile(skill: skill),
      const SizedBox(height: 12),
      const SectionHeading('Langues', icon: Icons.translate),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: languageSkills.map((s) => Chip(label: Text(s))).toList(),
      ),
      const SizedBox(height: 12),
      const SectionHeading('Centres d’intérêt', icon: Icons.favorite_border),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: interestItems
            .map(
              (s) => Chip(avatar: Icon(s.icon, size: 18), label: Text(s.label)),
            )
            .toList(),
      ),
    ],
  );
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Text(
        'Les personnes qui comptent',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Text(
        'Remplacez ces profils de démonstration par les membres de votre famille.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 14),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 650
              ? 3
              : constraints.maxWidth > 420
              ? 2
              : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Les profils peuvent contenir plusieurs lignes de texte.
              // Des cartes plus hautes évitent de couper ces informations.
              childAspectRatio: columns == 1 ? .9 : .72,
            ),
            itemCount: familyMembers.length,
            itemBuilder: (context, index) {
              final member = familyMembers[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: const Color(0xffe7f0ed),
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        member.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        member.relationship,
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                      if (member.activity.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(member.activity, textAlign: TextAlign.center),
                      ],
                      if (member.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          member.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ],
  );
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir cette application ou ce lien.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Text(
        'Restons en contact',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Text(
        'Choisissez un moyen de me joindre.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 12),
      ContactTile(
        icon: Icons.phone_outlined,
        title: 'Téléphone',
        value: contactPhone,
        onTap: () => _open(
          context,
          Uri(scheme: 'tel', path: contactPhone.replaceAll(' ', '')),
        ),
      ),
      ContactTile(
        icon: Icons.email_outlined,
        title: 'E-mail',
        value: contactEmail,
        onTap: () => _open(context, Uri(scheme: 'mailto', path: contactEmail)),
      ),
      ContactTile(
        icon: Icons.location_on_outlined,
        title: 'Adresse',
        value: contactAddress,
        onTap: () => _open(
          context,
          Uri.https('maps.google.com', '/', {'q': contactLocation}),
        ),
      ),
      ContactTile(
        icon: Icons.link,
        title: 'LinkedIn',
        value: contactLinkedIn,
        onTap: () => _open(context, Uri.parse(contactLinkedIn)),
      ),
      ContactTile(
        icon: Icons.code,
        title: 'GitHub',
        value: contactGitHub,
        onTap: () => _open(context, Uri.parse(contactGitHub)),
      ),
    ],
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: children,
        ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {required this.icon, super.key});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.green),
        const SizedBox(width: 9),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppTheme.green),
      title: Text(title),
      subtitle: Text(subtitle),
    ),
  );
}

class TimelineCard extends StatelessWidget {
  const TimelineCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    super.key,
  });
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.green),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.green),
                ),
                const SizedBox(height: 7),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SkillTile extends StatelessWidget {
  const SkillTile({required this.skill, super.key});
  final SkillItem skill;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(skill.name)),
              Text('${(skill.level * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 9),
          LinearProgressIndicator(
            value: skill.level,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    ),
  );
}

class ContactTile extends StatelessWidget {
  const ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    super.key,
  });
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: const Color(0xffe7f0ed),
        child: Icon(icon, color: AppTheme.ink),
      ),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.open_in_new, size: 18),
    ),
  );
}
