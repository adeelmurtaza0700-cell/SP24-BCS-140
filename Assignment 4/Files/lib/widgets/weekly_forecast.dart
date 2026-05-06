import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';

class WeeklyForecastCard extends StatefulWidget {
  final List<DailyForecast> daily;
  final int daysToShow;
  final String title;

  const WeeklyForecastCard({
    super.key,
    required this.daily,
    this.daysToShow = 7,
    this.title = '7-Day Forecast',
  });

  @override
  State<WeeklyForecastCard> createState() => _WeeklyForecastCardState();
}

class _WeeklyForecastCardState extends State<WeeklyForecastCard> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<WeatherProvider>();
    final days = widget.daily.take(widget.daysToShow).toList();

    // Compute min/max across all days for bar scaling
    final allMin = days.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b);
    final allMax = days.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b);

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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ...List.generate(days.length, (i) {
            return _buildDayRow(context, days[i], provider, isDark, i, allMin, allMax);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    DailyForecast day,
    WeatherProvider provider,
    bool isDark,
    int index,
    double allMin,
    double allMax,
  ) {
    final isExpanded = _expandedIndex == index;
    final isToday = index == 0;
    final range = allMax - allMin;
    final minNorm = range > 0 ? (day.tempMin - allMin) / range : 0.0;
    final maxNorm = range > 0 ? (day.tempMax - allMin) / range : 1.0;

    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isToday
              ? (isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isToday
              ? Border.all(color: Colors.blue.withOpacity(0.2))
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Day
                SizedBox(
                  width: 44,
                  child: Text(
                    isToday ? 'Today' : WeatherUtils.formatDay(day.dt),
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                      color: isToday ? const Color(0xFF1E88E5) : null,
                    ),
                  ),
                ),
                // Icon
                Image.network(
                  WeatherUtils.getWeatherIconUrl(day.icon),
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, size: 24),
                ),
                const SizedBox(width: 4),
                // Rain %
                SizedBox(
                  width: 36,
                  child: day.pop > 0.1
                      ? Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.lightBlue, size: 10),
                            const SizedBox(width: 1),
                            Text(
                              '${(day.pop * 100).round()}%',
                              style: const TextStyle(color: Colors.lightBlue, fontSize: 10),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const Spacer(),
                // Temp range bar
                Expanded(
                  flex: 3,
                  child: _buildTempBar(day, minNorm, maxNorm, isDark),
                ),
                const SizedBox(width: 8),
                // Min temp
                SizedBox(
                  width: 42,
                  child: Text(
                    provider.formatTemp(day.tempMin),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Max temp
                SizedBox(
                  width: 42,
                  child: Text(
                    provider.formatTemp(day.tempMax),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              _buildExpandedDetails(context, day, provider, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTempBar(DailyForecast day, double minNorm, double maxNorm, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final barLeft = minNorm * w;
        final barWidth = (maxNorm - minNorm) * w;

        return Stack(
          children: [
            // Background
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Fill
            Positioned(
              left: barLeft,
              child: Container(
                width: barWidth.clamp(8.0, w),
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTempColor(day.tempMin),
                      _getTempColor(day.tempMax),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedDetails(
    BuildContext context,
    DailyForecast day,
    WeatherProvider provider,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailStat(Icons.water_drop, '${day.humidity}%', 'Humidity', Colors.blue),
              _buildDetailStat(Icons.air, '${day.windSpeed.toStringAsFixed(1)} m/s', 'Wind', Colors.green),
              _buildDetailStat(Icons.wb_sunny, '${day.uvi.toStringAsFixed(1)}', 'UV Index',
                WeatherUtils.getUvColor(day.uvi)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailStat(Icons.thermostat, provider.formatTemp(day.tempDay), 'Day', Colors.orange),
              _buildDetailStat(Icons.nights_stay, provider.formatTemp(day.tempNight), 'Night', Colors.deepPurple),
              _buildDetailStat(
                Icons.description_outlined,
                WeatherUtils.capitalizeFirst(day.description),
                'Condition',
                Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Color _getTempColor(double temp) {
    if (temp <= 0) return Colors.lightBlue;
    if (temp <= 10) return Colors.blue;
    if (temp <= 20) return Colors.green;
    if (temp <= 30) return Colors.orange;
    return Colors.red;
  }
}
