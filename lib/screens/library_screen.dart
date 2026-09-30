import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'upload_screen.dart';

/// Biblioteca (versión Pro): todos los documentos, sin límites.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';

  Future<void> _open(DocumentInfo d, {bool voice = false}) async {
    if (!d.isReady) return;
    final state = context.read<AppState>();
    await state.openDocument(d.id);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(startWithVoice: voice)));
  }

  Future<void> _menu(DocumentInfo d) async {
    final l = context.read<AppState>().l;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: AppColors.lineStrong, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              DocTypeBadge(type: d.type, width: 38, height: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(_meta(l, d), style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ]),
              ),
            ]),
            const Divider(height: 24, color: AppColors.line),
            if (d.isReady) ...[
              _sheetItem(ctx, Icons.chat_bubble_outline, l.ask, 'ask'),
              _sheetItem(ctx, Icons.mic_none, l.voiceAsk, 'voice'),
            ],
            _sheetItem(ctx, Icons.delete_outline, l.deleteDoc, 'delete', danger: true),
          ]),
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'ask') return _open(d);
    if (action == 'voice') return _open(d, voice: true);
    if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.deleteQ(d.name)),
          content: Text(l.deleteBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.deleteBtn),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      try {
        await context.read<AppState>().deleteDocument(d.id);
      } catch (_) {
        if (mounted) showSnack(context, l.errorGeneric);
      }
    }
  }

  Widget _sheetItem(BuildContext ctx, IconData icon, String label, String value, {bool danger = false}) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: color)),
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  String _meta(L l, DocumentInfo d) {
    final pages = l.docPages(d.pages);
    return d.isReady ? '$pages · ${l.questionsN(d.questionCount)}' : pages;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    final q = _query.trim().toLowerCase();
    final docs = q.isEmpty ? state.documents : state.documents.where((d) => d.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(gradient: kPrimaryGradient, borderRadius: BorderRadius.circular(28), boxShadow: kPrimaryShadow),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          onPressed: () => startUpload(context),
          icon: const Icon(Icons.add),
          label: Text(l.upload, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Row(children: [
                const BrandLogo(size: 40),
                const SizedBox(width: 6),
                const Wordmark(fontSize: 19),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(7)),
                  child: const Text('PRO',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3A2500))),
                ),
                const Spacer(),
                IconButton.outlined(
                  tooltip: l.settings,
                  style: IconButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: AppColors.line)),
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
                ),
              ]),
              const SizedBox(height: 14),
              Text(l.library, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              Text(l.docsCount(state.documents.length), style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
              const SizedBox(height: 14),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l.searchPh,
                  prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.line)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 14),
              if (state.documents.isEmpty)
                _EmptyLibrary(l: l)
              else if (docs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.noResults, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
                )
              else
                for (final d in docs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DocTile(
                      doc: d,
                      meta: _meta(l, d),
                      l: l,
                      onTap: () => _open(d),
                      onMenu: () => _menu(d),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.doc, required this.meta, required this.l, required this.onTap, required this.onMenu});
  final DocumentInfo doc;
  final String meta;
  final L l;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final statusColor = doc.isReady ? AppColors.primary : (doc.isProcessing ? AppColors.processing : AppColors.danger);
    final statusText =
        doc.isReady ? l.ready : (doc.isProcessing ? '${l.processing} ${doc.progress}%' : l.uploadError);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: kCardShadow,
      ),
      child: Material(
        color: Colors.white,
        child: Row(children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
                child: Row(children: [
                  DocTypeBadge(type: doc.type, width: 44, height: 54),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Flexible(
                          child: Text(doc.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.soft2, borderRadius: BorderRadius.circular(6)),
                          child: Text(doc.language.toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.body)),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Text(meta, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      if (doc.isProcessing) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: doc.progress / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.processingBg,
                            color: AppColors.processing,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
          IconButton(
            tooltip: l.options,
            onPressed: onMenu,
            icon: const Icon(Icons.more_vert, color: AppColors.muted),
          ),
        ]),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.l});
  final L l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.softest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7B8D8), width: 1.5),
      ),
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.description_outlined, color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        Text(l.emptyLibTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(l.emptyLibText, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
      ]),
    );
  }
}
