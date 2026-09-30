import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'navigation.dart';
import 'upload_screen.dart';

/// Pantalla de bienvenida (sin inicio de sesión).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _loadingSample = false;

  Future<void> _useSample() async {
    final state = context.read<AppState>();
    setState(() => _loadingSample = true);
    try {
      await state.useSample();
      await state.refreshUsage();
      if (!mounted) return;
      goToMain(context);
    } catch (_) {
      if (mounted) showSnack(context, state.l.uploadError);
    } finally {
      if (mounted) setState(() => _loadingSample = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppState>().l;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(left: 0, right: 0, bottom: 0, child: WaveFooter()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Marca + idioma
                    Row(
                      children: [
                        const BrandLogo(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Wordmark(),
                              const SizedBox(height: 2),
                              Text(l.brandSub,
                                  style: const TextStyle(fontSize: 11.5, height: 1.3, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        const LangSegment(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Título + robot
                    SizedBox(
                      height: 250,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: -20,
                            top: -10,
                            width: 180,
                            height: 230,
                            child: ExcludeSemantics(
                              child: Image.asset('assets/images/robot.png', fit: BoxFit.contain),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.tag1,
                                  style: const TextStyle(
                                      fontSize: 33, fontWeight: FontWeight.w800, height: 1.08, letterSpacing: -1)),
                              Text(l.tag2,
                                  style: const TextStyle(
                                      fontSize: 33,
                                      fontWeight: FontWeight.w800,
                                      height: 1.08,
                                      letterSpacing: -1,
                                      color: AppColors.primary)),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 220,
                                child: Text(l.sub,
                                    style: const TextStyle(fontSize: 14.5, height: 1.45, color: AppColors.body)),
                              ),
                              const Spacer(),
                              Row(children: [
                                _chip(Icons.picture_as_pdf_outlined, 'PDF', AppColors.primary),
                                _chip(Icons.description, 'Word', const Color(0xFF2F6BEA)),
                                _chip(Icons.menu_book_outlined, l.guides, AppColors.teal),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tarjeta de la versión básica
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(color: Color(0x1A0B4FD6), blurRadius: 34, offset: Offset(0, 14)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: AppColors.amberBg, borderRadius: BorderRadius.circular(10)),
                              child: Text(AppConfig.isPro ? 'PRO · ${l.proBadge}' : l.basicBadge,
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.amberText)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (AppConfig.isPro) ...[
                            _bullet(Icons.library_books_outlined, l.pb1),
                            _bullet(Icons.all_inclusive, l.pb2),
                            _bullet(Icons.mic_none, l.pb3),
                            _bullet(Icons.history, l.pb4),
                          ] else ...[
                            _bullet(Icons.description_outlined, l.b1),
                            _bullet(Icons.chat_bubble_outline, l.b2),
                            _bullet(Icons.mic_none, l.b4),
                            _bullet(Icons.verified_user_outlined, l.b3),
                          ],
                          const SizedBox(height: 6),
                          PrimaryButton(
                            label: l.uploadMine,
                            icon: Icons.upload_rounded,
                            height: 54,
                            onPressed: () => startUpload(context),
                          ),
                          const SizedBox(height: 10),
                          _loadingSample
                              ? const SizedBox(
                                  height: 48,
                                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                )
                              : SecondaryButton(label: l.useSample, onPressed: _useSample),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(color: AppColors.soft, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _bullet(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: AppColors.soft, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
