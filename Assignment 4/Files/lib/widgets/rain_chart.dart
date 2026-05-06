import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class RainChartCard extends StatefulWidget {
  final List<HourlyWeather> hourly;

  const RainChartCard({super.key, required this.hourly});

  @override
  State<RainChartCard> createState() => _RainChartCardState();
}

class _RainChartCardState extends State<RainChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = widget.hourly.take(24).toList();
    final hasRain = data.any((h) => h.pop > 0 || (h.rain != null && h.rain! > 0));

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop, color: Colors.lightBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Rain Probability',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasRain ? Colors.lightBlue : Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasRain ? 'Rain expected' : 'No rain',
                  style: TextStyle(
                    color: hasRain ? Colors.lightBlue : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: 100,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.spot?.touchedBarGroupIndex != null) {
                        _touchedIndex = response!.spot!.touchedBarGroupIndex;
                      } else {
                        _touchedIndex = -1;
                      }
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? const Color(0xFF0D47A1) : Colors.blue.shade700,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, gi, rod, ri) {
                      return BarTooltipItem(
                        '${rod.toY.round()}%\n${WeatherUtils.formatHour(data[group.x].dt)}',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i % 4 != 0 || i >= data.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            WeatherUtils.formatHour(data[i].dt),
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  final isTouched = _touchedIndex == i;
                  final pop = data[i].pop * 100;
                  final rainAmount = (data[i].rain ?? 0) * 10;
                  final displayVal = pop > 0 ? pop : rainAmount;

                  Color barColor;
                  if (pop >= 80) {
                    barColor = Colors.blue.shade700;
                  } else if (pop >= 50) {
                    barColor = Colors.blue.shade500;
                  } else if (pop >= 25) {
                    barColor = Colors.lightBlue;
                  } else {
                    barColor = Colors.lightBlue.withOpacity(0.4);
                  }

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: displayVal.clamp(0, 100),
                        color: isTouched ? Colors.blue.shade300 : barColor,
                        width: isTouched ? 9 : 7,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(context, data, isDark),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, List<HourlyWeather> data, bool isDark) {
    final maxRain = data.map((h) => h.rain ?? 0).reduce((a, b) => a > b ? a : b);
    final maxPop = data.map((h) => h.pop).reduce((a, b) => a > b ? a : b);
    final avgPop = data.map((h) => h.pop).reduce((a, b) => a + b) / data.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          icon: Icons.water_drop,
          color: Colors.lightBlue,
          label: 'Max probability',
          value: '${(maxPop * 100).round()}%',
        ),
        _buildLegendItem(
          icon: Icons.show_chart,
          color: Colors.blue,
          label: 'Avg probability',
          value: '${(avgPop * 100).round()}%',
        ),
        if (maxRain > 0)
          _buildLegendItem(
            icon: Icons.umbrella,
            color: Colors.blue.shade700,
            label: 'Max rain',
            value: '${maxRain.toStringAsFixed(1)} mm',
          ),
      ],
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}

class TempChartCard extends StatelessWidget {
  final List<HourlyWeather> hourly;

  const TempChartCard({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = hourly.take(24).toList();
    if (data.isEmpty) return const SizedBox.shrink();

    final temps = data.map((h) => h.temperature).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b) - 2;
    final maxTemp = temps.reduce((a, b) => a > b ? a : b) + 2;

    final spots = List.generate(data.length, (i) => FlSpot(i.toDouble(), temps[i]));

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.thermostat, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Temperature Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minTemp,
                maxY: maxTemp,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark ? const Color(0xFFB84300) : Colors.orange.shade700,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) => spots.map((s) {
                      final i = s.x.toInt();
                      return LineTooltipItem(
                        '${s.y.round()}°\n${WeatherUtils.formatHour(data[i].dt)}',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxTemp - minTemp) / 4,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= data.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            WeatherUtils.formatHour(data[i].dt),
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                        return Text(
                          '${value.round()}°',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: Colors.orange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.withOpacity(0.25),
                          Colors.orange.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
