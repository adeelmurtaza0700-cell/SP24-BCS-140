import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';

class SunriseTimelineCard extends StatelessWidget {
  final WeatherData weather;

  const SunriseTimelineCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = WeatherUtils.getSunProgress(weather.sunrise, weather.sunset);

    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSunArcWidget(progress, context),
          const SizedBox(height: 20),
          _buildTimeRow(weather, provider, isDark),
          const SizedBox(height: 16),
          _buildDaylightBar(progress, context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'Sun Timeline',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSunArcWidget(double progress, BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _SunArcPainter(progress: progress),
        size: const Size(double.infinity, 140),
      ),
    );
  }

  Widget _buildTimeRow(WeatherData weather, WeatherProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeInfo(
          icon: Icons.wb_sunny,
          color: Colors.orange,
          title: 'Sunrise',
          time: WeatherUtils.formatTime(weather.sunrise, timezone: weather.timezone),
        ),
        _buildDaylightDuration(weather),
        _buildTimeInfo(
          icon: Icons.nights_stay,
          color: Colors.deepOrange,
          title: 'Sunset',
          time: WeatherUtils.formatTime(weather.sunset, timezone: weather.timezone),
          alignRight: true,
        ),
      ],
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignRight) Icon(icon, color: color, size: 16),
            if (!alignRight) const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            if (alignRight) const SizedBox(width: 4),
            if (alignRight) Icon(icon, color: color, size: 16),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDaylightDuration(WeatherData weather) {
    final daylightSeconds = weather.sunset - weather.sunrise;
    final hours = daylightSeconds ~/ 3600;
    final minutes = (daylightSeconds % 3600) ~/ 60;
    return Column(
      children: [
        const Icon(Icons.light_mode, color: Colors.amber, size: 22),
        const SizedBox(height: 2),
        Text(
          '${hours}h ${minutes}m',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const Text('Daylight', style: TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildDaylightBar(double progress, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Day progress', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.orange),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Arc path
    final arcPath = Path();
    final startX = w * 0.05;
    final endX = w * 0.95;
    final peakY = h * 0.1;
    final baseY = h * 0.85;

    arcPath.moveTo(startX, baseY);
    arcPath.quadraticBezierTo(w / 2, peakY, endX, baseY);

    // Draw dashed arc (background)
    final dashedPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, arcPath, dashedPaint);

    // Draw progress arc
    final progressPath = _getProgressPath(startX, baseY, endX, peakY, w, progress);
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.orange, Colors.amber, Colors.deepOrange],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(progressPath, progressPaint);

    // Sun glow
    final sunPos = _getSunPosition(startX, baseY, endX, peakY, w, h, progress);
    final glowPaint = Paint()
      ..color = Colors.amber.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(sunPos, 20, glowPaint);

    // Sun circle
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.yellow, Colors.orange],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 14));
    canvas.drawCircle(sunPos, 14, sunPaint);

    // Horizon line
    final horizonPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, baseY), Offset(w, baseY), horizonPaint);

    // Ground gradient
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.orange.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, baseY, w, h - baseY));
    canvas.drawRect(Rect.fromLTWH(0, baseY, w, h - baseY), groundPaint);
  }

  Path _getProgressPath(
    double startX, double baseY, double endX, double peakY, double w, double progress) {
    final path = Path();
    path.moveTo(startX, baseY);
    final t = progress;
    final cp = Offset(w / 2, peakY);
    final start = Offset(startX, baseY);
    final end = Offset(endX, baseY);

    if (t <= 0) return path;

    final points = <Offset>[];
    final steps = 60;
    for (int i = 0; i <= (steps * t).round(); i++) {
      final s = i / steps;
      final pt = _quadBezier(start, cp, end, s);
      points.add(pt);
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    return path;
  }

  Offset _getSunPosition(
    double startX, double baseY, double endX, double peakY, double w, double h, double progress) {
    final start = Offset(startX, baseY);
    final end = Offset(endX, baseY);
    final cp = Offset(w / 2, peakY);
    return _quadBezier(start, cp, end, progress.clamp(0.0, 1.0));
  }

  Offset _quadBezier(Offset p0, Offset p1, Offset p2, double t) {
    return Offset(
      (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx,
      (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      bool draw = true;
      const dashLen = 6.0;
      const gapLen = 4.0;
      while (dist < metric.length) {
        final segLen = draw ? dashLen : gapLen;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(dist, dist + segLen),
            paint,
          );
        }
        dist += segLen;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}

class _CardWrapper extends StatelessWidget {
  final Widget child;

  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
