import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/family_member.dart';
import 'services/api_service.dart';
import 'data/contact.dart';
import 'data/education.dart';
import 'data/experience.dart';
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
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _api.login(_user.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'API inaccessible. Vérifiez son démarrage et son URL.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    final email = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => RegisterScreen(initialEmail: _user.text.trim()),
      ),
    );
    if (email != null && mounted) {
      _user.text = email;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé. Vous pouvez vous connecter.'),
        ),
      );
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
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 360 ? 16 : 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).width < 360 ? 20 : 28,
                  ),
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
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'nom@exemple.com',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Saisissez votre adresse e-mail.'
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
                          onPressed: _loading ? null : _login,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                          label: const Text('Se connecter'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loading ? null : _register,
                          child: const Text('Créer un compte'),
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _api.register(_email.text.trim(), _password.text);
      if (mounted) Navigator.of(context).pop(_email.text.trim());
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'API inaccessible. Vérifiez son démarrage et son URL.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 360 ? 16 : 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.sizeOf(context).width < 360 ? 20 : 30,
                    22,
                    MediaQuery.sizeOf(context).width < 360 ? 20 : 30,
                    26,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _loading
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Retour'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: AppTheme.ink,
                          child: Icon(
                            Icons.person_add_alt_1,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Créer votre compte',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inscrivez-vous pour accéder à votre espace personnel.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Adresse e-mail',
                            hintText: 'nom@exemple.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            return email.contains('@') && email.contains('.')
                                ? null
                                : 'Saisissez une adresse e-mail valide.';
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            helperText: '6 caractères minimum',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _hidePassword
                                  ? 'Afficher le mot de passe'
                                  : 'Masquer le mot de passe',
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value != null && value.length >= 6
                              ? null
                              : 'Choisissez au moins 6 caractères.',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmation,
                          obscureText: _hideConfirmation,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _createAccount(),
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              tooltip: _hideConfirmation
                                  ? 'Afficher le mot de passe'
                                  : 'Masquer le mot de passe',
                              onPressed: () => setState(
                                () => _hideConfirmation = !_hideConfirmation,
                              ),
                              icon: Icon(
                                _hideConfirmation
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) => value == _password.text
                              ? null
                              : 'Les mots de passe ne correspondent pas.',
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xffffeeee),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xffa32929)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _loading ? null : _createAccount,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Créer mon compte'),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text(
                            'J’ai déjà un compte · Se connecter',
                          ),
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

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Accueil',
    ),
    NavigationDestination(
      icon: Icon(Icons.badge_outlined),
      selectedIcon: Icon(Icons.badge_rounded),
      label: 'Mon CV',
    ),
    NavigationDestination(
      icon: Icon(Icons.family_restroom_outlined),
      selectedIcon: Icon(Icons.family_restroom_rounded),
      label: 'Famille',
    ),
    NavigationDestination(
      icon: Icon(Icons.mail_outline_rounded),
      selectedIcon: Icon(Icons.mail_rounded),
      label: 'Contact',
    ),
  ];

  static const _railDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: Text('Accueil'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.badge_outlined),
      selectedIcon: Icon(Icons.badge_rounded),
      label: Text('Mon CV'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.family_restroom_outlined),
      selectedIcon: Icon(Icons.family_restroom_rounded),
      label: Text('Famille'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.mail_outline_rounded),
      selectedIcon: Icon(Icons.mail_rounded),
      label: Text('Contact'),
    ),
  ];

  Widget _activePage() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 220),
    child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
  );

  Widget _mobileNavigation() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: .12),
              blurRadius: 22,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 74,
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xffdcebe5),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: _destinations,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final wideLayout = MediaQuery.sizeOf(context).width >= 1024;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        toolbarHeight: 68,
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
      body: wideLayout
          ? Row(
              children: [
                SizedBox(
                  width: 84,
                  child: NavigationRail(
                    minWidth: 72,
                    backgroundColor: Colors.white,
                    selectedIndex: _index,
                    labelType: NavigationRailLabelType.all,
                    indicatorColor: const Color(0xffdcebe5),
                    leading: const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 20),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.ink,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.person_outline),
                      ),
                    ),
                    onDestinationSelected: (i) => setState(() => _index = i),
                    destinations: _railDestinations,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _activePage()),
              ],
            )
          : _activePage(),
      bottomNavigationBar: wideLayout ? null : _mobileNavigation(),
    );
  }
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

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});
  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _api = ApiService();
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final members = await _api.getFamilyMembers();
      if (mounted) {
        setState(() {
          _familyMembers = members;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadError = error is ApiException
              ? error.message
              : 'API inaccessible. Vérifiez son démarrage et son URL.';
          _isLoading = false;
        });
      }
    }
  }

  void _reload() {
    _loadMembers();
  }

  String _imageUrl(String value) {
    final image = Uri.tryParse(value);
    final api = Uri.tryParse(ApiService.baseUrl);
    if (image == null ||
        api == null ||
        (image.host != 'localhost' && image.host != '127.0.0.1')) {
      return value;
    }
    return image.replace(host: api.host, port: api.port).toString();
  }

  Widget _memberAvatar(FamilyMember member) {
    final fallback = CircleAvatar(
      radius: 34,
      backgroundColor: const Color(0xffe7f0ed),
      child: Text(
        member.initials,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.ink,
        ),
      ),
    );
    final url = member.imageUrl;
    if (url == null || url.isEmpty) return fallback;

    return ClipOval(
      child: SizedBox(
        width: 68,
        height: 68,
        child: Image.network(
          _imageUrl(url),
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          errorBuilder: (context, error, stackTrace) => fallback,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return fallback;
          },
        ),
      ),
    );
  }

  Future<void> _edit([FamilyMember? existing]) async {
    final formKey = GlobalKey<FormState>();
    PlatformFile? selectedImage;
    final fields = <String, TextEditingController>{
      'nom': TextEditingController(text: existing?.nom ?? ''),
      'postnom': TextEditingController(text: existing?.postnom ?? ''),
      'prenom': TextEditingController(text: existing?.prenom ?? ''),
      'lieu_naissance': TextEditingController(
        text: existing?.lieuNaissance ?? '',
      ),
      'date_naissance': TextEditingController(
        text: existing?.dateNaissance ?? '',
      ),
      'parente': TextEditingController(text: existing?.parente ?? ''),
    };
    final labels = {
      'nom': 'Nom',
      'postnom': 'Postnom',
      'prenom': 'Prénom',
      'lieu_naissance': 'Lieu de naissance',
      'date_naissance': 'Date de naissance (AAAA-MM-JJ)',
      'parente': 'Parenté',
    };
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            existing == null ? 'Ajouter un membre' : 'Modifier le membre',
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in fields.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: entry.value,
                          keyboardType: entry.key == 'date_naissance'
                              ? TextInputType.datetime
                              : TextInputType.text,
                          decoration: InputDecoration(
                            labelText: labels[entry.key],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ce champ est obligatoire.';
                            }
                            if (entry.key == 'date_naissance' &&
                                !RegExp(
                                  r'^\d{4}-\d{2}-\d{2}$',
                                ).hasMatch(value)) {
                              return 'Utilisez le format AAAA-MM-JJ.';
                            }
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final file = await FilePicker.pickFile(
                            type: FileType.custom,
                            allowedExtensions: [
                              'jpg',
                              'jpeg',
                              'png',
                              'gif',
                              'webp',
                            ],
                          );
                          if (file != null) {
                            final size = await file.length();
                            if (size != null && size > 2 * 1024 * 1024) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'L’image ne doit pas dépasser 2 Mo.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            setDialogState(() => selectedImage = file);
                          }
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Impossible de lire cette image.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.photo_outlined),
                      label: Text(
                        selectedImage == null
                            ? existing?.imageUrl == null
                                  ? 'Ajouter une image (facultatif)'
                                  : 'Remplacer l’image'
                            : 'Changer l’image',
                      ),
                    ),
                    if (selectedImage != null)
                      Text(selectedImage!.name, textAlign: TextAlign.center),
                    const Text('JPG, PNG, GIF ou WebP • 2 Mo maximum'),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      final member = FamilyMember(
        id: existing?.id ?? 0,
        nom: fields['nom']!.text.trim(),
        postnom: fields['postnom']!.text.trim(),
        prenom: fields['prenom']!.text.trim(),
        lieuNaissance: fields['lieu_naissance']!.text.trim(),
        dateNaissance: fields['date_naissance']!.text.trim(),
        parente: fields['parente']!.text.trim(),
      );
      try {
        if (existing == null) {
          await _api.createFamilyMember(member, image: selectedImage);
        } else {
          await _api.updateFamilyMember(member, image: selectedImage);
        }
        await _loadMembers();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Membre enregistré.')));
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error is ApiException
                    ? error.message
                    : 'Impossible de joindre l’API.',
              ),
            ),
          );
        }
      }
    }
    for (final controller in fields.values) {
      controller.dispose();
    }
  }

  Future<void> _delete(FamilyMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce membre ?'),
        content: Text(member.fullName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteFamilyMember(member.id);
      if (mounted) await _loadMembers();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ApiException
                  ? error.message
                  : 'Impossible de joindre l’API.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Les personnes qui comptent',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      Text(
        'Membres de famille enregistrés dans la base de données.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 14),
      if (_isLoading)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        )
      else if (_loadError != null)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 36,
                  color: AppTheme.muted,
                ),
                const SizedBox(height: 8),
                Text(_loadError!, textAlign: TextAlign.center),
                TextButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        )
      else ...[
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _edit(),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Ajouter un membre'),
          ),
        ),
        const SizedBox(height: 10),
        if (_familyMembers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Text(
              'Aucun membre enregistré.',
              textAlign: TextAlign.center,
            ),
          )
        else
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
                  childAspectRatio: columns == 1 ? 1.15 : .85,
                ),
                itemCount: _familyMembers.length,
                itemBuilder: (context, index) {
                  final member = _familyMembers[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _memberAvatar(member),
                          const SizedBox(height: 8),
                          Text(
                            member.fullName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            member.parente,
                            style: const TextStyle(color: AppTheme.muted),
                          ),
                          Text(
                            'Né(e) le ${member.dateNaissance} à ${member.lieuNaissance}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Modifier',
                                onPressed: () => _edit(member),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Supprimer',
                                onPressed: () => _delete(member),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
      ],
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
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 360
                ? 16
                : MediaQuery.sizeOf(context).width >= 900
                ? 32
                : 20,
            MediaQuery.sizeOf(context).width >= 600 ? 24 : 16,
            MediaQuery.sizeOf(context).width < 360
                ? 16
                : MediaQuery.sizeOf(context).width >= 900
                ? 32
                : 20,
            28,
          ),
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
