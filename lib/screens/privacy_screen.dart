import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Privacidad: la app no recopila información, funciona sin internet y no usa IA.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppState>().l;
    final items = AppConfig.isPro
        ? [l.priv1, l.priv2, l.priv3pro, l.priv4, l.priv5pro]
        : [l.priv1, l.priv2, l.priv3, l.priv4, l.priv5];

    return Scaffold(
      appBar: BackHeader(title: l.privTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: kCardGradient, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0x2EFFFFFF), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(l.privLead,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3, color: Colors.white)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          CardBox(
            child: Column(children: [
              for (final t in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t, style: const TextStyle(fontSize: 14.5, height: 1.45))),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(16)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.manage_search_rounded, color: Color(0xFF3A2500), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.aiTitle,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.warnText)),
                  const SizedBox(height: 4),
                  Text(l.aiBody, style: const TextStyle(fontSize: 13.5, height: 1.5, color: Color(0xFF5A3A00))),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
