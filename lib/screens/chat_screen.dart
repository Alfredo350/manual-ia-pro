import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/source_capture.dart';
import 'pro_screen.dart';

/// Chat con el manual: texto o voz, captura de la página, lectura en voz alta y límite diario.
/// Las respuestas son el texto del documento, encontrado con reglas de búsqueda (sin IA).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.initialQuestion, this.startWithVoice = false});
  final String? initialQuestion;
  final bool startWithVoice;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  final _scroll = ScrollController();
  late AppState _state;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuestion != null) _send(widget.initialQuestion!);
      if (widget.startWithVoice) _startVoice();
    });
  }

  @override
  void dispose() {
    // Se ejecuta después de desmontar la pantalla para no avisar cambios durante el cierre.
    final st = _state;
    Future.microtask(() {
      st.stopSpeaking();
      if (st.listening) st.cancelListening();
    });
    _input.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? text]) async {
    final q = (text ?? _input.text).trim();
    if (q.isEmpty) return;
    _input.clear();
    FocusScope.of(context).unfocus();
    final r = await _state.ask(q);
    if (!mounted) return;
    if (r == AskResult.error) showSnack(context, _state.l.errorGeneric);
  }

  Future<void> _startVoice() async {
    if (_state.limitReached) return;
    FocusScope.of(context).unfocus();
    await _state.startListening();
  }

  /// Si el teléfono no tiene dictado, se usa el micrófono del teclado (Gboard, Samsung…).
  Future<void> _useKeyboard() async {
    await _state.cancelListening();
    if (mounted) _inputFocus.requestFocus();
  }

  Future<void> _sendVoice() async {
    final r = await _state.sendVoice();
    if (!mounted) return;
    if (r == AskResult.error && _state.messages.isNotEmpty) showSnack(context, _state.l.errorGeneric);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    final itemCount = state.messages.length + (state.asking ? 1 : 0);
    if (itemCount != _lastCount) {
      _lastCount = itemCount;
      _scrollToEnd();
    }
    final used = state.usage.usedToday;
    final limit = state.usage.limit;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 64,
        shape: const Border(bottom: BorderSide(color: AppColors.line)),
        leading: IconButton(
          tooltip: l.back,
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(state.document?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          Text(AppConfig.isPro ? '${l.historySaved} · ${l.unlimited}' : l.onlyDoc,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted)),
        ]),
      ),
      body: Column(
        children: [
          // Contador del día (solo en la versión básica)
          if (!AppConfig.isPro) ...[
          Container(
            color: AppColors.softest,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(state.limitReached ? l.doneToday : l.left(limit - used),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              UsageDots(used: used, limit: limit),
            ]),
          ),
          const Divider(height: 1, color: AppColors.line),
          ],
          Expanded(
            child: state.messages.isEmpty && !state.asking
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(l.emptyChat,
                            textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 15)),
                        const SizedBox(height: 12),
                        _AiNote(text: l.aiNote),
                      ]),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    itemCount: itemCount + 1,
                    itemBuilder: (context, row) {
                      if (row == 0) {
                        return Padding(padding: const EdgeInsets.only(bottom: 12), child: _AiNote(text: l.aiNote));
                      }
                      final i = row - 1;
                      if (i >= state.messages.length) return _ThinkingBubble(text: l.thinking);
                      final m = state.messages[i];
                      return m.fromUser
                          ? _UserBubble(message: m)
                          : _AnswerBubble(message: m, index: i, onAsk: (q) => _send(q));
                    },
                  ),
          ),
          if (state.limitReached)
            const _LimitPanel()
          else if (state.listening)
            _ListeningPanel(onSend: _sendVoice, onRetry: _startVoice, onKeyboard: _useKeyboard)
          else
            _InputBar(
                controller: _input,
                focusNode: _inputFocus,
                busy: state.asking,
                onSend: () => _send(),
                onMic: _startVoice),
        ],
      ),
    );
  }
}

// ---------------- Burbujas ----------------

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (message.byVoice) ...[
            const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.mic, size: 16, color: Color(0xFFDCE7FF))),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
          ),
        ]),
      ),
    );
  }
}

/// Respuesta: dónde está en el documento, captura de la página y el texto original.
class _AnswerBubble extends StatelessWidget {
  const _AnswerBubble({required this.message, required this.index, required this.onAsk});
  final ChatMessage message;
  final int index;
  final ValueChanged<String> onAsk;

  void _openPage(BuildContext context, DocumentInfo doc, SourceRef s) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageViewerScreen(doc: doc, source: s)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    final doc = state.document;
    final speaking = state.speakingIndex == index;

    if (!message.found || message.sources.isEmpty || doc == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, right: 30),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warnBg,
            border: Border.all(color: AppColors.warnBorder),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.search_off_rounded, size: 20, color: AppColors.warnText),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.notFoundTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.warnText)),
                  const SizedBox(height: 2),
                  Text(l.notFoundBody, style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.warnText)),
                ]),
              ),
            ]),
            if (message.related.isNotEmpty) ...[
              const SizedBox(height: 10),
              SectionLabel(l.relatedTopics),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final t in message.related)
                  ActionChip(
                    label: Text(t),
                    labelStyle: const TextStyle(
                        fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.warnBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onPressed: state.limitReached ? null : () => onAsk(t),
                  ),
              ]),
            ],
          ]),
        ),
      );
    }

    final main = message.sources.first;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: kCardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Dónde está
          Row(children: [
            const Icon(Icons.description_outlined, size: 17, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                main.section.isEmpty ? l.foundIn(main.page) : '${l.foundIn(main.page)} · ${main.section}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          // Captura de la página
          SourceCapture(doc: doc, source: main, onTap: () => _openPage(context, doc, main)),
          const SizedBox(height: 4),
          Text(l.tapCapture, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
          const SizedBox(height: 10),
          // Texto original
          SelectableText(main.excerpt, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.ink)),
          if (message.sources.length > 1) ...[
            const SizedBox(height: 12),
            SectionLabel(l.otherMatches),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in message.sources.skip(1))
                ActionChip(
                  avatar: const Icon(Icons.description_outlined, size: 16, color: AppColors.primaryDark),
                  label: Text(s.section.isEmpty ? '${l.pg} ${s.page}' : '${l.pg} ${s.page} · ${s.section}'),
                  labelStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  backgroundColor: AppColors.soft,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onPressed: () => _openPage(context, doc, s),
                ),
            ]),
          ],
          const SizedBox(height: 12),
          // Escuchar / Pausar
          Semantics(
            button: true,
            toggled: speaking,
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () => state.toggleSpeak(index),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: speaking ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: speaking ? AppColors.primary : AppColors.lineStrong),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(speaking ? Icons.pause : Icons.volume_up_outlined,
                      size: 17, color: speaking ? Colors.white : AppColors.primary),
                  const SizedBox(width: 6),
                  if (speaking) ...[
                    const VoiceWave(bars: 4, height: 14, barWidth: 3, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Text(speaking ? l.pause : l.listen,
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: speaking ? Colors.white : AppColors.primary)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
        ]),
      ),
    );
  }
}

/// Aviso: respuestas tomadas del texto del manual.
class _AiNote extends StatelessWidget {
  const _AiNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.manage_search_rounded, size: 15, color: AppColors.muted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ),
        ],
      );
}

// ---------------- Paneles inferiores ----------------

class _InputBar extends StatelessWidget {
  const _InputBar(
      {required this.controller, required this.focusNode, required this.busy, required this.onSend, required this.onMic});
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final VoidCallback onSend;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppState>().l;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Tooltip(
            message: l.voiceAsk,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(side: BorderSide(color: AppColors.primary, width: 1.5)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: busy ? null : onMic,
                child: const SizedBox(
                    width: 50, height: 50, child: Icon(Icons.mic_none, color: AppColors.primary, size: 24)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!busy) onSend();
              },
              decoration: InputDecoration(hintText: l.askPh),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: l.send,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(gradient: kPrimaryGradient, shape: BoxShape.circle, boxShadow: kPrimaryShadow),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: busy ? null : onSend,
                  child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Panel de dictado. Se abre al instante y muestra en qué paso está el micrófono.
class _ListeningPanel extends StatelessWidget {
  const _ListeningPanel({required this.onSend, required this.onRetry, required this.onKeyboard});
  final VoidCallback onSend;
  final VoidCallback onRetry;
  final VoidCallback onKeyboard;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    final hasText = state.transcript.trim().isNotEmpty;
    final err = state.voiceError;
    final errorText = switch (err) {
      'denied' => l.micDenied,
      'blocked' => l.micBlocked,
      'unavailable' => l.sttUnavailable,
      'busy' => l.micBusy,
      'network' => l.voiceNetwork,
      'notHeard' => l.notHeard,
      _ => null,
    };

    final Widget center;
    if (state.micStarting) {
      center = const SizedBox(
          width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary));
    } else if (state.micActive) {
      center = const VoiceWave();
    } else if (err == 'blocked') {
      center = FilledButton.icon(
        onPressed: state.openMicSettings,
        icon: const Icon(Icons.settings_outlined),
        label: Text(l.openSettings),
      );
    } else if (err == 'unavailable') {
      center = FilledButton.icon(
        onPressed: onKeyboard,
        icon: const Icon(Icons.keyboard_voice_outlined),
        label: Text(l.useKeyboard),
      );
    } else {
      center = IconButton.filled(
        tooltip: l.tryAgain,
        iconSize: 28,
        style: IconButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(56, 56)),
        onPressed: onRetry,
        icon: const Icon(Icons.mic),
      );
    }

    final title = state.micStarting ? l.micPreparing : (state.micActive ? l.listening : l.voiceAsk);

    return _BottomSheetBox(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (state.micActive) ...[
            Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: AppColors.recording, shape: BoxShape.circle)),
            const SizedBox(width: 8),
          ],
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ]),
        const SizedBox(height: 14),
        center,
        const SizedBox(height: 14),
        Text(
          hasText ? '“${state.transcript}”' : (errorText ?? l.listeningHint),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: hasText ? 17 : 13.5,
            fontWeight: hasText || errorText != null ? FontWeight.w700 : FontWeight.w500,
            height: 1.4,
            color: hasText ? AppColors.ink : (errorText != null ? AppColors.processing : AppColors.muted),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(flex: 10, child: SecondaryButton(label: l.cancel, height: 52, onPressed: state.cancelListening)),
          const SizedBox(width: 12),
          Expanded(
            flex: 14,
            child: PrimaryButton(
              label: l.sendVoice,
              icon: Icons.arrow_upward_rounded,
              onPressed: hasText ? onSend : null,
            ),
          ),
        ]),
      ]),
    );
  }
}

class _LimitPanel extends StatelessWidget {
  const _LimitPanel();

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppState>().l;
    return _BottomSheetBox(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.amberBg, shape: BoxShape.circle),
            child: const Icon(Icons.schedule, color: AppColors.processing),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.limitTitle, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.25)),
              const SizedBox(height: 4),
              Text(l.limitBody, style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.body)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: kCardGradient, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Text(l.proTitle,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(7)),
                child: const Text('PRO',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3A2500))),
              ),
            ]),
            const SizedBox(height: 6),
            Text(l.proPitch, style: const TextStyle(fontSize: 14, height: 1.45, color: Color(0xFFDCE7FF))),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.navyBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle:
                      const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w800),
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProScreen())),
                child: Text(l.seeProBtn),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        SecondaryButton(label: l.gotIt, onPressed: () => Navigator.of(context).maybePop()),
      ]),
    );
  }
}

class _BottomSheetBox extends StatelessWidget {
  const _BottomSheetBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x240B1B3F), blurRadius: 30, offset: Offset(0, -10))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: SafeArea(top: false, child: child),
    );
  }
}
