import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'navigation.dart';

/// Elige un PDF o Word y abre la pantalla de procesamiento (todo ocurre en el teléfono).
/// Si ya hay un documento, primero pide confirmar el reemplazo (máximo 1).
Future<void> startUpload(BuildContext context) async {
  final state = context.read<AppState>();
  final l = state.l;

  if (!AppConfig.isPro && state.hasDocument) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.replaceTitle),
        content: Text(l.replaceBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.replaceOk)),
        ],
      ),
    );
    if (ok != true) return;
  }

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf', 'docx', 'doc'],
    withData: false,
  );
  if (result == null || result.files.isEmpty) return;
  final picked = result.files.single;
  if (!context.mounted) return;

  final name = picked.name;
  final lower = name.toLowerCase();
  if (lower.endsWith('.doc')) {
    showSnack(context, l.errOldDoc);
    return;
  }
  if (!(lower.endsWith('.pdf') || lower.endsWith('.docx')) || picked.path == null) {
    showSnack(context, l.pickFileError);
    return;
  }
  if (picked.size > AppConfig.maxFileSizeMb * 1024 * 1024) {
    showSnack(context, l.fileTooBig(AppConfig.maxFileSizeMb));
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => UploadScreen(file: File(picked.path!), fileName: name, sizeBytes: picked.size)),
  );
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, required this.file, required this.fileName, required this.sizeBytes});
  final File file;
  final String fileName;
  final int sizeBytes;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _working = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _upload());
  }

  Future<void> _upload() async {
    setState(() {
      _working = true;
      _failed = false;
    });
    try {
      await context.read<AppState>().uploadFile(widget.file, widget.fileName);
      if (mounted) setState(() => _working = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _working = false;
          _failed = true;
        });
      }
    }
  }

  void _goHome() => goToMain(context);

  String get _size {
    final mb = widget.sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    final doc = state.importing;
    final failed = _failed;
    final progress = doc?.progress ?? 0;
    final ready = !_working && !failed;
    final isDocx = widget.fileName.toLowerCase().endsWith('.docx');
    final errorText = switch (state.importError) {
      'scanned' => l.errScanned,
      'oldDoc' => l.errOldDoc,
      'password' => l.errPassword,
      'damaged' => l.errDamaged,
      _ => l.uploadError,
    };

    // Paso actual (0..4) según el avance.
    final step = ready ? 4 : (progress < 10 ? 0 : (progress < 85 ? 1 : (progress < 95 ? 2 : 3)));
    final steps = [l.s1, l.s2, l.s3, l.s4];

    return Scaffold(
      appBar: BackHeader(title: l.upload),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppConfig.isPro ? AppColors.soft : AppColors.amberBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(AppConfig.isPro ? l.proUploadNote : l.oneDocNote,
                    style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                        color: AppConfig.isPro ? AppColors.primaryDark : const Color(0xFF5A3A00))),
              ),
              const SizedBox(height: 16),
              CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      DocTypeBadge(type: isDocx ? 'docx' : 'pdf', width: 38, height: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          Text(_size, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                        ]),
                      ),
                      if (!failed)
                        Text(ready ? '100%' : '$progress%',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ready ? AppColors.primary : AppColors.processing)),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: failed ? 0 : (ready ? 1 : progress / 100),
                        minHeight: 6,
                        backgroundColor: AppColors.processingBg,
                        color: ready ? AppColors.primary : AppColors.processing,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (failed)
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.error_outline, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(errorText,
                                style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, height: 1.4))),
                      ])
                    else
                      for (var i = 0; i < steps.length; i++) _stepRow(steps[i], i < step, i == step),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (!failed)
                Row(children: [
                  const Icon(Icons.phone_android, size: 16, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.leaveNote, style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.muted)),
                  ),
                ]),
              const Spacer(),
              if (failed)
                PrimaryButton(label: l.back, icon: Icons.arrow_back, onPressed: () => Navigator.of(context).maybePop())
              else
                PrimaryButton(label: AppConfig.isPro ? l.goLibrary : l.goHome, onPressed: _working ? null : _goHome),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepRow(String text, bool done, bool current) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(
          width: 24,
          height: 24,
          child: done
              ? Container(
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 15, color: Colors.white),
                )
              : current
                  ? const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.processing)
                  : Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, border: Border.all(color: AppColors.lineStrong, width: 1.5)),
                    ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                  color: done || current ? AppColors.ink : AppColors.muted)),
        ),
      ]),
    );
  }
}
