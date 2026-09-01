import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const EnSpeakingApp());
}

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

  UserProfile({
    required this.name,
    required this.email,
    required this.targetGoal,
    required this.dailyGoalMinutes,
  });
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  UserProfile profile = UserProfile(
    name: "Élisée Kikoli",
    email: "elisee@enspeaking.com",
    targetGoal: "Anglais Professionnel Fluide",
    dailyGoalMinutes: 20,
  );

  int totalXP = 240;
  int streakDays = 5;
  int minutesStudiedToday = 12;

  final Set<String> completedLessons = {'lesson_intro'};

  final List<QuizHistoryItem> quizHistory = [
    QuizHistoryItem(title: "Grammaire Initiale", level: "Débutant", score: 3, total: 3, date: DateTime.now()),
  ];

  final List<ReminderItem> reminders = [
    ReminderItem(
      id: 'rem_1',
      time: const TimeOfDay(hour: 19, minute: 30),
      days: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
      isEnabled: true,
      label: 'Session Quotidienne En-Speaking',
    ),
  ];

  void updateProfile(String name, String goal, int minutes) {
    profile.name = name;
    profile.targetGoal = goal;
    profile.dailyGoalMinutes = minutes;
    notifyListeners();
  }

  void completeLesson(String lessonId, int xpReward) {
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
      totalXP += xpReward;
      minutesStudiedToday += 8;
      notifyListeners();
    }
  }

  void recordQuiz(String title, String level, int score, int total) {
    quizHistory.insert(0, QuizHistoryItem(title: title, level: level, score: score, total: total, date: DateTime.now()));
    totalXP += (score * 20);
    minutesStudiedToday += 5;
    notifyListeners();
  }

  void toggleReminder(String id) {
    final r = reminders.firstWhere((item) => item.id == id);
    r.isEnabled = !r.isEnabled;
    notifyListeners();
  }

  void addReminder(ReminderItem rem) {
    reminders.add(rem);
    notifyListeners();
  }

  void deleteReminder(String id) {
    reminders.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  String get currentLevel {
    if (totalXP < 200) return "A1 Débutant";
    if (totalXP < 450) return "A2 Élémentaire";
    if (totalXP < 750) return "B1 Intermédiaire";
    if (totalXP < 1200) return "B2 Avancé";
    return "C1 Bilingue Expert";
  }

  double get overallProgress {
    return ((completedLessons.length * 20 + quizHistory.length * 15) / 150.0).clamp(0.1, 1.0);
  }
}

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

  void goToTab(int idx) => setState(() => _currentIndex = idx);

  final List<Widget> _pages = const [
    HomeScreen(),
    LessonsScreen(),
    SpeakingScreen(),
    VideoScreen(),
    QuizScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E293B),
          indicatorColor: const Color(0xFF0EA5E9).withOpacity(0.25),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF0EA5E9)), label: 'Accueil'),
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: Color(0xFF0EA5E9)), label: 'Leçons'),
            NavigationDestination(icon: Icon(Icons.record_voice_over_outlined), selectedIcon: Icon(Icons.record_voice_over, color: Color(0xFF0EA5E9)), label: 'Speaking'),
            NavigationDestination(icon: Icon(Icons.video_collection_outlined), selectedIcon: Icon(Icons.video_collection, color: Color(0xFF0EA5E9)), label: 'Vidéos'),
            NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz, color: Color(0xFF0EA5E9)), label: 'Quiz'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF0EA5E9)), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// 1. ACCUEIL
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
                        radius: 22,
                        child: Text(state.profile.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(state.currentLevel, style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.alarm, color: Color(0xFFF59E0B), size: 26),
                    onPressed: () => _openReminderDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1000&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [const Color(0xFF0F172A).withOpacity(0.92), Colors.transparent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                        child: Text('🔥 SÉRIE DE ${state.streakDays} JOURS', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                      const SizedBox(height: 6),
                      const Text('Parlez anglais naturellement', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${state.totalXP} points XP accumulés', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Objectif du jour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${state.minutesStudiedToday}/${state.profile.dailyGoalMinutes} min', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: dayProgress, minHeight: 6, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF0EA5E9))),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text('COMMENCER LES COURS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  onPressed: () => MainNavigationScreen.of(context)?.goToTab(1),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Activités Disponibles', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _actionCard(icon: Icons.menu_book, title: 'Leçons', sub: '${state.completedLessons.length} finies', color: const Color(0xFF38BDF8), onTap: () => MainNavigationScreen.of(context)?.goToTab(1))),
                  const SizedBox(width: 12),
                  Expanded(child: _actionCard(icon: Icons.record_voice_over, title: 'Speaking', sub: 'Prononciation', color: const Color(0xFF10B981), onTap: () => MainNavigationScreen.of(context)?.goToTab(2))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _actionCard({required IconData icon, required String title, required String sub, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  static void _openReminderDialog(BuildContext context) {
    final state = AppState.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(
        builder: (c, setS) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Rappels d\'apprentissage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_alarm, color: Color(0xFF0EA5E9)),
                    onPressed: () async {
                      final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (t != null) {
                        state.addReminder(ReminderItem(
                          id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
                          time: t,
                          days: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
                          label: 'Pratique de l\'anglais',
                        ));
                        setS(() {});
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...state.reminders.map((r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${r.time.hour.toString().padLeft(2, '0')}:${r.time.minute.toString().padLeft(2, '0')} - ${r.label}'),
                    subtitle: Text(r.days.join(', ')),
                    trailing: Switch(
                      value: r.isEnabled,
                      activeColor: const Color(0xFF0EA5E9),
                      onChanged: (_) {
                        state.toggleReminder(r.id);
                        setS(() {});
                      },
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. LEÇONS
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  final List<Map<String, dynamic>> lessonCatalog = const [
    {
      'id': 'lesson_intro',
      'title': 'Salutations et Présentation Professionnelle',
      'category': 'Vocabulaire',
      'xp': 40,
      'vocab': '• Pleased to meet you (Ravi de vous rencontrer)\n• What line of work are you in? (Dans quel domaine travaillez-vous ?)',
      'grammar': 'Présent Simple pour parler de sa profession ("I work as an engineer").',
    },
    {
      'id': 'lesson_pres_perf',
      'title': 'Le Present Perfect en Pratique',
      'category': 'Grammaire',
      'xp': 50,
      'vocab': '• Already (Déjà) • Yet (Pas encore) • So far (Jusqu\'ici)',
      'grammar': 'Have/Has + Participe passé pour relier le passé et le présent.',
    },
    {
      'id': 'lesson_business',
      'title': 'Négociations et Réunions d\'Équipe',
      'category': 'Business',
      'xp': 60,
      'vocab': '• To streamline (Optimiser) • Action items (Tâches à faire)',
      'grammar': 'Utilisez "Could you..." pour formuler des demandes polies en réunion.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: lessonCatalog.length,
        itemBuilder: (ctx, i) {
          final l = lessonCatalog[i];
          final isDone = state.completedLessons.contains(l['id']);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: isDone ? const Color(0xFF10B981) : Colors.white10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l['category'], style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('+${l['xp']} XP', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(l['vocab'], style: const TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                  child: Text('Règle : ${l['grammar']}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isDone ? const Color(0xFF1E293B) : const Color(0xFF0EA5E9), side: BorderSide(color: isDone ? const Color(0xFF10B981) : Colors.transparent)),
                    onPressed: () {
                      state.completeLesson(l['id'], l['xp']);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leçon validée (+${l['xp']} XP) !')));
                    },
                    child: Text(isDone ? 'COMPLÉTÉE ✓' : 'VALIDER LA LEÇON', style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? const Color(0xFF10B981) : Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 3. SPEAKING
class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  bool isRecording = false;
  String feedback = "Appuyez sur le micro et lisez la phrase.";
  int score = 0;

  final String phrase = "Mastering conversational English opens global career opportunities.";

  void record() {
    setState(() {
      isRecording = true;
      feedback = "Écoute en cours...";
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final finalScore = 93 + Random().nextInt(6);
      setState(() {
        isRecording = false;
        score = finalScore;
        feedback = "Très bonne prononciation et fluidité (Score : $finalScore%).";
      });
      AppState.instance.totalXP += 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PRATIQUE VOCALE', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Atelier de Speaking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.4))),
                child: Text(phrase, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Icon(score > 0 ? Icons.check_circle : Icons.mic_none, color: score > 0 ? Colors.greenAccent : const Color(0xFFF59E0B)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(feedback, style: const TextStyle(fontSize: 13, color: Colors.white70))),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: isRecording ? null : record,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: isRecording ? Colors.redAccent : const Color(0xFF0EA5E9),
              child: Icon(isRecording ? Icons.graphic_eq : Icons.mic, size: 38, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. VIDÉO
class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COURS VIDÉO', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Vidéothèque Interactive', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3))),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, size: 58, color: Color(0xFF0EA5E9)),
                  SizedBox(height: 8),
                  Text('Business English & Body Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 5. QUIZ
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQ = 0;
  int score = 0;
  int? selected;
  bool answered = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Quelle phrase utilise correctement le Present Perfect ?',
      'options': ['I have seen this movie yesterday.', 'I have already seen this movie.', 'I was seen this movie.', 'I saw this movie already.'],
      'answer': 1,
      'expl': '"Already" s\'emploie avec le Present Perfect pour une action passée liée au présent.',
    },
    {
      'question': 'Que signifie "To think outside the box" ?',
      'options': ['Penser de façon créative', 'Sortir d\'un bâtiment', 'Ranger une boîte', 'Fermer un dossier'],
      'answer': 0,
      'expl': 'Expression idiomatique désignant la réflexion créative.',
    },
  ];

  void pick(int idx) {
    if (answered) return;
    setState(() {
      selected = idx;
      answered = true;
      if (idx == questions[currentQ]['answer']) score++;
    });
  }

  void next() {
    if (currentQ < questions.length - 1) {
      setState(() {
        currentQ++;
        selected = null;
        answered = false;
      });
    } else {
      AppState.instance.recordQuiz("Quiz Général", "Tous niveaux", score, questions.length);
      setState(() {
        currentQ = 0;
        selected = null;
        answered = false;
        score = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz complété et enregistré dans votre profil !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QUESTION ${currentQ + 1}/${questions.length}', style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
              Text('Score : $score', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Text(q['question'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...List.generate((q['options'] as List<String>).length, (i) {
            Color c = const Color(0xFF1E293B);
            if (answered) {
              if (i == q['answer']) c = Colors.green.shade700;
              else if (selected == i) c = Colors.red.shade700;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => pick(i),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14)),
                  child: Text(q['options'][i], style: const TextStyle(fontSize: 14)),
                ),
              ),
            );
          }),
          const Spacer(),
          if (answered)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: next,
                child: Text(currentQ == questions.length - 1 ? 'TERMINER ET ENREGISTRER' : 'SUIVANT', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// 6. PROFIL
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: const Color(0xFF0EA5E9), child: Text(state.profile.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(state.currentLevel, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _statBox('XP Total', '${state.totalXP} pts')),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Série', '${state.streakDays} Jours')),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Leçons', '${state.completedLessons.length}')),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Historique des Quiz', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...state.quizHistory.map((h) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(h.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${h.score}/${h.total}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static Widget _statBox(String label, String val) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }
}
