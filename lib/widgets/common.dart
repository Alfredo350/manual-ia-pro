import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

/// Logo cuadrado azul con destello.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 52});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 8,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryLight, Color(0xFF0A3FB8)],
                ),
                borderRadius: BorderRadius.circular(size * 0.3),
                boxShadow: kPrimaryShadow,
              ),
              child: Icon(Icons.description_outlined, color: Colors.white, size: size * 0.5),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.auto_awesome, color: AppColors.amber, size: size * 0.32),
          ),
        ],
      ),
    );
  }
}

/// "MANUAL.IA"
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 21});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: const [
        TextSpan(text: 'MANUAL'),
        TextSpan(text: '.IA', style: TextStyle(color: AppColors.primary)),
      ]),
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.1),
    );
  }
}

/// Botón principal azul con degradado.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: kPrimaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled ? kPrimaryShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10)],
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón blanco con borde.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.accent = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  /// true = borde y texto azules.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.primary : AppColors.ink;
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          side: BorderSide(color: accent ? AppColors.primary : AppColors.lineStrong, width: accent ? 1.5 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

/// Selector ES | EN | PT.
class LangSegment extends StatelessWidget {
  const LangSegment({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    const codes = ['es', 'en', 'pt'];
    const names = {'es': 'Español', 'en': 'English', 'pt': 'Português'};
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.soft2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in codes)
            Semantics(
              label: names[c],
              selected: state.lang == c,
              button: true,
              child: GestureDetector(
                onTap: () => state.setLang(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: state.lang == c ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: state.lang == c ? kPrimaryShadow : null,
                  ),
                  child: Text(
                    c.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: state.lang == c ? FontWeight.w700 : FontWeight.w500,
                      color: state.lang == c ? Colors.white : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Barra de 5 segmentos con las preguntas usadas.
class UsageDots extends StatelessWidget {
  const UsageDots({super.key, required this.used, required this.limit, this.dark = false});
  final int used;
  final int limit;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < limit; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: i < used
                    ? (dark ? AppColors.barLight : AppColors.primary)
                    : (dark ? const Color(0x38FFFFFF) : AppColors.lineStrong),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Etiqueta PDF / DOC.
class DocTypeBadge extends StatelessWidget {
  const DocTypeBadge({super.key, required this.type, this.width = 46, this.height = 56});
  final String type;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pdf = type == 'pdf';
    return Container(
      width: width,
      height: height,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: pdf ? AppColors.pdfBg : AppColors.docBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        pdf ? 'PDF' : 'DOC',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: pdf ? AppColors.pdfText : AppColors.docText,
        ),
      ),
    );
  }
}

/// Tarjeta blanca con borde y sombra suave.
class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 18});
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.line),
        boxShadow: kCardShadow,
      ),
      child: child,
    );
  }
}

/// Título pequeño en mayúsculas.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color = AppColors.muted});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: color),
      );
}

/// Ola azul decorativa del pie de pantalla.
class WaveFooter extends StatelessWidget {
  const WaveFooter({super.key, this.height = 60});
  final double height;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(double.infinity, height), painter: _WavePainter());
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final back = Path()
      ..moveTo(0, h * 0.57)
      ..cubicTo(w * 0.23, h * 0.17, w * 0.44, h * 0.97, w * 0.67, h * 0.5)
      ..cubicTo(w * 0.8, h * 0.25, w * 0.92, h * 0.13, w, h * 0.3)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final front = Path()
      ..moveTo(0, h * 0.77)
      ..cubicTo(w * 0.28, h * 0.43, w * 0.51, h * 1.07, w * 0.77, h * 0.67)
      ..cubicTo(w * 0.87, h * 0.52, w * 0.95, h * 0.5, w, h * 0.57)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xB3BFD6FF));
    canvas.drawPath(front, Paint()..color = const Color(0xE62F6BEA));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ondas animadas (dictado y lectura en voz alta).
class VoiceWave extends StatefulWidget {
  const VoiceWave({super.key, this.bars = 13, this.height = 44, this.barWidth = 5, this.color});
  final int bars;
  final double height;
  final double barWidth;
  final Color? color;

  @override
  State<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<VoiceWave> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return ExcludeSemantics(
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.bars; i++)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: widget.barWidth * 0.45),
                  width: widget.barWidth,
                  height: widget.height *
                      (reduce ? 0.6 : 0.3 + 0.7 * (0.5 + 0.5 * math.sin(_c.value * 2 * math.pi + i * 0.9)).abs()),
                  decoration: BoxDecoration(
                    color: widget.color,
                    gradient: widget.color == null ? kPrimaryGradient : null,
                    borderRadius: BorderRadius.circular(widget.barWidth),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encabezado con botón de volver.
class BackHeader extends StatelessWidget implements PreferredSizeWidget {
  const BackHeader({super.key, required this.title, this.onBack, this.closeIcon = false, this.actions});
  final String title;
  final VoidCallback? onBack;
  final bool closeIcon;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final l = context.watch<AppState>().l;
    return AppBar(
      leading: IconButton(
        tooltip: closeIcon ? l.close : l.back,
        icon: Icon(closeIcon ? Icons.close : Icons.arrow_back_ios_new, size: 22),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(title),
      actions: actions,
    );
  }
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
