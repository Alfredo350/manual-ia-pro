import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Idioma de la app (ES / EN / PT).
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    final langs = [
      ('es', 'ES', 'Español', l.nameEs),
      ('en', 'EN', 'English', l.nameEn),
      ('pt', 'PT', 'Português', l.namePt),
    ];

    return Scaffold(
      appBar: BackHeader(title: l.language),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionLabel(l.appLang),
          const SizedBox(height: 10),
          for (final (code, short, native, sub) in langs)
            _Option(
              selected: state.lang == code,
              onTap: () => state.setLang(code),
              leading: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.soft2, borderRadius: BorderRadius.circular(10)),
                child: Text(short, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              title: native,
              subtitle: sub,
            ),
          const SizedBox(height: 4),
          Text(l.instant, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.soft2, borderRadius: BorderRadius.circular(14)),
            child: Text(l.langNote, style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.body)),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.selected, required this.onTap, required this.title, required this.subtitle, this.leading});
  final bool selected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        button: true,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: selected ? AppColors.primary : AppColors.line, width: selected ? 2 : 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                if (leading != null) ...[leading!, const SizedBox(width: 14)],
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.muted)),
                  ]),
                ),
                if (selected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 15, color: Colors.white),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
