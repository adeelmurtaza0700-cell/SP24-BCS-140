import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart' show WeatherProvider, TempUnit, AppThemeMode;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyCtrl = TextEditingController();
  bool _obscureKey = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WeatherProvider>();
    _apiKeyCtrl.text = provider.apiKey;
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyCtrl.text.trim();
    if (key.isEmpty) return;
    setState(() => _isSaving = true);
    await context.read<WeatherProvider>().setApiKey(key);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('API key saved successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // API Key section
          _buildSectionHeader('API Configuration', Icons.key, Colors.amber, isDark),
          const SizedBox(height: 12),
          _buildApiKeyCard(isDark),
          const SizedBox(height: 8),
          _buildApiKeyHint(isDark),

          const SizedBox(height: 28),

          // Units section
          _buildSectionHeader('Units', Icons.straighten, const Color(0xFF1E88E5), isDark),
          const SizedBox(height: 12),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                _buildRadioTile(
                  title: 'Celsius (°C)',
                  subtitle: 'Metric system',
                  value: TempUnit.celsius,
                  groupValue: provider.tempUnit,
                  onChanged: (v) => provider.setTempUnit(v!),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildRadioTile(
                  title: 'Fahrenheit (°F)',
                  subtitle: 'Imperial system',
                  value: TempUnit.fahrenheit,
                  groupValue: provider.tempUnit,
                  onChanged: (v) => provider.setTempUnit(v!),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Theme section
          _buildSectionHeader('Appearance', Icons.palette_outlined, Colors.green, isDark),
          const SizedBox(height: 12),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                _buildRadioTile(
                  title: 'Light Mode',
                  subtitle: 'Always light theme',
                  value: AppThemeMode.light,
                  groupValue: provider.themeMode,
                  onChanged: (v) => provider.setThemeMode(v!),
                  leadingIcon: Icons.light_mode,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildRadioTile(
                  title: 'Dark Mode',
                  subtitle: 'Always dark theme',
                  value: AppThemeMode.dark,
                  groupValue: provider.themeMode,
                  onChanged: (v) => provider.setThemeMode(v!),
                  leadingIcon: Icons.dark_mode,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildRadioTile(
                  title: 'System Default',
                  subtitle: 'Follow system setting',
                  value: AppThemeMode.auto,
                  groupValue: provider.themeMode,
                  onChanged: (v) => provider.setThemeMode(v!),
                  leadingIcon: Icons.brightness_auto,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // About section
          _buildSectionHeader('About', Icons.info_outline, Colors.grey, isDark),
          const SizedBox(height: 12),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                _buildInfoTile('App Version', '1.0.0', Icons.apps, isDark),
                _buildDivider(isDark),
                _buildInfoTile('Data Provider', 'OpenWeatherMap', Icons.cloud, isDark),
                _buildDivider(isDark),
                _buildInfoTile('Built with', 'Flutter', Icons.flutter_dash, isDark),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Favorites management
          if (provider.favorites.isNotEmpty) ...[
            _buildSectionHeader('Favorites', Icons.favorite, Colors.redAccent, isDark),
            const SizedBox(height: 12),
            _buildCard(
              isDark: isDark,
              child: Column(
                children: provider.favorites.asMap().entries.map((entry) {
                  final i = entry.key;
                  final city = entry.value;
                  return Column(
                    children: [
                      if (i > 0) _buildDivider(isDark),
                      ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                        title: Text(city, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                          onPressed: () => provider.toggleFavorite(city),
                        ),
                        onTap: () {
                          provider.fetchWeather(city);
                          Navigator.pop(context);
                        },
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyCard(bool isDark) {
    return _buildCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OpenWeatherMap API Key',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyCtrl,
              obscureText: _obscureKey,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF1A2F4A),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your API key...',
                hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'sans-serif'),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save API Key', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyHint(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Get a free API key from openweathermap.org. Sign up, go to API keys section, and copy your key.',
              style: TextStyle(
                color: isDark ? Colors.amber.shade200 : Colors.amber.shade800,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    IconData? leadingIcon,
    required bool isDark,
  }) {
    final isSelected = value == groupValue;
    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: const Color(0xFF1E88E5),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 16, color: isSelected ? const Color(0xFF1E88E5) : Colors.grey),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              color: isSelected ? const Color(0xFF1E88E5) : null,
            ),
          ),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, bool isDark) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
