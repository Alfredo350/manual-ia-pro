import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'upload_screen.dart';

/// Inicio: preguntas del día + el único documento.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Al volver a la app otro día, el contador se renueva.
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().refreshUsage());
  }

  void _openChat({String? question, bool voice = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(initialQuestion: question, startWithVoice: voice)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    final doc = state.document;
    final usage = state.usage;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: state.refreshUsage,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Row(children: [
                const BrandLogo(size: 40),
                const SizedBox(width: 6),
                const Expanded(child: Wordmark(fontSize: 19)),
                IconButton.outlined(
                  tooltip: l.settings,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.line),
                  ),
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
                ),
              ]),
              const SizedBox(height: 16),

              // Preguntas de hoy
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: kCardGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: kPrimaryShadow,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: SectionLabel(l.today, color: const Color(0xFFBBC8E6))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0x2EFFFFFF), borderRadius: BorderRadius.circular(10)),
                      child: Text(l.basicBadge,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(l.usedOf(usage.usedToday),
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 10),
                  UsageDots(used: usage.usedToday, limit: usage.limit, dark: true),
                  const SizedBox(height: 10),
                  Text(l.renews, style: const TextStyle(fontSize: 13, color: Color(0xFFDCE7FF))),
                ]),
              ),
              const SizedBox(height: 16),

              if (doc != null) ...[
                CardBox(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      DocTypeBadge(type: doc.type),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(doc.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text(l.docPages(doc.pages), style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                          const SizedBox(height: 3),
                          _status(l, doc.isReady, doc.isProcessing, doc.progress),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: PrimaryButton(
                          label: l.ask,
                          icon: Icons.chat_bubble_outline,
                          height: 50,
                          onPressed: doc.isReady ? () => _openChat() : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: SecondaryButton(
                          label: l.voiceTitle,
                          icon: Icons.mic_none,
                          height: 50,
                          accent: true,
                          onPressed: doc.isReady ? () => _openChat(voice: true) : null,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () => startUpload(context),
                      icon: const Icon(Icons.sync, size: 18),
                      label: Text(l.replace),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: const TextStyle(
                            fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                ),
                if (doc.isReady && state.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  SectionLabel(l.suggested),
                  const SizedBox(height: 10),
                  for (final q in state.suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.line),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _openChat(question: q),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            child: Text(q, style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                ],
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.softest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFA7B8D8), width: 1.5),
                  ),
                  child: Column(children: [
                    Text(l.noDocTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(l.noDocText, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 14),
                    PrimaryButton(label: l.uploadMine, onPressed: () => startUpload(context)),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _status(L l, bool ready, bool processing, int progress) {
    final color = ready ? AppColors.primary : (processing ? AppColors.processing : AppColors.danger);
    final text = ready ? l.ready : (processing ? '${l.processing} $progress%' : l.uploadError);
    return Row(children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Flexible(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color))),
    ]);
  }
}
