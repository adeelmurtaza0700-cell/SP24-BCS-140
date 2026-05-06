import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyWeather> hourly;

  const HourlyForecastCard({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<WeatherProvider>();
    final displayList = hourly.take(24).toList();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.access_time, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Hourly Forecast',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '24 hours',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _buildHourlyItem(
                context,
                displayList[i],
                provider,
                isDark,
                isFirst: i == 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(
    BuildContext context,
    HourlyWeather h,
    WeatherProvider provider,
    bool isDark, {
    bool isFirst = false,
  }) {
    final isRain = h.main == 'Rain' || h.main == 'Drizzle';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      decoration: BoxDecoration(
        color: isFirst
            ? (isDark ? const Color(0xFF1E88E5).withOpacity(0.3) : const Color(0xFF1E88E5).withOpacity(0.1))
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst
              ? const Color(0xFF1E88E5).withOpacity(0.4)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          Text(
            isFirst ? 'Now' : WeatherUtils.formatHour(h.dt),
            style: TextStyle(
              color: isFirst ? const Color(0xFF1E88E5) : Colors.grey,
              fontSize: 12,
              fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          // Icon
          Image.network(
            WeatherUtils.getWeatherIconUrl(h.icon),
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, size: 28),
          ),
          // Temp
          Text(
            provider.formatTemp(h.temperature),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isFirst ? const Color(0xFF1E88E5) : null,
            ),
          ),
          // Rain probability
          if (isRain || h.pop > 0.1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, color: Colors.lightBlue, size: 10),
                const SizedBox(width: 2),
                Text(
                  '${(h.pop * 100).round()}%',
                  style: const TextStyle(color: Colors.lightBlue, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}
