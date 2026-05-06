// widgets/air_quality_card.dart
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class AirQualityCard extends StatelessWidget {
  final AirQuality airQuality;

  const AirQualityCard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = WeatherUtils.getAqiColor(airQuality.aqi);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.air, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Air Quality',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  airQuality.aqiLabel,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // AQI progress
          _buildAqiGauge(airQuality.aqi, isDark),
          const SizedBox(height: 20),
          // Pollutant grid (responsive)
          LayoutBuilder(builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            // 3 columns on wide screens, 2 on narrow
            final crossCount = availableWidth > 360 ? 3 : 2;
            final spacing = 8.0;
            final tileWidth =
                (availableWidth - spacing * (crossCount - 1)) / crossCount;

            final tiles = [
              _buildPollutant('PM2.5', airQuality.pm2_5, 'μg/m³', 25, isDark),
              _buildPollutant('PM10', airQuality.pm10, 'μg/m³', 50, isDark),
              _buildPollutant('O₃', airQuality.o3, 'μg/m³', 100, isDark),
              _buildPollutant('NO₂', airQuality.no2, 'μg/m³', 40, isDark),
              _buildPollutant('SO₂', airQuality.so2, 'μg/m³', 20, isDark),
              _buildPollutant('CO', airQuality.co / 1000, 'mg/m³', 10, isDark),
            ];

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: tiles
                  .map((w) => SizedBox(
                      width: tileWidth.clamp(100.0, tileWidth), child: w))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAqiGauge(int aqi, bool isDark) {
    final color = WeatherUtils.getAqiColor(aqi);
    final progress = ((aqi - 1) / 4.0).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Good', 'Fair', 'Mod', 'Poor', 'V.Poor'].map((label) {
            return Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 9));
          }).toList(),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPollutant(
      String name, double value, String unit, double limit, bool isDark) {
    final ratio = (value / limit).clamp(0.0, 1.0);
    final color = ratio < 0.5
        ? Colors.green
        : ratio < 0.8
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value < 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 9)),
        ],
      ),
    );
  }
}
