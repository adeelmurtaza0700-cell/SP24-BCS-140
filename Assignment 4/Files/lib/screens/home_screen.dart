import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_hero_card.dart';
import '../widgets/sunrise_timeline.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/weekly_forecast.dart';
import '../widgets/rain_chart.dart';
import '../widgets/air_quality_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/rain_animation.dart';
import 'compare_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showSearch = false;
  late AnimationController _searchAnimController;
  late Animation<double> _searchAnim;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _searchAnim = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (_showSearch) {
      _searchAnimController.forward();
    } else {
      _searchAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(provider, isDark),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, provider, isDark),
                Expanded(
                  child: _buildBody(provider, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(WeatherProvider provider, bool isDark) {
    if (!provider.hasData) return Container(color: isDark ? const Color(0xFF0A1628) : const Color(0xFFF0F4FF));
    final weather = provider.currentWeather!;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1628) : const Color(0xFFF0F4FF),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WeatherProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // App title / city name
          Expanded(
            child: GestureDetector(
              onTap: _toggleSearch,
              child: Row(
                children: [
                  Text(
                    provider.hasData ? provider.currentCity : 'Weather',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _showSearch ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action buttons
          _buildIconBtn(
            icon: Icons.compare_arrows,
            tooltip: 'Compare Cities',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompareScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconBtn(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconBtn(
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onTap: () => provider.fetchWeather(provider.currentCity),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildBody(WeatherProvider provider, bool isDark) {
    return Column(
      children: [
        // Search overlay
        AnimatedBuilder(
          animation: _searchAnim,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _searchAnim,
              child: FadeTransition(
                opacity: _searchAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: WeatherSearchBar(
                    autofocus: _showSearch,
                    onClose: _toggleSearch,
                  ),
                ),
              ),
            );
          },
        ),

        // Main scrollable content
        Expanded(
          child: _buildScrollContent(provider, isDark),
        ),
      ],
    );
  }

  Widget _buildScrollContent(WeatherProvider provider, bool isDark) {
    if (provider.apiKey.isEmpty) {
      return _buildApiKeyPrompt(context, isDark);
    }

    if (provider.isLoading) {
      return _buildLoadingState(isDark);
    }

    if (provider.hasError) {
      return _buildErrorState(provider, isDark);
    }

    if (!provider.hasData) {
      return _buildEmptyState(isDark);
    }

    final weather = provider.currentWeather!;
    final daily = provider.dailyForecast;

    return RefreshIndicator(
      onRefresh: () => provider.fetchWeather(provider.currentCity),
      color: const Color(0xFF1E88E5),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        physics: const BouncingScrollPhysics(),
        children: [
          // Hero weather card
          WeatherHeroCard(weather: weather),
          const SizedBox(height: 20),

          // Sunrise timeline
          SunriseTimelineCard(weather: weather),
          const SizedBox(height: 16),

          // Hourly forecast
          if (provider.hourlyForecast.isNotEmpty) ...[
            HourlyForecastCard(hourly: provider.hourlyForecast),
            const SizedBox(height: 16),
          ],

          // Temperature trend chart
          if (provider.hourlyForecast.isNotEmpty) ...[
            TempChartCard(hourly: provider.hourlyForecast),
            const SizedBox(height: 16),
          ],

          // Rain chart
          if (provider.hourlyForecast.isNotEmpty) ...[
            RainChartCard(hourly: provider.hourlyForecast),
            const SizedBox(height: 16),
          ],

          // 7-day forecast
          if (daily.isNotEmpty) ...[
            WeeklyForecastCard(
              daily: daily.take(7).toList(),
              daysToShow: 7,
              title: '7-Day Forecast',
            ),
            const SizedBox(height: 16),
          ],

          // 30-day forecast
          if (daily.length > 7) ...[
            WeeklyForecastCard(
              daily: daily,
              daysToShow: daily.length.clamp(0, 30),
              title: '${daily.length}-Day Forecast',
            ),
            const SizedBox(height: 16),
          ],

          // Air quality
          if (provider.airQuality != null) ...[
            AirQualityCard(airQuality: provider.airQuality!),
            const SizedBox(height: 16),
          ],

          // Extra info cards row
          _buildExtraInfoRow(weather, isDark),
        ],
      ),
    );
  }

  Widget _buildExtraInfoRow(dynamic weather, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.thermostat,
            color: Colors.orange,
            title: 'Feels Like',
            value: context.read<WeatherProvider>().formatTemp(weather.feelsLike),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.cloud,
            color: Colors.blueGrey,
            title: 'Cloud Cover',
            value: '${weather.cloudiness}%',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.speed,
            color: Colors.deepOrange,
            title: 'Pressure',
            value: '${weather.pressure} hPa',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildApiKeyPrompt(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_outlined, size: 52, color: Color(0xFF1E88E5)),
            ),
            const SizedBox(height: 28),
            const Text(
              'Weather App',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -1),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your OpenWeatherMap API key in Settings to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildShimmer(height: MediaQuery.of(context).size.height * 0.52, isDark: isDark),
        const SizedBox(height: 16),
        _buildShimmer(height: 200, isDark: isDark),
        const SizedBox(height: 16),
        _buildShimmer(height: 160, isDark: isDark),
        const SizedBox(height: 16),
        _buildShimmer(height: 180, isDark: isDark),
      ],
    );
  }

  Widget _buildShimmer({required double height, required bool isDark}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorState(WeatherProvider provider, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              provider.error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchWeather(provider.currentCity),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Search for a city', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
