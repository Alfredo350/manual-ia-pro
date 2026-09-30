import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Presenta MANUAL IA Pro (app aparte en Google Play).
class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  Future<void> _openStore(BuildContext context) async {
    final ok = await launchUrl(Uri.parse(AppConfig.proStoreUrl), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) showSnack(context, context.read<AppState>().l.errorGeneric);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppState>().l;
    final features = [l.pf1, l.pf2, l.pf3, l.pf4];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Container(
          height: 360,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.navyBlue, AppColors.primary],
            ),
          ),
        ),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: l.close,
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const BrandLogo(size: 48),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(8)),
                      child: const Text('PRO',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF3A2500))),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  Text(l.proH1,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w800, height: 1.12, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text(l.proSub, style: const TextStyle(fontSize: 15, height: 1.45, color: Color(0xFFDCE7FF))),
                ]),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Color(0x290B1B3F), blurRadius: 34, offset: Offset(0, 14))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final f in features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 15, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(f, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                    child: Text(l.youHave, style: const TextStyle(fontSize: 13, color: AppColors.body)),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: l.getPro, icon: Icons.play_arrow_rounded, height: 54, onPressed: () => _openStore(context)),
                ]),
              ),
              const SizedBox(height: 14),
              Text(l.proNote,
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.muted)),
            ],
          ),
        ),
      ]),
    );
  }
}
