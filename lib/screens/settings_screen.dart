import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'language_screen.dart';
import 'privacy_screen.dart';
import 'pro_screen.dart';
import 'upload_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = state.l;
    const names = {'es': 'Español', 'en': 'English', 'pt': 'Português'};

    return Scaffold(
      appBar: BackHeader(title: l.settings),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _Group(children: [
            _Row(
              icon: Icons.language,
              label: l.language,
              value: names[state.lang],
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanguageScreen())),
            ),
            MergeSemantics(
              child: SwitchListTile(
                value: state.autoRead,
                onChanged: state.setAutoRead,
                activeTrackColor: AppColors.primary,
                secondary: const Icon(Icons.volume_up_outlined, color: AppColors.ink),
                title: Text(l.autoRead, style: const TextStyle(fontSize: 15)),
                subtitle: Text(l.autoReadSub, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
            if (AppConfig.isPro)
              _Row(
                icon: Icons.library_books_outlined,
                label: l.docsRow,
                value: '${state.documents.length}',
                onTap: () => Navigator.of(context).maybePop(),
                last: true,
              )
            else ...[
              _Row(
                icon: Icons.chat_bubble_outline,
                label: l.today,
                value: l.usedOf(state.usage.usedToday),
              ),
              _Row(
                icon: Icons.description_outlined,
                label: l.docRow,
                value: state.document?.name ?? '—',
                onTap: () => startUpload(context),
                last: true,
              ),
            ],
          ]),
          const SizedBox(height: 16),
          _Group(children: [
            if (!AppConfig.isPro)
              _Row(
                icon: Icons.auto_awesome_outlined,
                label: l.proRow,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProScreen())),
              ),
            _Row(
              icon: Icons.lock_outline,
              label: l.privacy,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
            ),
            _Row(
              icon: Icons.info_outline,
              label: l.about,
              value: AppConfig.isPro ? l.versionPro : '${l.version} (${AppConfig.appVersion})',
              last: true,
            ),
          ]),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: kCardShadow,
        ),
        child: Column(children: children),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, this.value, this.onTap, this.last = false});
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: Color(0xFFE9EFFA))),
        ),
        child: Row(children: [
          Icon(icon, color: AppColors.ink, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          if (value != null)
            Flexible(
              child: Text(value!,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted)),
            ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ]),
      ),
    );
  }
}
