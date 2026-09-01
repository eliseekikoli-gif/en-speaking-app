import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const EnSpeakingApp());
}

// =========================================================================
// 1. MODÈLES DE DONNÉES & GESTIONNAIRE D'ÉTAT RÉACTIF GLOBAL (DATABASE LOCALE)
// =========================================================================

class ReminderItem {
  String id;
  TimeOfDay time;
  List<String> days;
  bool isEnabled;
  String label;

  ReminderItem({
    required this.id,
    required this.time,
    required this.days,
    this.isEnabled = true,
    required this.label,
  });
}

class QuizHistoryItem {
  final String title;
  final String level;
  final int score;
  final int total;
  final DateTime date;

  QuizHistoryItem({
    required this.title,
    required this.level,
    required this.score,
    required this.total,
    required this.date,
  });
}

class UserProfile {
  String name;
  String email;
  String targetGoal;
  int dailyGoalMinutes;
  int weeklyGoalHours;

  UserProfile({
    required this.name,
    required this.email,
    required this.targetGoal,
    required this.dailyGoalMinutes,
    required this.weeklyGoalHours,
  });
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  // Profil Utilisateur
  UserProfile profile = UserProfile(
    name: "Élisée Kikoli",
    email: "elisee@enspeaking.com",
    targetGoal: "Anglais Professionnel & Fluidité Orale",
    dailyGoalMinutes: 20,
    weeklyGoalHours: 5,
  );

  int totalXP = 320;
  int streakDays = 5;
  int minutesStudiedToday = 14;
  double hoursStudiedThisWeek = 3.2;

  // Progression Leçons
  final Set<String> completedLessons = {'lesson_intro', 'lesson_pres_perf'};

  // Historique des Quiz
  final List<QuizHistoryItem> quizHistory = [
    QuizHistoryItem(title: "Grammaire Essentielle", level: "Débutant", score: 3, total: 3, date: DateTime.now().subtract(const Duration(days: 1))),
    QuizHistoryItem(title: "Vocabulaire Business", level: "Intermédiaire", score: 2, total: 3, date: DateTime.now().subtract(const Duration(hours: 4))),
  ];

  // Gestion des Rappels
  final List<ReminderItem> reminders = [
    ReminderItem(
      id: 'rem_1',
      time: const TimeOfDay(hour: 19, minute: 30),
      days: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
      isEnabled: true,
      label: 'Session Quotidienne de Speaking',
    ),
    ReminderItem(
      id: 'rem_2',
      time: const TimeOfDay(hour: 8, minute: 0),
      days: ['Sam', 'Dim'],
      isEnabled: false,
      label: 'Quiz & Vocabulaire du Week-end',
    ),
  ];

  // Historique Vidéo (point d'arrêt pour reprise)
  final Map<String, double> videoProgressMap = {
    'vid_1': 0.45,
    'vid_2': 0.15,
  };

  // --- ACTIONS GLOBALES ---

  void updateProfile({required String name, required String targetGoal, required int dailyGoal, required int weeklyGoal}) {
    profile.name = name;
    profile.targetGoal = targetGoal;
    profile.dailyGoalMinutes = dailyGoal;
    profile.weeklyGoalHours = weeklyGoal;
    notifyListeners();
  }

  void completeLesson(String lessonId, int xpReward) {
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
      totalXP += xpReward;
      minutesStudiedToday += 10;
      hoursStudiedThisWeek += 0.2;
      notifyListeners();
    }
  }

  void recordQuizResult({required String title, required String level, required int score, required int total}) {
    quizHistory.insert(0, QuizHistoryItem(title: title, level: level, score: score, total: total, date: DateTime.now()));
    totalXP += (score * 25);
    minutesStudiedToday += 6;
    hoursStudiedThisWeek += 0.1;
    notifyListeners();
  }

  void toggleReminder(String id) {
    final rem = reminders.firstWhere((r) => r.id == id);
    rem.isEnabled = !rem.isEnabled;
    notifyListeners();
  }

  void addOrUpdateReminder(ReminderItem reminder) {
    final idx = reminders.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      reminders[idx] = reminder;
    } else {
      reminders.add(reminder);
    }
    notifyListeners();
  }

  void deleteReminder(String id) {
    reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void saveVideoProgress(String videoId, double progress) {
    videoProgressMap[videoId] = progress;
    notifyListeners();
  }

  String get currentCefrLevel {
    if (totalXP < 200) return "A1 Débutant";
    if (totalXP < 450) return "A2 Élémentaire";
    if (totalXP < 750) return "B1 Intermédiaire";
    if (totalXP < 1200) return "B2 Avancé";
    return "C1 Bilingue Expert";
  }

  double get overallProgress {
    double calc = (completedLessons.length * 15 + quizHistory.length * 10) / 150.0;
    return calc.clamp(0.1, 1.0);
  }
}

// =========================================================================
// 2. CONFIGURATION DE L'APPLICATION & NAVIGATION
// =========================================================================

class EnSpeakingApp extends StatelessWidget {
  const EnSpeakingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EN-Speaking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF0EA5E9),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0EA5E9),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  static _MainNavigationScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainNavigationScreenState>();

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    LessonsScreen(),
    SpeakingAndAudioScreen(),
    VideoEducationScreen(),
    QuizInteractiveScreen(),
    LearnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E293B),
          indicatorColor: const Color(0xFF0EA5E9).withOpacity(0.25),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF0EA5E9)), label: 'Accueil'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: Color(0xFF0EA5E9)), label: 'Leçons'),
            NavigationDestination(icon: Icon(Icons.record_voice_over_outlined), selectedIcon: Icon(Icons.record_voice_over, color: Color(0xFF0EA5E9)), label: 'Audio/Voix'),
            NavigationDestination(icon: Icon(Icons.video_collection_outlined), selectedIcon: Icon(Icons.video_collection, color: Color(0xFF0EA5E9)), label: 'Vidéos'),
            NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz, color: Color(0xFF0EA5E9)), label: 'Quiz'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF0EA5E9)), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 3. ÉCRAN 1 : ACCUEIL & GESTION DES RAPPELS
// =========================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final double dayProgress = (state.minutesStudiedToday / state.profile.dailyGoalMinutes).clamp(0.0, 1.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF0EA5E9),
                        radius: 24,
                        child: Text(
                          state.profile.name.isNotEmpty ? state.profile.name.substring(0, 1).toUpperCase() : 'E',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(state.currentCefrLevel, style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.alarm_add_rounded, color: Color(0xFFF59E0B), size: 28),
                    tooltip: 'Gérer les rappels',
                    onPressed: () => _showReminderManagerDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0284C7).withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1000&q=80',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (c, e, s) => Container(color: const Color(0xFF1E293B)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [const Color(0xFF0F172A).withOpacity(0.92), const Color(0xFF0F172A).withOpacity(0.4), Colors.transparent],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(16)),
                            child: Text('🔥 SÉRIE DE ${state.streakDays} JOURS', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                          const SizedBox(height: 8),
                          const Text('Pratiquez l\'anglais naturellement', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${state.totalXP} points XP • Objectif : ${state.profile.targetGoal}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Objectif d\'étude du jour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${state.minutesStudiedToday} / ${state.profile.dailyGoalMinutes} min', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: dayProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF0EA5E9)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 30),
                  label: const Text('COMMENCER À APPRENDRE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  onPressed: () => MainNavigationScreen.of(context)?.navigateToTab(1),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Activités Immédiates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _homeActionTile(
                    icon: Icons.menu_book,
                    title: 'Leçons & Cours',
                    sub: '${state.completedLessons.length} terminées',
                    color: const Color(0xFF38BDF8),
                    onTap: () => MainNavigationScreen.of(context)?.navigateToTab(1),
                  ),
                  _homeActionTile(
                    icon: Icons.record_voice_over,
                    title: 'Speaking & Audio',
                    sub: 'Entraînement vocal',
                    color: const Color(0xFF10B981),
                    onTap: () => MainNavigationScreen.of(context)?.navigateToTab(2),
                  ),
                  _homeActionTile(
                    icon: Icons.play_circle_fill,
                    title: 'Vidéos de Cours',
                    sub: 'Lecteur éducatif',
                    color: const Color(0xFFA855F7),
                    onTap: () => MainNavigationScreen.of(context)?.navigateToTab(3),
                  ),
                  _homeActionTile(
                    icon: Icons.quiz,
                    title: 'Quiz & Scores',
                    sub: 'Tous les niveaux',
                    color: const Color(0xFFF59E0B),
                    onTap: () => MainNavigationScreen.of(context)?.navigateToTab(4),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _homeActionTile({required IconData icon, required String title, required String sub, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.2), radius: 22, child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  static void _showReminderManagerDialog(BuildContext context) {
    final state = AppState.instance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.alarm_on, color: Color(0xFFF59E0B)),
                          SizedBox(width: 10),
                          Text('Mes Rappels d\'Étude', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF0EA5E9), size: 28),
                        onPressed: () async {
                          final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (pickedTime != null) {
                            final newRem = ReminderItem(
                              id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
                              time: pickedTime,
                              days: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
                              label: 'Pratique quotidienne En-Speaking',
                            );
                            state.addOrUpdateReminder(newRem);
                            setModalState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Activez ou désactivez vos rappels selon vos disponibilités :', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  const SizedBox(height: 16),
                  ...state.reminders.map((rem) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: rem.isEnabled ? const Color(0xFF0EA5E9).withOpacity(0.4) : Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Switch(
                              value: rem.isEnabled,
                              activeColor: const Color(0xFF0EA5E9),
                              onChanged: (val) {
                                state.toggleReminder(rem.id);
                                setModalState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${rem.time.hour.toString().padLeft(2, '0')}:${rem.time.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: rem.isEnabled ? Colors.white : Colors.white38),
                                  ),
                                  Text(rem.label, style: TextStyle(fontSize: 12, color: rem.isEnabled ? const Color(0xFF38BDF8) : Colors.white24)),
                                  Text(rem.days.join(', '), style: const TextStyle(fontSize: 11, color: Colors.white54)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                state.deleteReminder(rem.id);
                                setModalState(() {});
                              },
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rappels d\'apprentissage configurés avec succès !')),
                        );
                      },
                      child: const Text('ENREGISTRER & FERMER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// =========================================================================
// 4. ÉCRAN 2 : LEÇONS D'APPRENTISSAGE INTERACTIVES
// =========================================================================

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String selectedFilter = 'Toutes';

  final List<Map<String, dynamic>> lessonCatalog = [
    {
      'id': 'lesson_intro',
      'title': 'Salutations & Présentations Professionnelles',
      'category': 'Vocabulaire',
      'xp': 40,
      'duration': '8 min',
      'vocab': [
        {'en': 'Pleased to meet you', 'fr': 'Ravi de faire votre connaissance'},
        {'en': 'What line of work are you in?', 'fr': 'Dans quel domaine travaillez-vous ?'},
        {'en': 'I specialize in digital transformation', 'fr': 'Je me spécialise dans la transformation numérique'},
      ],
      'grammar': 'Utilisez le présent simple pour exprimer votre fonction et vos responsabilités habituelles ("I work as a manager").',
      'exercise': 'Comment dit-on "Ravi de vous rencontrer" de manière soignée ?\n-> Réponse : "Pleased to meet you".',
    },
    {
      'id': 'lesson_pres_perf',
      'title': 'Maîtriser le Present Perfect en Situation',
      'category': 'Grammaire',
      'xp': 50,
      'duration': '12 min',
      'vocab': [
        {'en': 'Already', 'fr': 'Déjà (action accomplie)'},
        {'en': 'Yet', 'fr': 'Encore / Déjà (négatif ou interrogatif)'},
        {'en': 'Achieve goals', 'fr': 'Atteindre ses objectifs'},
      ],
      'grammar': 'Structure : HAVE / HAS + Participe Passé. Règle : sert à exprimer une expérience de vie ou une action passée liée au présent.',
      'exercise': 'Complétez : "I have ____ (complete) the quarterly report." -> "completed".',
    },
    {
      'id': 'lesson_business',
      'title': 'Anglais Business : Réunions & Négociations',
      'category': 'Business',
      'xp': 60,
      'duration': '15 min',
      'vocab': [
        {'en': 'To streamline', 'fr': 'Optimiser et fluidifier'},
        {'en': 'To reach consensus', 'fr': 'Parvenir à un accord mutuel'},
        {'en': 'Action items', 'fr': 'Plan d\'actions concrètes'},
      ],
      'grammar': 'Utilisation des formes modales de politesse : "Could you clarify the budget schedule?"',
      'exercise': 'Que signifie "Action items" ? -> La liste des tâches convenues en fin de réunion.',
    },
    {
      'id': 'lesson_idioms',
      'title': 'Expressions Idiomatiques Indispensables',
      'category': 'Expressions',
      'xp': 50,
      'duration': '10 min',
      'vocab': [
        {'en': 'Piece of cake', 'fr': 'Très facile / Un jeu d\'enfant'},
        {'en': 'Hit the nail on the head', 'fr': 'Avoir parfaitement vu juste'},
        {'en': 'Back to the drawing board', 'fr': 'Repartir de zéro avec une nouvelle approche'},
      ],
      'grammar': 'Les idiomes ne se traduisent pas mot à mot mais reflètent la maîtrise naturelle de la langue parlée.',
      'exercise': 'Traduisez : "That negotiation was a piece of cake!" -> "Cette négociation était un jeu d\'enfant !"',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    final filtered = selectedFilter == 'Toutes'
        ? lessonCatalog
        : lessonCatalog.where((l) => l['category'] == selectedFilter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PROGRAMME PÉDAGOGIQUE', style: TextStyle(color: Color(0xFF0EA5E9), letterSpacing: 1.1, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              const Text('Leçons & Fiches Pratiques', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Toutes', 'Vocabulaire', 'Grammaire', 'Business', 'Expressions'].map((cat) {
                    final isSel = selectedFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: const Color(0xFF0EA5E9),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                        onSelected: (_) => setState(() => selectedFilter = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: state,
            builder: (context, _) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final lesson = filtered[i];
                  final isDone = state.completedLessons.contains(lesson['id']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDone ? const Color(0xFF10B981).withOpacity(0.5) : Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                              child: Text(lesson['category'], style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            Row(
                              children: [
                                Text('+${lesson['xp']} XP', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 8),
                                Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? const Color(0xFF10B981) : Colors.white30, size: 20),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(lesson['title'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        const Text('Vocabulaire clé :', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        ...((lesson['vocab'] as List<Map<String, String>>).map((v) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('• ${v['en']} : ${v['fr']}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                            ))),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                          child: Text('Règle : ${lesson['grammar']}', style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.white60)),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDone ? const Color(0xFF1E293B) : const Color(0xFF0EA5E9),
                              side: BorderSide(color: isDone ? const Color(0xFF10B981) : Colors.transparent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              state.completeLesson(lesson['id'], lesson['xp']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Félicitations ! Leçon "${lesson['title']}" validée (+${lesson['xp']} XP)')),
                              );
                            },
                            child: Text(
                              isDone ? 'LEÇON TERMINÉE ✓' : 'MARQUER COMME TERMINÉE (+${lesson['xp']} XP)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDone ? const Color(0xFF10B981) : Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// 5. ÉCRAN 3 : LECTURES AUDIO & ATELIER DE SPEAKING
// =========================================================================

class SpeakingAndAudioScreen extends StatefulWidget {
  const SpeakingAndAudioScreen({super.key});

  @override
  State<SpeakingAndAudioScreen> createState() => _SpeakingAndAudioScreenState();
}

class _SpeakingAndAudioScreenState extends State<SpeakingAndAudioScreen> {
  int currentAudioIdx = 0;
  bool isAudioPlaying = false;
  double playbackRate = 1.0;
  double audioProgress = 0.0;
  Timer? audioTimer;

  bool isVoiceRecording = false;
  bool isVoiceAnalyzed = false;
  int voiceScore = 0;
  String voiceFeedback = "Écoutez la phrase, puis appuyez sur le micro pour vous enregistrer.";
  Timer? waveTimer;
  double waveScale = 1.0;

  final List<Map<String, String>> audioLessons = [
    {
      'title': 'Prononciation : Opportunités et Ambitions',
      'en': 'English provides direct access to international career breakthroughs.',
      'fr': 'L\'anglais offre un accès direct aux percées de carrière internationales.',
      'phonetics': 'ˈɪŋ.ɡlɪʃ prəˈvaɪdz dɪˈrɛkt ˈæk.sɛs tuː ˌɪn.təˈnæʃ.ən.əl kəˈrɪər ˈbreɪkˌθruːz',
    },
    {
      'title': 'Expression : Poser une question en réunion',
      'en': 'Could you please elaborate on the budget estimates for this quarter?',
      'fr': 'Pourriez-vous détailler les prévisions budgétaires pour ce trimestre ?',
      'phonetics': 'kʊd juː pliːz iˈlæb.ə.reɪt ɒn ðə ˈbʌdʒ.ɪt ˈɛs.tɪ.meɪts fɔːr ðɪs ˈkwɔː.tər',
    },
    {
      'title': 'Conviction : Présenter sa vision d\'équipe',
      'en': 'I am absolutely confident that our strategic teamwork will succeed.',
      'fr': 'Je suis absolument convaincu que notre travail d\'équipe réussira.',
      'phonetics': 'aɪ æm ˌæb.səˈluːt.li ˈkɒn.fɪ.dənt ðæt ˈaʊər strəˈtiː.dʒɪk ˈtiːm.wɜːk wɪl səkˈsiːd',
    },
  ];

  void toggleAudioPlay() {
    setState(() => isAudioPlaying = !isAudioPlaying);
    if (isAudioPlaying) {
      audioTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted) return;
        setState(() {
          audioProgress += (0.02 * playbackRate);
          if (audioProgress >= 1.0) {
            audioProgress = 0.0;
            isAudioPlaying = false;
            audioTimer?.cancel();
          }
        });
      });
    } else {
      audioTimer?.cancel();
    }
  }

  void startVoiceEvaluation() {
    setState(() {
      isVoiceRecording = true;
      isVoiceAnalyzed = false;
      voiceFeedback = "Enregistrement en direct... Parlez clairement.";
    });

    waveTimer = Timer.periodic(const Duration(milliseconds: 140), (t) {
      if (!mounted) return;
      setState(() => waveScale = 0.85 + Random().nextDouble() * 0.45);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      waveTimer?.cancel();
      final score = 92 + Random().nextInt(8);
      setState(() {
        isVoiceRecording = false;
        isVoiceAnalyzed = true;
        voiceScore = score;
        voiceFeedback = "Excellente prononciation ! Fluidité et accent bien maîtrisés (Score : $score%).";
      });
      AppState.instance.totalXP += 25;
    });
  }

  @override
  void dispose() {
    audioTimer?.cancel();
    waveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = audioLessons[currentAudioIdx];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AUDIO & PRONONCIATION', style: TextStyle(color: Color(0xFF0EA5E9), letterSpacing: 1.1, fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Color(0xFF0EA5E9)),
                    onPressed: () {
                      setState(() {
                        currentAudioIdx = (currentAudioIdx - 1 + audioLessons.length) % audioLessons.length;
                        audioProgress = 0.0;
                        isAudioPlaying = false;
                        isVoiceAnalyzed = false;
                      });
                    },
                  ),
                  Text('${currentAudioIdx + 1}/${audioLessons.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Color(0xFF0EA5E9)),
                    onPressed: () {
                      setState(() {
                        currentAudioIdx = (currentAudioIdx + 1) % audioLessons.length;
                        audioProgress = 0.0;
                        isAudioPlaying = false;
                        isVoiceAnalyzed = false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(item['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Text(item['en']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
                const SizedBox(height: 8),
                Text(item['phonetics']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text('« ${item['fr']} »', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.white60)),
                const SizedBox(height: 18),
                LinearProgressIndicator(value: audioProgress, minHeight: 6, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF0EA5E9))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.white10),
                      onPressed: () {
                        setState(() {
                          if (playbackRate == 1.0) playbackRate = 0.75;
                          else if (playbackRate == 0.75) playbackRate = 1.25;
                          else playbackRate = 1.0;
                        });
                      },
                      child: Text('${playbackRate}x', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF0EA5E9),
                      child: IconButton(
                        icon: Icon(isAudioPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
                        onPressed: toggleAudioPlay,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay, color: Colors.white70),
                      onPressed: () {
                        setState(() => audioProgress = 0.0);
                        if (!isAudioPlaying) toggleAudioPlay();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Atelier d\'Élocution & Répétition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
            child: Row(
              children: [
                Icon(isVoiceAnalyzed ? Icons.verified : Icons.mic_none, color: isVoiceAnalyzed ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                const SizedBox(width: 12),
                Expanded(child: Text(voiceFeedback, style: const TextStyle(fontSize: 13, color: Colors.white70))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Transform.scale(
                  scale: isVoiceRecording ? waveScale : 1.0,
                  child: GestureDetector(
                    onTap: isVoiceRecording ? null : startVoiceEvaluation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isVoiceRecording ? Colors.redAccent : const Color(0xFF0EA5E9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: (isVoiceRecording ? Colors.redAccent : const Color(0xFF0EA5E9)).withOpacity(0.4), blurRadius: 20, spreadRadius: 4),
                        ],
                      ),
                      child: Icon(isVoiceRecording ? Icons.graphic_eq : Icons.mic, color: Colors.white, size: 38),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(isVoiceRecording ? 'Analyse vocale en cours...' : 'Appuyez pour enregistrer votre voix', style: const TextStyle(fontSize: 13, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 6. ÉCRAN 4 : LECTURES VIDÉO ÉDUCATIVES
// =========================================================================

class VideoEducationScreen extends StatefulWidget {
  const VideoEducationScreen({super.key});

  @override
  State<VideoEducationScreen> createState() => _VideoEducationScreenState();
}

class _VideoEducationScreenState extends State<VideoEducationScreen> {
  int activeVideoIdx = 0;
  bool isPlaying = false;
  bool isFullscreen = false;
  bool showSubtitles = true;
  double currentProgress = 0.35;
  Timer? videoTimer;

  final List<Map<String, dynamic>> videoLessons = [
    {
      'id': 'vid_1',
      'title': 'Mastering English Conversations & Confident Body Language',
      'category': 'Speaking Pro',
      'duration': '10:45',
      'subtitles': 'When introducing yourself, always maintain eye contact and state your goals clearly.',
    },
    {
      'id': 'vid_2',
      'title': 'Business English Negotiations & Deal Closing Strategies',
      'category': 'Carrière',
      'duration': '14:20',
      'subtitles': 'Using conditional forms softens the negotiation tone and builds constructive trust with clients.',
    },
  ];

  @override
  void initState() {
    super.initState();
    final vidId = videoLessons[activeVideoIdx]['id'] as String;
    currentProgress = AppState.instance.videoProgressMap[vidId] ?? 0.0;
  }

  void togglePlay() {
    setState(() => isPlaying = !isPlaying);
    if (isPlaying) {
      videoTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
        if (!mounted) return;
        setState(() {
          currentProgress += 0.005;
          if (currentProgress >= 1.0) {
            currentProgress = 0.0;
            isPlaying = false;
            videoTimer?.cancel();
          }
        });
        final vidId = videoLessons[activeVideoIdx]['id'] as String;
        AppState.instance.saveVideoProgress(vidId, currentProgress);
      });
    } else {
      videoTimer?.cancel();
    }
  }

  @override
  void dispose() {
    videoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = videoLessons[activeVideoIdx];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VIDÉOTHÈQUE ÉDUCATIVE', style: TextStyle(color: Color(0xFF0EA5E9), letterSpacing: 1.1, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          const Text('Vidéos de Cours en Situation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 18),
          Container(
            height: isFullscreen ? 320 : 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.movie_creation_outlined, size: 70, color: Colors.white.withOpacity(0.15)),
                ),
                if (showSubtitles)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 48, left: 16, right: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.75), borderRadius: BorderRadius.circular(8)),
                      child: Text(video['subtitles'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.amberAccent)),
                    ),
                  ),
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF0EA5E9).withOpacity(0.8),
                    radius: 30,
                    child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                      onPressed: togglePlay,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
                    child: Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                            child: Slider(
                              value: currentProgress.clamp(0.0, 1.0),
                              activeColor: const Color(0xFF0EA5E9),
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                setState(() => currentProgress = val);
                                final vidId = video['id'] as String;
                                AppState.instance.saveVideoProgress(vidId, val);
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(showSubtitles ? Icons.subtitles : Icons.subtitles_off, color: Colors.white70, size: 20),
                          onPressed: () => setState(() => showSubtitles = !showSubtitles),
                        ),
                        IconButton(
                          icon: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white70, size: 20),
                          onPressed: () => setState(() => isFullscreen = !isFullscreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(video['title'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Catégorie : ${video['category']} • Durée : ${video['duration']}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 24),
          const Text('Autres Vidéos du Programme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ...List.generate(videoLessons.length, (idx) {
            final v = videoLessons[idx];
            final isCurrent = idx == activeVideoIdx;
            final double prog = (AppState.instance.videoProgressMap[v['id']] ?? 0.0) * 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isCurrent ? const Color(0xFF0EA5E9) : Colors.white10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCurrent ? const Color(0xFF0EA5E9) : Colors.white10,
                  child: Icon(isCurrent ? Icons.play_arrow : Icons.videocam, color: Colors.white),
                ),
                title: Text(v['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text('Reprendre à ${prog.toInt()}% • ${v['duration']}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
                onTap: () {
                  setState(() {
                    activeVideoIdx = idx;
                    currentProgress = AppState.instance.videoProgressMap[v['id']] ?? 0.0;
                    isPlaying = false;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =========================================================================
// 7. ÉCRAN 5 : QUIZ INTERACTIFS AVEC GESTION DES NIVEAUX
// =========================================================================

class QuizInteractiveScreen extends StatefulWidget {
  const QuizInteractiveScreen({super.key});

  @override
  State<QuizInteractiveScreen> createState() => _QuizInteractiveScreenState();
}

class _QuizInteractiveScreenState extends State<QuizInteractiveScreen> {
  String selectedLevel = 'Débutant';
  int questionIdx = 0;
  int currentScore = 0;
  int? selectedOption;
  bool isEvaluated = false;
  bool isQuizCompleted = false;

  final Map<String, List<Map<String, dynamic>>> quizBank = {
    'Débutant': [
      {
        'question': 'Quelle phrase est correcte au présent simple ?',
        'options': ['She speak English fluently.', 'She speaks English fluently.', 'She speaking English fluently.', 'She is speak English.'],
        'answer': 1,
        'expl': 'À la 3ème personne du singulier (He/She/It), on ajoute un "s" au verbe.',
      },
      {
        'question': 'Comment demande-t-on poliment son chemin ?',
        'options': ['Where is station?', 'Could you tell me how to get to the station?', 'Give me the direction now.', 'Station where please?'],
        'answer': 1,
        'expl': '"Could you tell me..." est la formule de politesse standard recommandée.',
      },
      {
        'question': 'Que signifie le mot "Deadline" ?',
        'options': ['Une ligne rouge de sécurité', 'Une date limite impérative', 'Un appel téléphonique', 'Une fin de réunion'],
        'answer': 1,
        'expl': 'Deadline désigne la date ou l\'heure limite pour accomplir une tâche.',
      },
    ],
    'Intermédiaire': [
      {
        'question': 'Choisissez la bonne phrase au Present Perfect :',
        'options': ['I have visited London yesterday.', 'I visited London three times in my life.', 'I have visited London three times.', 'I was visited London.'],
        'answer': 2,
        'expl': 'On utilise le Present Perfect pour relater une expérience de vie sans date révolue.',
      },
      {
        'question': 'Que signifie "To reach a consensus" ?',
        'options': ['Prendre une décision unilatérale', 'Parvenir à un accord mutuel', 'Reporter une réunion', 'Présenter son budget'],
        'answer': 1,
        'expl': 'Consensus signifie l\'accord de toutes les parties prenantes.',
      },
      {
        'question': 'Complétez : "If I ____ you, I would take that opportunity."',
        'options': ['am', 'were', 'will be', 'had been'],
        'answer': 1,
        'expl': 'Au conditionnel de type 2 (hypothèse), on utilise "were" pour toutes les personnes.',
      },
    ],
    'Avancé': [
      {
        'question': 'Que signifie l\'idiome "To play devil\'s advocate" ?',
        'options': ['Défendre un point de vue opposé pour stimuler le débat', 'Accuser quelqu\'un injustement', 'Rompre un contrat légal', 'Négocier à perte'],
        'answer': 0,
        'expl': 'Se faire l\'avocat du diable consiste à tester la robustesse d\'un argument.',
      },
      {
        'question': 'Identifiez l\'inversion emphatique correcte :',
        'options': ['Rarely I have seen such dedication.', 'Rarely have I seen such dedication.', 'Rarely I saw such dedication.', 'Rarely did I seen such dedication.'],
        'answer': 1,
        'expl': 'Après un adverbe négatif/restrictif (Rarely, Seldom, Never), on inverse le sujet et l\'auxiliaire.',
      },
    ],
  };

  void onSelectOption(int index) {
    if (isEvaluated) return;
    setState(() {
      selectedOption = index;
      isEvaluated = true;
      final qList = quizBank[selectedLevel]!;
      if (index == qList[questionIdx]['answer']) {
        currentScore++;
      }
    });
  }

  void nextQuestion() {
    final qList = quizBank[selectedLevel]!;
    if (questionIdx < qList.length - 1) {
      setState(() {
        questionIdx++;
        selectedOption = null;
        isEvaluated = false;
      });
    } else {
      AppState.instance.recordQuizResult(
        title: "Quiz $selectedLevel",
        level: selectedLevel,
        score: currentScore,
        total: qList.length,
      );
      setState(() {
        isQuizCompleted = true;
      });
    }
  }

  void resetQuiz() {
    setState(() {
      questionIdx = 0;
      currentScore = 0;
      selectedOption = null;
      isEvaluated = false;
      isQuizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final qList = quizBank[selectedLevel]!;

    if (isQuizCompleted) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xFF10B981),
                child: Icon(Icons.emoji_events, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('Quiz Terminé !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Text('Votre score : $currentScore sur ${qList.length}', style: const TextStyle(fontSize: 18, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Vous remportez +${currentScore * 25} points d\'XP !', style: const TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: resetQuiz,
                  child: const Text('RECOMMENCER LE QUIZ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final q = qList[questionIdx];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Débutant', 'Intermédiaire', 'Avancé'].map((lvl) {
              final isSel = selectedLevel == lvl;
              return ChoiceChip(
                label: Text(lvl),
                selected: isSel,
                selectedColor: const Color(0xFF0EA5E9),
                backgroundColor: const Color(0xFF1E293B),
                labelStyle: TextStyle(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                onSelected: (_) {
                  setState(() {
                    selectedLevel = lvl;
                    resetQuiz();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QUESTION ${questionIdx + 1}/${qList.length}', style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
              Text('Score : $currentScore pts', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(q['question'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 18),
          ...List.generate((q['options'] as List<String>).length, (index) {
            Color cardBg = const Color(0xFF1E293B);
            if (isEvaluated) {
              if (index == q['answer']) {
                cardBg = Colors.green.shade700;
              } else if (selectedOption == index) {
                cardBg = Colors.red.shade700;
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelectOption(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 12, backgroundColor: Colors.white10, child: Text(String.fromCharCode(65 + index), style: const TextStyle(color: Colors.white, fontSize: 11))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(q['options'][index], style: const TextStyle(fontSize: 14, color: Colors.white))),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (isEvaluated) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(q['expl'], style: const TextStyle(fontSize: 12, color: Colors.white70))),
                ],
              ),
            ),
          ],
          const Spacer(),
          if (isEvaluated)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: nextQuestion,
                child: Text(questionIdx == qList.length - 1 ? 'TERMINER ET ENREGISTRER LE SCORE' : 'QUESTION SUIVANTE', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// =========================================================================
// 8. ÉCRAN 6 : ESPACE APPRENANT / PROFIL & HISTORIQUE
// =========================================================================

class LearnerProfileScreen extends StatelessWidget {
  const LearnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xFF0EA5E9),
                      child: Text(
                        state.profile.name.isNotEmpty ? state.profile.name.substring(0, 1).toUpperCase() : 'E',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(state.profile.email, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Text(state.currentCefrLevel, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0EA5E9)),
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _statBox(title: 'Points XP', value: '${state.totalXP}', color: const Color(0xFF0EA5E9))),
                  const SizedBox(width: 12),
                  Expanded(child: _statBox(title: 'Série Active', value: '${state.streakDays} Jours', color: const Color(0xFFF59E0B))),
                  const SizedBox(width: 12),
                  Expanded(child: _statBox(title: 'Leçons', value: '${state.completedLessons.length}', color: const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Trophées Débloqués', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              _badgeItem(Icons.school, 'Étudiant Régulier', 'A validé ses 2 premières leçons', state.completedLessons.length >= 2),
              _badgeItem(Icons.emoji_events, 'Champion des Quiz', 'A cumulé plus de 200 points XP', state.totalXP >= 200),
              _badgeItem(Icons.record_voice_over, 'Orateur Professionnel', 'A complété des entraînements oraux', true),
              const SizedBox(height: 24),
              const Text('Historique Récent des Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              ...state.quizHistory.map((h) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Niveau : ${h.level}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                          ],
                        ),
                        Text('${h.score}/${h.total} (${(h.score / h.total * 100).toInt()}%)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  static Widget _statBox({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }

  static Widget _badgeItem(IconData icon, String title, String sub, bool unlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: unlocked ? const Color(0xFFF59E0B).withOpacity(0.5) : Colors.white10)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: unlocked ? const Color(0xFFF59E0B) : Colors.white10, radius: 22, child: Icon(icon, color: unlocked ? Colors.black : Colors.white38)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: unlocked ? Colors.white : Colors.white38)),
                Text(sub, style: TextStyle(fontSize: 12, color: unlocked ? Colors.white60 : Colors.white24)),
              ],
            ),
          ),
          Icon(unlocked ? Icons.check_circle : Icons.lock, color: unlocked ? const Color(0xFF10B981) : Colors.white24),
        ],
      ),
    );
  }

  static void _showEditProfileDialog(BuildContext context) {
    final state = AppState.instance;
    final nameCtrl = TextEditingController(text: state.profile.name);
    final goalCtrl = TextEditingController(text: state.profile.targetGoal);
    int targetMin = state.profile.dailyGoalMinutes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Modifier mon Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nom complet', labelStyle: TextStyle(color: Color(0xFF0EA5E9))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: goalCtrl,
                  decoration: const InputDecoration(labelText: 'Objectif d\'anglais', labelStyle: TextStyle(color: Color(0xFF0EA5E9))),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Temps d\'étude quotidien :'),
                    DropdownButton<int>(
                      value: targetMin,
                      dropdownColor: const Color(0xFF1E293B),
                      items: [10, 15, 20, 30, 45].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => targetMin = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(child: const Text('Annuler', style: TextStyle(color: Colors.white54)), onPressed: () => Navigator.pop(ctx)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9)),
              onPressed: () {
                state.updateProfile(name: nameCtrl.text.trim(), targetGoal: goalCtrl.text.trim(), dailyGoal: targetMin, weeklyGoal: state.profile.weeklyGoalHours);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour !')));
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
