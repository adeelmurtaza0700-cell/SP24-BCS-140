// screens/compare_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import '../widgets/rain_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Cities'),
        backgroundColor:
            isDark ? const Color(0xFF0A1628) : const Color(0xFFF0F4FF),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1E88E5),
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Temperature'),
            Tab(text: 'Details'),
          ],
        ),
      ),
      body: Column(
        children: [
          // City input row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildCityInput(
                    controller: _ctrl1,
                    hint: 'City 1',
                    color: const Color(0xFF1E88E5),
                    onSearch: (city) => provider.fetchCompareCity(city, 1),
                    isDark: isDark,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.compare_arrows, size: 20),
                ),
                Expanded(
                  child: _buildCityInput(
                    controller: _ctrl2,
                    hint: 'City 2',
                    color: Colors.orange,
                    onSearch: (city) => provider.fetchCompareCity(city, 2),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverview(provider, isDark),
                _buildTempComparison(provider, isDark),
                _buildDetails(provider, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityInput({
    required TextEditingController controller,
    required String hint,
    required Color color,
    required Function(String) onSearch,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.location_city, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSearch,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: color, size: 18),
            onPressed: () {
              if (controller.text.isNotEmpty) onSearch(controller.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(WeatherProvider provider, bool isDark) {
    final w1 = provider.compareWeather1;
    final w2 = provider.compareWeather2;

    if (w1 == null && w2 == null) {
      return _buildEmptyCompare(isDark);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          // Side by side hero cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: w1 != null
                      ? _buildMiniWeatherCard(
                          w1, const Color(0xFF1E88E5), provider, isDark)
                      : _buildEmptySlot(isDark)),
              const SizedBox(width: 12),
              Expanded(
                  child: w2 != null
                      ? _buildMiniWeatherCard(
                          w2, Colors.orange, provider, isDark)
                      : _buildEmptySlot(isDark)),
            ],
          ),
          const SizedBox(height: 16),

          // Comparison stats
          if (w1 != null && w2 != null) ...[
            _buildComparisonTable(w1, w2, provider, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniWeatherCard(
      WeatherData w, Color accent, WeatherProvider provider, bool isDark) {
    final gradients = WeatherUtils.getWeatherGradient(w.main, true);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradients.first.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${w.cityName}, ${w.country}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Image.network(
            WeatherUtils.getWeatherIconUrl(w.icon),
            width: 50,
            height: 50,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.wb_sunny, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            provider.formatTemp(w.temperature),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w200,
                height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            WeatherUtils.capitalizeFirst(w.description),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _buildMiniStat(Icons.water_drop, '${w.humidity}%'),
          const SizedBox(height: 4),
          _buildMiniStat(Icons.air, '${w.windSpeed.toStringAsFixed(1)} m/s'),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildComparisonTable(
      WeatherData w1, WeatherData w2, WeatherProvider provider, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(w1.cityName, w2.cityName, isDark),
          _buildTableRow(
              'Temperature',
              provider.formatTemp(w1.temperature),
              provider.formatTemp(w2.temperature),
              isDark,
              w1.temperature,
              w2.temperature,
              true),
          _buildTableRow(
              'Feels Like',
              provider.formatTemp(w1.feelsLike),
              provider.formatTemp(w2.feelsLike),
              isDark,
              w1.feelsLike,
              w2.feelsLike,
              true),
          _buildTableRow('Humidity', '${w1.humidity}%', '${w2.humidity}%',
              isDark, w1.humidity.toDouble(), w2.humidity.toDouble(), false),
          _buildTableRow(
              'Wind Speed',
              '${w1.windSpeed.toStringAsFixed(1)} m/s',
              '${w2.windSpeed.toStringAsFixed(1)} m/s',
              isDark,
              w1.windSpeed,
              w2.windSpeed,
              false),
          _buildTableRow(
              'Visibility',
              '${(w1.visibility / 1000).toStringAsFixed(1)} km',
              '${(w2.visibility / 1000).toStringAsFixed(1)} km',
              isDark,
              w1.visibility.toDouble(),
              w2.visibility.toDouble(),
              true),
          _buildTableRow('Pressure', '${w1.pressure} hPa', '${w2.pressure} hPa',
              isDark, w1.pressure.toDouble(), w2.pressure.toDouble(), null),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String city1, String city2, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Expanded(
              flex: 2,
              child: Text('Metric',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.grey))),
          Expanded(
            flex: 3,
            child: Text(city1,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1E88E5)),
                textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: Text(city2,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.orange),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String label, String val1, String val2, bool isDark,
      double num1, double num2, bool? higherIsBetter) {
    Color? color1, color2;
    if (higherIsBetter != null) {
      final better = higherIsBetter ? (num1 > num2) : (num1 < num2);
      color1 = better ? Colors.green : (num1 == num2 ? null : Colors.red);
      color2 = !better ? Colors.green : (num1 == num2 ? null : Colors.red);
      if (num1 == num2) {
        color1 = null;
        color2 = null;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              val1,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              val2,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempComparison(WeatherProvider provider, bool isDark) {
    final h1 = provider.compareHourly1;
    final h2 = provider.compareHourly2;
    final w1 = provider.compareWeather1;
    final w2 = provider.compareWeather2;

    if (h1.isEmpty && h2.isEmpty) return _buildEmptyCompare(isDark);

    final count = h1.length < h2.length ? h1.length : h2.length;
    if (count == 0) return _buildEmptyCompare(isDark);

    final data1 = h1.take(count).toList();
    final data2 = h2.take(count).toList();

    final spots1 =
        List.generate(count, (i) => FlSpot(i.toDouble(), data1[i].temperature));
    final spots2 =
        List.generate(count, (i) => FlSpot(i.toDouble(), data2[i].temperature));

    final allTemps = [
      ...data1.map((e) => e.temperature),
      ...data2.map((e) => e.temperature)
    ];
    final minT = allTemps.reduce((a, b) => a < b ? a : b) - 2;
    final maxT = allTemps.reduce((a, b) => a > b ? a : b) + 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.withOpacity(0.12),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature Comparison (24h)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendDot(
                    const Color(0xFF1E88E5), w1?.cityName ?? 'City 1'),
                const SizedBox(width: 16),
                _buildLegendDot(Colors.orange, w2?.cityName ?? 'City 2'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (count - 1).toDouble(),
                  minY: minT,
                  maxY: maxT,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxT - minT) / 4,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= data1.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              WeatherUtils.formatHour(data1[i].dt),
                              style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.grey,
                                  fontSize: 10),
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
                          if (value == meta.max || value == meta.min)
                            return const SizedBox.shrink();
                          return Text(
                            '${value.round()}°',
                            style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.grey,
                                fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    if (spots1.isNotEmpty)
                      LineChartBarData(
                        spots: spots1,
                        isCurved: true,
                        color: const Color(0xFF1E88E5),
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF1E88E5).withOpacity(0.2),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    if (spots2.isNotEmpty)
                      LineChartBarData(
                        spots: spots2,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.orange.withOpacity(0.2),
                              Colors.transparent
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
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDetails(WeatherProvider provider, bool isDark) {
    final w1 = provider.compareWeather1;
    final w2 = provider.compareWeather2;
    if (w1 == null && w2 == null) return _buildEmptyCompare(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: w1 != null
                  ? _buildDetailColumn(
                      w1, const Color(0xFF1E88E5), provider, isDark)
                  : const SizedBox()),
          if (w1 != null && w2 != null) const SizedBox(width: 12),
          Expanded(
              child: w2 != null
                  ? _buildDetailColumn(w2, Colors.orange, provider, isDark)
                  : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(
      WeatherData w, Color accent, WeatherProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(w.cityName,
              style: TextStyle(
                  color: accent, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(w.country,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          _buildDetailItem('Temperature', provider.formatTemp(w.temperature),
              Icons.thermostat),
          _buildDetailItem('Feels Like', provider.formatTemp(w.feelsLike),
              Icons.device_thermostat),
          _buildDetailItem('Humidity', '${w.humidity}%', Icons.water_drop),
          _buildDetailItem(
              'Wind',
              '${w.windSpeed.toStringAsFixed(1)} m/s ${WeatherUtils.getWindDirection(w.windDeg)}',
              Icons.air),
          _buildDetailItem('Pressure', '${w.pressure} hPa', Icons.speed),
          _buildDetailItem(
              'Visibility',
              '${(w.visibility / 1000).toStringAsFixed(1)} km',
              Icons.visibility),
          _buildDetailItem('Cloudiness', '${w.cloudiness}%', Icons.cloud),
          _buildDetailItem(
              'Sunrise',
              WeatherUtils.formatTime(w.sunrise, timezone: w.timezone),
              Icons.wb_sunny),
          _buildDetailItem(
              'Sunset',
              WeatherUtils.formatTime(w.sunset, timezone: w.timezone),
              Icons.nights_stay),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off,
                size: 32, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'Select City',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCompare(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows,
              size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Enter two cities to compare',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Search and select cities above',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
