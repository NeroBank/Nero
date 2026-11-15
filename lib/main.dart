import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color wine = Color(0xFF8E1019);
const Color deepWine = Color(0xFF57070D);
const Color gold = Color(0xFFD9A441);
const Color paper = Color(0xFFFFFBF6);

const List<String> bibleBooks = [
  'Genesis','Exodus','Leviticus','Numbers','Deuteronomy','Joshua','Judges','Ruth',
  '1 Samuel','2 Samuel','1 Kings','2 Kings','1 Chronicles','2 Chronicles','Ezra',
  'Nehemiah','Esther','Job','Psalms','Proverbs','Ecclesiastes','Song of Solomon',
  'Isaiah','Jeremiah','Lamentations','Ezekiel','Daniel','Hosea','Joel','Amos',
  'Obadiah','Jonah','Micah','Nahum','Habakkuk','Zephaniah','Haggai','Zechariah',
  'Malachi','Matthew','Mark','Luke','John','Acts','Romans','1 Corinthians',
  '2 Corinthians','Galatians','Ephesians','Philippians','Colossians',
  '1 Thessalonians','2 Thessalonians','1 Timothy','2 Timothy','Titus','Philemon',
  'Hebrews','James','1 Peter','2 Peter','1 John','2 John','3 John','Jude','Revelation'
];

SupabaseClient? get sb => Supabase.instance.isInitialized ? Supabase.instance.client : null;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const anon = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isNotEmpty && anon.isNotEmpty) {
    await Supabase.initialize(url: url, anonKey: anon);
  }
  runApp(const NeroApp());
}

class NeroApp extends StatelessWidget {
  const NeroApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NERO',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: wine, primary: wine, secondary: gold),
      appBarTheme: const AppBarTheme(backgroundColor: wine, foregroundColor: Colors.white, centerTitle: true),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFFF8F1EC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    if (sb == null) return const SetupScreen();
    return StreamBuilder<AuthState>(
      stream: sb!.auth.onAuthStateChange,
      builder: (context, snap) {
        final user = sb!.auth.currentUser;
        if (user == null) return const WelcomeScreen();
        return NeroHome(user: user);
      },
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const NeroMark(size: 100), const SizedBox(height: 18),
        const Text('NERO', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: wine)),
        const SizedBox(height: 12),
        const Text('Supabase is not configured yet. Add your Supabase project URL and publishable/anon key to the GitHub Actions secrets, then build with the workflow.', textAlign: TextAlign.center),
      ]),
    )),
  );
}

class NeroMark extends StatelessWidget {
  final double size;
  const NeroMark({super.key, this.size = 62});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .18),
    child: Image.asset('assets/icon/nero_launcher.png', width: size, height: size, fit: BoxFit.cover),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(fit: StackFit.expand, children: [
      Image.asset('assets/images/bible_banner.png', fit: BoxFit.cover),
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(.12), deepWine.withOpacity(.96)], stops: const [0.15, 1]))),
      SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 32, 26, 30),
        child: Column(children: [
          const Spacer(),
          const NeroMark(size: 104),
          const SizedBox(height: 12),
          const Text('NERO', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 3)),
          const Text('Read, Reflect & Grow', style: TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic)),
          const SizedBox(height: 14),
          const Text("Discover God's Word. Change Your Life.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 34),
          _WideButton(text: 'Create Account', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthForm(register: true)))),
          const SizedBox(height: 12),
          _WideButton(text: 'Sign In', light: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthForm(register: false)))),
          const SizedBox(height: 18),
          TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NeroHome(guest: true))), child: const Text('Continue as Guest', style: TextStyle(color: Colors.white))),
        ]),
      )),
    ]),
  );
}

class _WideButton extends StatelessWidget {
  final String text; final VoidCallback onTap; final bool light;
  const _WideButton({required this.text, required this.onTap, this.light = false});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 54, child: FilledButton(
    style: FilledButton.styleFrom(backgroundColor: light ? Colors.white : const Color(0xFFC51D25), foregroundColor: light ? wine : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    onPressed: onTap, child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  ));
}

class AuthForm extends StatefulWidget {
  final bool register;
  const AuthForm({super.key, required this.register});
  @override
  State<AuthForm> createState() => _AuthFormState();
}
class _AuthFormState extends State<AuthForm> {
  final name = TextEditingController(), email = TextEditingController(), password = TextEditingController(), confirm = TextEditingController();
  bool busy = false, obscure = true;
  String? error;
  @override
  void dispose() { name.dispose(); email.dispose(); password.dispose(); confirm.dispose(); super.dispose(); }
  Future<void> submit() async {
    if (sb == null) { setState(() => error = 'Online sign-in is not configured.'); return; }
    if (widget.register && password.text != confirm.text) { setState(() => error = 'Passwords do not match.'); return; }
    if (password.text.length < 6) { setState(() => error = 'Password must contain at least 6 characters.'); return; }
    setState(() { busy = true; error = null; });
    try {
      if (widget.register) {
        final res = await sb!.auth.signUp(email: email.text.trim(), password: password.text, data: {'full_name': name.text.trim()});
        if (!mounted) return;
        if (res.session == null) {
          _message('Account request received. Check your email to verify your account before signing in.');
          Navigator.pop(context);
        } else {
          _message('Your account has been created.');
          Navigator.pop(context);
        }
      } else {
        await sb!.auth.signInWithPassword(email: email.text.trim(), password: password.text);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => NeroHome(user: sb!.auth.currentUser)),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'Unable to connect. Check your internet connection and try again.');
    } finally { if (mounted) setState(() => busy = false); }
  }
  void _message(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.register ? 'Create Account' : 'Sign In')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Center(child: NeroMark(size: 76)), const SizedBox(height: 20),
      if (widget.register) ...[
        TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: 'Full Name')),
        const SizedBox(height: 12),
      ],
      TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), hintText: 'Email Address')),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: obscure, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), hintText: 'Password', suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)))),
      if (widget.register) ...[
        const SizedBox(height: 12),
        TextField(controller: confirm, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), hintText: 'Confirm Password')),
      ],
      if (!widget.register) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () async {
        if (email.text.trim().isEmpty) { setState(() => error = 'Enter your email address first.'); return; }
        try { await sb!.auth.resetPasswordForEmail(email.text.trim()); if (mounted) _message('Password reset email sent.'); } catch (_) { if (mounted) setState(() => error = 'Could not send reset email.'); }
      }, child: const Text('Forgot Password?'))),
      if (error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 12),
      _WideButton(text: busy ? 'Please wait...' : (widget.register ? 'Register' : 'Sign In'), onTap: busy ? () {} : submit),
      const SizedBox(height: 14),
      Center(child: TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthForm(register: !widget.register))), child: Text(widget.register ? 'Already have an account? Sign In' : "Don't have an account? Create Account"))),
    ]),
  );
}

class NeroHome extends StatefulWidget {
  final User? user; final bool guest;
  const NeroHome({super.key, this.user, this.guest = false});
  @override
  State<NeroHome> createState() => _NeroHomeState();
}
class _NeroHomeState extends State<NeroHome> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      _Dashboard(onRead: () => setState(() => tab = 1)),
      const BibleLibrary(),
      const SavedVerses(),
      AccountPage(guest: widget.guest),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(10), child: NeroMark(size: 36)),
        title: const Text('NERO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [IconButton(onPressed: () => showSearch(context: context, delegate: BibleSearchDelegate()), icon: const Icon(Icons.search))],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i),
        indicatorColor: gold.withOpacity(.25),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Bible'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  final VoidCallback onRead;
  const _Dashboard({required this.onRead});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(alignment: Alignment.bottomLeft, children: [
      Image.asset('assets/images/bible_banner.png', height: 190, width: double.infinity, fit: BoxFit.cover),
      Container(height: 190, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, deepWine.withOpacity(.9)]))),
      const Padding(padding: EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('WELCOME TO NERO', style: TextStyle(color: gold, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        SizedBox(height: 6), Text('Read, Reflect & Grow', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        Text('Your daily companion in God’s Word', style: TextStyle(color: Colors.white)),
      ])),
    ])),
    const SizedBox(height: 18),
    const Text('VERSE OF THE DAY', style: TextStyle(color: wine, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    const SizedBox(height: 8),
    Card(color: const Color(0xFFFFF1E4), elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text('“The LORD is my shepherd; I shall not want.”', style: TextStyle(fontSize: 21, height: 1.45, fontWeight: FontWeight.w600, color: deepWine)),
      SizedBox(height: 8), Text('PSALM 23:1', style: TextStyle(color: wine, fontWeight: FontWeight.bold)),
    ]))),
    const SizedBox(height: 18),
    const Text('QUICK ACCESS', style: TextStyle(color: wine, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    const SizedBox(height: 10),
    Row(children: [
      Expanded(child: _QuickTile(icon: Icons.menu_book, title: 'Read Bible', onTap: onRead)),
      const SizedBox(width: 10),
      Expanded(child: _QuickTile(icon: Icons.search, title: 'Search', onTap: () => showSearch(context: context, delegate: BibleSearchDelegate()))),
    ]),
    const SizedBox(height: 18),
    const Text('THE BIBLE', style: TextStyle(color: wine, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    const SizedBox(height: 8),
    Text('Explore all 66 books of the King James Version, from Genesis to Revelation.', style: TextStyle(color: Colors.brown.shade700, height: 1.4)),
  ]);
}
class _QuickTile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _QuickTile({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAD9D0))), child: Column(children: [Icon(icon, color: wine, size: 30), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))])));
}

class BibleLibrary extends StatefulWidget {
  const BibleLibrary({super.key});
  @override
  State<BibleLibrary> createState() => _BibleLibraryState();
}
class _BibleLibraryState extends State<BibleLibrary> {
  String filter = '';
  @override
  Widget build(BuildContext context) {
    final books = bibleBooks.where((b) => b.toLowerCase().contains(filter.toLowerCase())).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(onChanged: (v) => setState(() => filter = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search books of the Bible'))),
      Expanded(child: ListView.builder(itemCount: books.length, itemBuilder: (context, i) {
        final book = books[i];
        return ListTile(leading: CircleAvatar(backgroundColor: wine.withOpacity(.1), child: const Icon(Icons.menu_book, color: wine)), title: Text(book, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(i < 39 ? 'Old Testament' : 'New Testament'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterPicker(book: book))));
      })),
    ]);
  }
}

class ChapterPicker extends StatelessWidget {
  final String book;
  const ChapterPicker({super.key, required this.book});
  Future<int> count() async {
    try {
      final raw = jsonDecode(await rootBundle.loadString('assets/bible/${_fileName(book)}.json')) as Map<String,dynamic>;
      final chapters = raw['chapters'];
      return chapters is List ? chapters.length : (chapters as Map).length;
    } catch (_) { return _fallbackChapters[book] ?? 1; }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(book)),
    body: FutureBuilder<int>(future: count(), builder: (context, snap) {
      final n = snap.data ?? _fallbackChapters[book] ?? 1;
      return GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: n, itemBuilder: (context, i) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BibleReader(book: book, chapter: i+1))), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8D6CD))), child: Center(child: Text('${i+1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: wine))))));
    }),
  );
}

class BibleReader extends StatefulWidget {
  final String book; final int chapter;
  const BibleReader({super.key, required this.book, required this.chapter});
  @override
  State<BibleReader> createState() => _BibleReaderState();
}
class _BibleReaderState extends State<BibleReader> {
  late Future<List<String>> verses;
  @override
  void initState() { super.initState(); verses = load(); }
  Future<List<String>> load() async {
    final data = jsonDecode(await rootBundle.loadString('assets/bible/${_fileName(widget.book)}.json')) as Map<String,dynamic>;
    final chapters = data['chapters'];
    dynamic selected;
    if (chapters is List) selected = chapters[widget.chapter-1];
    else selected = chapters['${widget.chapter}'];
    if (selected is List) return selected.map((e) => e is Map ? (e['text'] ?? e['verse'] ?? '').toString() : e.toString()).toList();
    if (selected is Map) {
      final keys = selected.keys.toList()..sort((a,b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
      return keys.map((k) => selected[k].toString()).toList();
    }
    throw Exception('Bible chapter data is unavailable.');
  }
  Future<void> saveVerse(int index, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('nero_saved_verses') ?? [];
    final item = '${widget.book} ${widget.chapter}:${index+1}|$text';
    if (!list.contains(item)) list.add(item);
    await prefs.setStringList('nero_saved_verses', list);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verse saved.')));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.book} ${widget.chapter}'), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedVerses())), icon: const Icon(Icons.bookmark_border))]),
    body: FutureBuilder<List<String>>(future: verses, builder: (context, snap) {
      if (snap.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Bible text has not been downloaded into assets/bible yet. Run the included GitHub Actions workflow to download the complete KJV dataset.')));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.builder(padding: const EdgeInsets.fromLTRB(20, 18, 20, 40), itemCount: snap.data!.length, itemBuilder: (context, i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: InkWell(onLongPress: () => saveVerse(i, snap.data![i]), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 3, right: 12), child: Text('${i+1}', style: const TextStyle(color: wine, fontWeight: FontWeight.bold))),
        Expanded(child: Text(snap.data![i], style: const TextStyle(fontSize: 19, height: 1.65, color: Color(0xFF34251F)))),
        IconButton(visualDensity: VisualDensity.compact, onPressed: () => saveVerse(i, snap.data![i]), icon: const Icon(Icons.bookmark_add_outlined, color: wine, size: 20)),
      ]))));
    }),
  );
}

class SavedVerses extends StatefulWidget {
  const SavedVerses({super.key});
  @override
  State<SavedVerses> createState() => _SavedVersesState();
}
class _SavedVersesState extends State<SavedVerses> {
  Future<List<String>> getSaved() async => (await SharedPreferences.getInstance()).getStringList('nero_saved_verses') ?? [];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<List<String>>(future: getSaved(), builder: (context, snap) {
      final items = snap.data ?? [];
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      if (items.isEmpty) return const Center(child: Text('Your saved verses will appear here.'));
      return ListView.builder(itemCount: items.length, itemBuilder: (context, i) => ListTile(leading: const Icon(Icons.bookmark, color: wine), title: Text(items[i].split('|').first), subtitle: Text(items[i].split('|').skip(1).join('|')), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { final p = await SharedPreferences.getInstance(); items.removeAt(i); await p.setStringList('nero_saved_verses', items); setState(() {}); })));
    }),
  );
}

class AccountPage extends StatelessWidget {
  final bool guest;
  const AccountPage({super.key, this.guest = false});
  @override
  Widget build(BuildContext context) {
    final user = sb?.auth.currentUser;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 20), const Center(child: NeroMark(size: 88)), const SizedBox(height: 12),
      Center(child: Text(user?.userMetadata?['full_name']?.toString() ?? (guest ? 'Guest Reader' : 'NERO Reader'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
      Center(child: Text(user?.email ?? 'Read and reflect in the KJV Bible')),
      const SizedBox(height: 26),
      if (user != null) ListTile(leading: const Icon(Icons.verified_user, color: wine), title: const Text('Account status'), subtitle: Text(user.emailConfirmedAt == null ? 'Email verification pending' : 'Email verified')),
      ListTile(leading: const Icon(Icons.info_outline, color: wine), title: const Text('About NERO'), subtitle: const Text('Read, Reflect & Grow • King James Version')),
      const SizedBox(height: 16),
      _WideButton(text: user == null ? 'Sign In' : 'Sign Out', light: user == null, onTap: () async {
        if (user == null) { Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthForm(register: false))); }
        else {
          await sb!.auth.signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
            );
          }
        }
      }),
    ]);
  }
}

class BibleSearchDelegate extends SearchDelegate<String> {
  @override String get searchFieldLabel => 'Search books or verse text';
  @override List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  @override Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back));
  @override Widget buildResults(BuildContext context) => _searchResults(context);
  @override Widget buildSuggestions(BuildContext context) => _searchResults(context);
  Widget _searchResults(BuildContext context) {
    final results = bibleBooks.where((b) => b.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(children: results.map((b) => ListTile(title: Text(b), leading: const Icon(Icons.menu_book, color: wine), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterPicker(book: b)))).toList());
  }
}

String _fileName(String book) => book.toLowerCase().replaceAll(' ', '_');
const Map<String,int> _fallbackChapters = {
  'Genesis':50,'Exodus':40,'Leviticus':27,'Numbers':36,'Deuteronomy':34,'Joshua':24,'Judges':21,'Ruth':4,
  '1 Samuel':31,'2 Samuel':24,'1 Kings':22,'2 Kings':25,'1 Chronicles':29,'2 Chronicles':36,'Ezra':10,'Nehemiah':13,
  'Esther':10,'Job':42,'Psalms':150,'Proverbs':31,'Ecclesiastes':12,'Song of Solomon':8,'Isaiah':66,'Jeremiah':52,
  'Lamentations':5,'Ezekiel':48,'Daniel':12,'Hosea':14,'Joel':3,'Amos':9,'Obadiah':1,'Jonah':4,'Micah':7,'Nahum':3,
  'Habakkuk':3,'Zephaniah':3,'Haggai':2,'Zechariah':14,'Malachi':4,'Matthew':28,'Mark':16,'Luke':24,'John':21,'Acts':28,
  'Romans':16,'1 Corinthians':16,'2 Corinthians':13,'Galatians':6,'Ephesians':6,'Philippians':4,'Colossians':4,
  '1 Thessalonians':5,'2 Thessalonians':3,'1 Timothy':6,'2 Timothy':4,'Titus':3,'Philemon':1,'Hebrews':13,'James':5,
  '1 Peter':5,'2 Peter':3,'1 John':5,'2 John':1,'3 John':1,'Jude':1,'Revelation':22
};
