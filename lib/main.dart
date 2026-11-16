import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeroApp());
}

class NeroApp extends StatelessWidget {
  const NeroApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NERO', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true, scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: wine, primary: wine, secondary: gold),
      appBarTheme: const AppBarTheme(backgroundColor: wine, foregroundColor: Colors.white, centerTitle: true),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFFF8F1EC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
    home: const NeroHome(),
  );
}

class NeroMark extends StatelessWidget {
  final double size;
  const NeroMark({super.key, this.size = 62});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .18),
    child: Image.asset('assets/images/icon/nero_launcher.png', width: size, height: size, fit: BoxFit.cover),
  );
}

class NeroHome extends StatefulWidget {
  const NeroHome({super.key});
  @override
  State<NeroHome> createState() => _NeroHomeState();
}
class _NeroHomeState extends State<NeroHome> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _Dashboard(onRead: () => setState(() => tab = 1)),
      const BibleLibrary(), const SavedVerses(), const AboutPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(10), child: NeroMark(size: 36)),
        title: const Text('NERO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [IconButton(onPressed: () => showSearch(context: context, delegate: BibleSearchDelegate()), icon: const Icon(Icons.search), tooltip: 'Search the Bible')],
      ),
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i),
        indicatorColor: gold.withOpacity(.25),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Bible'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'About'),
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
    final books = bibleBooks.where((b) => b.toLowerCase().contains(filter.trim().toLowerCase())).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          onChanged: (value) => setState(() => filter = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Find a book',
          ),
        ),
      ),
      Expanded(child: ListView.builder(itemCount: books.length, itemBuilder: (context, i) {
        final book = books[i];
        return ListTile(leading: CircleAvatar(backgroundColor: wine.withOpacity(.1), child: const Icon(Icons.menu_book, color: wine)), title: Text(book, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(bibleBooks.indexOf(book) < 39 ? 'Old Testament' : 'New Testament'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterPicker(book: book))));
      })),
    ]);
  }
}

class ChapterPicker extends StatelessWidget {
  final String book;
  const ChapterPicker({super.key, required this.book});
  Future<int> count() async {
    final raw = jsonDecode(await rootBundle.loadString('assets/bible/${_fileName(book)}.json')) as Map<String, dynamic>;
    final chapters = raw['chapters'];
    if (chapters is Map) return chapters.length;
    if (chapters is List) return chapters.length;
    throw const FormatException('Invalid chapter data');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(book)),
    body: FutureBuilder<int>(future: count(), builder: (context, snap) {
      if (snap.hasError) return const Center(child: Text('Bible data is unavailable. Please rebuild the app.'));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      return GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: snap.data!, itemBuilder: (context, i) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BibleReader(book: book, chapter: i + 1))), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8D6CD))), child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: wine))))));
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
  late Future<List<MapEntry<String, String>>> verses;
  @override
  void initState() { super.initState(); verses = load(); }
  Future<List<MapEntry<String, String>>> load() async {
    final data = jsonDecode(await rootBundle.loadString('assets/bible/${_fileName(widget.book)}.json')) as Map<String, dynamic>;
    final chapters = data['chapters'];
    dynamic selected = chapters is List ? chapters[widget.chapter - 1] : (chapters as Map)[widget.chapter.toString()];
    if (selected is Map && selected['verses'] != null) selected = selected['verses'];
    if (selected is Map) {
      final keys = selected.keys.toList()..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
      return keys.map((key) {
        final value = selected[key];
        final text = value is Map ? (value['text'] ?? value['verse_text'] ?? '').toString() : value.toString();
        return MapEntry(key.toString(), text);
      }).toList();
    }
    if (selected is List) return selected.asMap().entries.map((entry) {
      final value = entry.value;
      final text = value is Map ? (value['text'] ?? value['verse_text'] ?? '').toString() : value.toString();
      final number = value is Map ? (value['verse'] ?? entry.key + 1).toString() : (entry.key + 1).toString();
      return MapEntry(number, text);
    }).toList();
    throw const FormatException('Bible chapter data is unavailable.');
  }
  Future<void> saveVerse(String number, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('nero_saved_verses') ?? [];
    final reference = '${widget.book} ${widget.chapter}:$number';
    final item = jsonEncode({'reference': reference, 'text': text});
    if (!list.any((saved) { try { return jsonDecode(saved)['reference'] == reference; } catch (_) { return false; } })) list.add(item);
    await prefs.setStringList('nero_saved_verses', list);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verse saved to your device.')));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.book} ${widget.chapter}'), actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedVerses())), icon: const Icon(Icons.bookmark_border), tooltip: 'Saved verses')]),
    body: FutureBuilder<List<MapEntry<String, String>>>(future: verses, builder: (context, snap) {
      if (snap.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('This chapter could not be loaded. Please rebuild the app with the complete KJV data.')));
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.builder(padding: const EdgeInsets.fromLTRB(20, 18, 20, 40), itemCount: snap.data!.length, itemBuilder: (context, i) {
        final verse = snap.data![i];
        return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 3, right: 12), child: Text(verse.key, style: const TextStyle(color: wine, fontWeight: FontWeight.bold))),
          Expanded(child: Text(verse.value, style: const TextStyle(fontSize: 19, height: 1.65, color: Color(0xFF34251F)))),
          IconButton(visualDensity: VisualDensity.compact, onPressed: () => saveVerse(verse.key, verse.value), icon: const Icon(Icons.bookmark_add_outlined, color: wine, size: 20), tooltip: 'Save verse'),
        ]));
      });
    }),
  );
}

class SavedVerses extends StatefulWidget {
  const SavedVerses({super.key});
  @override
  State<SavedVerses> createState() => _SavedVersesState();
}
class _SavedVersesState extends State<SavedVerses> {
  Future<List<Map<String, String>>> getSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('nero_saved_verses') ?? [];
    final result = <Map<String, String>>[];
    for (final item in raw) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map) result.add({'reference': decoded['reference'].toString(), 'text': decoded['text'].toString()});
      } catch (_) {
        final parts = item.split('|');
        if (parts.length >= 2) result.add({'reference': parts.first, 'text': parts.skip(1).join('|')});
      }
    }
    return result;
  }
  Future<void> removeAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('nero_saved_verses') ?? [];
    final saved = await getSaved();
    if (index < saved.length) {
      final reference = saved[index]['reference'];
      items.removeWhere((item) { try { return jsonDecode(item)['reference'] == reference; } catch (_) { return item.startsWith('$reference|'); } });
      await prefs.setStringList('nero_saved_verses', items);
      if (mounted) setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<List<Map<String, String>>>(future: getSaved(), builder: (context, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      final items = snap.data!;
      if (items.isEmpty) return const Center(child: Text('Your saved verses will appear here.'));
      return ListView.builder(itemCount: items.length, itemBuilder: (context, i) => ListTile(leading: const Icon(Icons.bookmark, color: wine), title: Text(items[i]['reference']!), subtitle: Text(items[i]['text']!), trailing: IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Remove saved verse', onPressed: () => removeAt(i))));
    }),
  );
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24), children: [
    const SizedBox(height: 24), const Center(child: NeroMark(size: 92)), const SizedBox(height: 16),
    const Center(child: Text('NERO', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: wine, letterSpacing: 2))),
    const Center(child: Text('Read, Reflect & Grow', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic))),
    const SizedBox(height: 24), const Text('NERO is an offline Bible reader containing the complete 66-book King James Version. Read, search, and save verses directly on your device.', textAlign: TextAlign.center, style: TextStyle(height: 1.6)),
    const SizedBox(height: 16), const ListTile(leading: Icon(Icons.wifi_off, color: wine), title: Text('Works offline'), subtitle: Text('Bible reading and search do not require an internet connection after installation.')),
    const ListTile(leading: Icon(Icons.bookmark, color: wine), title: Text('Saved on your device'), subtitle: Text('Your saved verses remain on this device.')),
  ]);
}

class BibleSearchDelegate extends SearchDelegate<String> {
  @override String get searchFieldLabel => 'Search words or verses';
  @override List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear), tooltip: 'Clear search')];
  @override Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, ''), icon: const Icon(Icons.arrow_back));
  @override Widget buildResults(BuildContext context) => _searchResults(context);
  @override Widget buildSuggestions(BuildContext context) => _searchResults(context);
  Widget _searchResults(BuildContext context) {
    final term = query.trim().toLowerCase();
    if (term.length < 2) return const Center(child: Text('Enter at least two letters to search the KJV Bible.'));
    return FutureBuilder<List<_VerseHit>>(
      future: _findVerses(term),
      builder: (context, snap) {
        if (snap.hasError) return const Center(child: Text('Search could not load the Bible text.'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final hits = snap.data!;
        if (hits.isEmpty) return const Center(child: Text('No matching verses found.'));
        return ListView.builder(itemCount: hits.length, itemBuilder: (context, i) {
          final hit = hits[i];
          return ListTile(leading: const Icon(Icons.menu_book, color: wine), title: Text(hit.reference, style: const TextStyle(fontWeight: FontWeight.bold, color: wine)), subtitle: Text(hit.text, maxLines: 3, overflow: TextOverflow.ellipsis), onTap: () { close(context, hit.reference); Navigator.push(context, MaterialPageRoute(builder: (_) => BibleReader(book: hit.book, chapter: hit.chapter))); });
        });
      },
    );
  }
}

class _VerseHit {
  final String book; final int chapter; final String verse; final String text;
  const _VerseHit(this.book, this.chapter, this.verse, this.text);
  String get reference => '$book $chapter:$verse';
}

Future<List<_VerseHit>> _findVerses(String term) async {
  final hits = <_VerseHit>[];
  for (final book in bibleBooks) {
    final raw = jsonDecode(await rootBundle.loadString('assets/bible/${_fileName(book)}.json')) as Map<String, dynamic>;
    final chapters = raw['chapters'];
    final chapterKeys = chapters is Map ? chapters.keys.toList() : List.generate((chapters as List).length, (i) => (i + 1).toString());
    chapterKeys.sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
    for (final chapterKey in chapterKeys) {
      final chapterNumber = int.parse(chapterKey.toString());
      final dynamic chapter = chapters is Map ? chapters[chapterKey] : chapters[chapterNumber - 1];
      final dynamic source = chapter is Map && chapter['verses'] != null ? chapter['verses'] : chapter;
      if (source is Map) {
        final keys = source.keys.toList()..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
        for (final key in keys) {
          final value = source[key];
          final text = value is Map ? (value['text'] ?? value['verse_text'] ?? '').toString() : value.toString();
          if (text.toLowerCase().contains(term)) hits.add(_VerseHit(book, chapterNumber, key.toString(), text));
          if (hits.length >= 300) return hits;
        }
      } else if (source is List) {
        for (var i = 0; i < source.length; i++) {
          final value = source[i];
          final text = value is Map ? (value['text'] ?? value['verse_text'] ?? '').toString() : value.toString();
          final number = value is Map ? (value['verse'] ?? i + 1).toString() : (i + 1).toString();
          if (text.toLowerCase().contains(term)) hits.add(_VerseHit(book, chapterNumber, number, text));
          if (hits.length >= 300) return hits;
        }
      }
    }
  }
  return hits;
}

String _fileName(String book) => book.toLowerCase().replaceAll(' ', '_');
