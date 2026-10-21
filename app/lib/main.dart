import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sqflite/sqflite.dart';
import 'src/summary.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotes.db;
  runApp(const DiwwanApp());
}

const navy = Color(0xFF162B4D);
const blue = Color(0xFF4263EB);
const canvas = Color(0xFFF5F7FC);

class DiwwanApp extends StatelessWidget {
  const DiwwanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'دوّن | Diwwan',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: blue),
      scaffoldBackgroundColor: canvas,
      appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: navy),
    ),
    home: const HomePage(),
  );
}

class Entry {
  const Entry({this.id, required this.title, required this.kind, required this.body, required this.date, this.audioPath = ''});
  final int? id;
  final String title, kind, body, date, audioPath;
  Map<String, Object?> toMap() => {'id': id, 'title': title, 'kind': kind, 'body': body, 'date': date, 'audio_path': audioPath};
  factory Entry.fromMap(Map<String, Object?> m) => Entry(
    id: m['id'] as int, title: m['title'] as String, kind: m['kind'] as String,
    body: m['body'] as String, date: m['date'] as String, audioPath: (m['audio_path'] as String?) ?? '',
  );
}

class LocalNotes {
  static Database? _database;
  static Future<Database> get db async {
    if (_database != null) return _database!;
    final root = await getApplicationDocumentsDirectory();
    _database = await openDatabase(p.join(root.path, 'diwwan.db'), version: 1,
      onCreate: (db, _) => db.execute("CREATE TABLE entries(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, kind TEXT NOT NULL, body TEXT NOT NULL, date TEXT NOT NULL, audio_path TEXT NOT NULL DEFAULT '')"));
    return _database!;
  }
  static Future<List<Entry>> all() async {
    final rows = await (await db).query('entries', orderBy: 'id DESC');
    return rows.map(Entry.fromMap).toList();
  }
  static Future<void> save(Entry e) async {
    final values = e.toMap()..remove('id');
    if (e.id == null) { await (await db).insert('entries', values); }
    else { await (await db).update('entries', values, where: 'id=?', whereArgs: [e.id]); }
  }
  static Future<void> remove(int id) async {
    await (await db).delete('entries', where: 'id=?', whereArgs: [id]);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Entry> entries = [];
  String search = '';
  int filter = 0;
  @override void initState() { super.initState(); _refresh(); }
  Future<void> _refresh() async { final result = await LocalNotes.all(); if (mounted) setState(() => entries = result); }
  List<Entry> get visible => entries.where((e) =>
    (filter == 0 || e.kind == (filter == 1 ? 'lecture' : 'report')) &&
    ('${e.title} ${e.body}'.toLowerCase().contains(search.toLowerCase()))).toList();

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    body: SafeArea(child: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.graphic_eq, color: Colors.white)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('دوّن', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: navy)),
            Text('مساحتك للمحاضرات والتقارير', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
          ])),
          IconButton(onPressed: () => showAboutDialog(context: context, applicationName: 'Diwwan', applicationVersion: '0.1.0', children: const [Text('نسخة أولية محلية. ميزات الذكاء الاصطناعي التوليدي غير مدمجة بعد.')]), icon: const Icon(Icons.info_outline)),
        ]),
        const SizedBox(height: 22),
        Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [navy, Color(0xFF2D5085)]), borderRadius: BorderRadius.circular(24)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('من المحاضرة إلى التقرير', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${entries.length} ملف محفوظ محليًا على الهاتف', style: const TextStyle(color: Color(0xFFDCE7FF))),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: () => _edit('lecture'), icon: const Icon(Icons.mic), label: const Text('محاضرة'), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: navy))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.tonalIcon(onPressed: () => _edit('report'), icon: const Icon(Icons.description), label: const Text('تقرير'))),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        TextField(onChanged: (v) => setState(() => search = v), decoration: InputDecoration(
          hintText: 'ابحث في المحاضرات والتقارير', prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: [
          _chip('الكل', 0), _chip('المحاضرات', 1), _chip('التقارير', 2),
        ]),
      ]))),
      if (visible.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: Center(child: Padding(
        padding: EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.library_books_outlined, size: 48, color: blue), SizedBox(height: 12),
          Text('لا توجد ملفات بعد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: navy)),
          Text('أنشئ محاضرتك الأولى أو ابدأ تقريرًا جديدًا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
        ])))),
      SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 28), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, i) {
        final e = visible[i];
        final lecture = e.kind == 'lecture';
        return Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(
          leading: CircleAvatar(backgroundColor: lecture ? const Color(0xFFE7ECFF) : const Color(0xFFDDF5E9), child: Icon(lecture ? Icons.headphones : Icons.article_outlined, color: lecture ? blue : Colors.teal)),
          title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${lecture ? 'محاضرة' : 'تقرير'} • ${e.body}', maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => _edit(e.kind, existing: e),
          trailing: PopupMenuButton<String>(onSelected: (v) async { if (v == 'edit') await _edit(e.kind, existing: e); if (v == 'delete') { await LocalNotes.remove(e.id!); _refresh(); } }, itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('فتح وتعديل')), PopupMenuItem(value: 'delete', child: Text('حذف')),
          ]),
        ));
      }, childCount: visible.length))),
    ])),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit('lecture'), icon: const Icon(Icons.add), label: const Text('ملف جديد')),
  ));

  Widget _chip(String text, int value) => ChoiceChip(label: Text(text), selected: filter == value, onSelected: (_) => setState(() => filter = value), showCheckmark: false);
  Future<void> _edit(String kind, {Entry? existing}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditorPage(kind: kind, existing: existing)));
    await _refresh();
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key, required this.kind, this.existing});
  final String kind;
  final Entry? existing;
  @override State<EditorPage> createState() => _EditorPageState();
}
class _EditorPageState extends State<EditorPage> {
  late final TextEditingController title, body;
  final recorder = AudioRecorder();
  final speech = stt.SpeechToText();
  bool recording = false, listening = false;
  String audioPath = '', language = 'ar';

  @override void initState() {
    super.initState();
    title = TextEditingController(text: widget.existing?.title ?? '');
    body = TextEditingController(text: widget.existing?.body ?? '');
    audioPath = widget.existing?.audioPath ?? '';
  }
  @override void dispose() { title.dispose(); body.dispose(); recorder.dispose(); speech.stop(); super.dispose(); }

  Future<void> _record() async {
    if (recording) {
      final result = await recorder.stop();
      setState(() { recording = false; audioPath = result ?? audioPath; });
      return;
    }
    if (!await recorder.hasPermission()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اسمح للتطبيق باستخدام الميكروفون أولًا.')));
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'diwwan_${DateTime.now().millisecondsSinceEpoch}.m4a');
    await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() { recording = true; audioPath = path; });
  }

  Future<void> _transcribe() async {
    if (listening) {
      await speech.stop();
      setState(() => listening = false);
      return;
    }
    final ready = await speech.initialize(onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && mounted) {
          setState(() => listening = false);
        }
      },
      onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر التفريغ: ${e.errorMsg}')),
          );
        }
      },
    );
    if (!ready) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمة التعرف على الكلام غير متاحة على هذا الجهاز.')),
        );
      }
      return;
    }
    setState(() => listening = true);
    await speech.listen(localeId: speechLocaleFor(language), onResult: (result) {
      if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
        final next = '${body.text}${body.text.isEmpty ? '' : '\n'}${result.recognizedWords.trim()}';
        body.value = TextEditingValue(text: next, selection: TextSelection.collapsed(offset: next.length));
      }
    });
  }

  Future<void> _save() async {
    if (recording) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أوقف التسجيل قبل الحفظ.'))); return; }
    if (title.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل عنوانًا للملف.'))); return; }
    await LocalNotes.save(Entry(id: widget.existing?.id, title: title.text.trim(), kind: widget.kind, body: body.text.trim(),
      date: widget.existing?.date ?? DateTime.now().toIso8601String(), audioPath: audioPath));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lecture = widget.kind == 'lecture';
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: Text(lecture ? 'المحاضرة' : 'التقرير'), actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))]),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'العنوان', filled: true, fillColor: Colors.white)),
        const SizedBox(height: 14),
        if (lecture) Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(children: [Icon(recording ? Icons.fiber_manual_record : Icons.mic, color: recording ? Colors.red : blue), const SizedBox(width: 10), Expanded(child: Text(recording ? 'جارٍ التسجيل...' : audioPath.isEmpty ? 'تسجيل صوتي محلي' : 'تم حفظ مسار التسجيل')), FilledButton(onPressed: _record, child: Text(recording ? 'إيقاف' : 'تسجيل'))]),
          if (audioPath.isNotEmpty) Text(p.basename(audioPath), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]))),
        Row(children: [const Text('لغة التفريغ'), const Spacer(), DropdownButton<String>(value: language, items: const [
          DropdownMenuItem(value: 'ar', child: Text('العربية')), DropdownMenuItem(value: 'fr', child: Text('Français')), DropdownMenuItem(value: 'en', child: Text('English')),
        ], onChanged: (v) => setState(() => language = v ?? 'ar'))]),
        TextField(controller: body, minLines: 9, maxLines: 18, decoration: const InputDecoration(hintText: 'اكتب الملاحظات أو أفرغ المحاضرة هنا...', alignLabelWithHint: true, filled: true, fillColor: Colors.white)),
        if (lecture) Padding(padding: const EdgeInsets.only(top: 12), child: OutlinedButton.icon(onPressed: _transcribe, icon: Icon(listening ? Icons.stop : Icons.record_voice_over), label: Text(listening ? 'إيقاف التفريغ' : 'تحويل الكلام إلى نص'))),
        Padding(padding: const EdgeInsets.only(top: 8), child: OutlinedButton.icon(onPressed: () => setState(() => body.text = buildPreliminarySummary(body.text)), icon: const Icon(Icons.auto_awesome), label: const Text('ملخص أولي (دون ذكاء اصطناعي توليدي)'))),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('حفظ على الهاتف')),
      ]),
    ));
  }
}
