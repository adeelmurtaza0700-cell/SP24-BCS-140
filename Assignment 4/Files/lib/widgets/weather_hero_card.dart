// widgets/weather_hero_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import 'rain_animation.dart';

class WeatherHeroCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherHeroCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final isNight = WeatherUtils.isNightTime(weather.sunrise, weather.sunset);
    final gradientColors =
        WeatherUtils.getWeatherGradient(weather.main, true, isNight: isNight);
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            _buildBackgroundDecor(isNight, weather.main),
            RainAnimation(
              isActive: weather.isRaining ||
                  weather.isSnowing ||
                  weather.isThundering,
              isSnow: weather.isSnowing,
              isThunder: weather.isThundering,
              intensity: weather.isRaining ? 2 : 1,
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${weather.cityName}, ${weather.country}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            provider.toggleFavorite(weather.cityName),
                        icon: Icon(
                          provider.isFavorite(weather.cityName)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: provider.isFavorite(weather.cityName)
                              ? Colors.redAccent
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    WeatherUtils.formatDateTime(weather.dt),
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),

                  const SizedBox(height: 12),

                  // Main area: temperature + icon. Use LayoutBuilder to adapt
                  Flexible(
                    fit: FlexFit.loose,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      final w = constraints.maxWidth;
                      // scale based on available height (allow down to 0.35)
                      final heightScale =
                          h > 0 ? (h / 140).clamp(0.35, 1.0) : 1.0;
                      // scale based on available width (allow down to 0.35)
                      final widthScale =
                          w > 0 ? (w / 300).clamp(0.35, 1.0) : 1.0;
                      // use the smaller scale to ensure content fits both axes
                      final scale =
                          heightScale < widthScale ? heightScale : widthScale;
                      final iconSize = (h * 0.55).clamp(40.0, 110.0);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: temperature content
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.formatTemp(weather.temperature),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 88 * scale,
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: -4,
                                    height: 1.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6 * scale),
                                Text(
                                  WeatherUtils.capitalizeFirst(
                                      weather.description),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22 * scale),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6 * scale),
                                Wrap(
                                  spacing: 8 * scale,
                                  runSpacing: 6 * scale,
                                  children: [
                                    _buildTempBadge(
                                        icon: Icons.arrow_upward,
                                        label: provider
                                            .formatTemp(weather.tempMax),
                                        color: Colors.orangeAccent,
                                        scale: scale),
                                    _buildTempBadge(
                                        icon: Icons.arrow_downward,
                                        label: provider
                                            .formatTemp(weather.tempMin),
                                        color: Colors.lightBlueAccent,
                                        scale: scale),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right: weather icon
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: _buildWeatherIcon(weather.icon),
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 14),

                  // Stats row (scale fonts based on available height)
                  LayoutBuilder(builder: (context, constraints) {
                    final localH = constraints.maxHeight > 0
                        ? constraints.maxHeight
                        : 80.0;
                    final localW =
                        constraints.maxWidth > 0 ? constraints.maxWidth : 360.0;
                    final hScale = (localH / 80).clamp(0.35, 1.0);
                    final wScale = (localW / 360).clamp(0.35, 1.0);
                    final statScale = hScale < wScale ? hScale : wScale;
                    return _buildStatsRow(weather, provider, scale: statScale);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecor(bool isNight, String main) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05))),
        ),
        Positioned(
          bottom: -60,
          left: -30,
          child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04))),
        ),
        if (isNight) ...[
          ...List.generate(12, (i) {
            final r = (i * 137.5) % 1;
            final x = (i * 73.3) % 1;
            final y = (i * 47.7) % 0.5;
            return Positioned(
                left: x * 400,
                top: y * 200,
                child: Container(
                  width: 1.5 + r * 1.5,
                  height: 1.5 + r * 1.5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.5 + r * 0.4)),
                ));
          }),
        ],
        if (main == 'Clouds' || main == 'Rain' || main == 'Drizzle') ...[
          Positioned(
              top: 30,
              right: 20,
              child: Opacity(opacity: 0.15, child: CloudWidget(size: 1.5))),
          Positioned(
              top: 60,
              left: 10,
              child: Opacity(opacity: 0.1, child: CloudWidget(size: 1.2))),
        ],
      ],
    );
  }

  Widget _buildWeatherIcon(String icon) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
      child: Image.network(
        WeatherUtils.getWeatherIconUrl(icon),
        width: 90,
        height: 90,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.wb_sunny, color: Colors.white, size: 60),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTempBadge(
      {required IconData icon,
      required String label,
      required Color color,
      double scale = 1.0}) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16 * scale)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14 * scale),
          SizedBox(width: 6 * scale),
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WeatherData weather, WeatherProvider provider,
      {double scale = 1.0}) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14 * scale)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: _buildStat(
                  Icons.water_drop, '${weather.humidity}%', 'Humidity',
                  scale: scale)),
          SizedBox(width: 8 * scale),
          Expanded(
              child: _buildStat(
                  Icons.air,
                  '${weather.windSpeed.toStringAsFixed(1)} m/s',
                  WeatherUtils.getWindDirection(weather.windDeg),
                  scale: scale)),
          SizedBox(width: 8 * scale),
          Expanded(
              child: _buildStat(
                  Icons.visibility,
                  '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                  'Visibility',
                  scale: scale)),
          SizedBox(width: 8 * scale),
          Expanded(
              child: _buildStat(
                  Icons.compress, '${weather.pressure} hPa', 'Pressure',
                  scale: scale)),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label,
      {double scale = 1.0}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18 * scale),
        SizedBox(height: 6 * scale),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700)),
        SizedBox(height: 4 * scale),
        Text(label,
            style: TextStyle(color: Colors.white60, fontSize: 10 * scale)),
      ],
    );
  }
}
