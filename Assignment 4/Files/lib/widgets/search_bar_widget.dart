import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherSearchBar extends StatefulWidget {
  final bool autofocus;
  final VoidCallback? onClose;

  const WeatherSearchBar({super.key, this.autofocus = false, this.onClose});

  @override
  State<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends State<WeatherSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      final provider = context.read<WeatherProvider>();
      final results = await provider.searchCities(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
          _isSearching = false;
        });
      }
    });
  }

  void _selectCity(String city) {
    final provider = context.read<WeatherProvider>();
    final cityName = city.split(',').first.trim();
    provider.fetchWeather(cityName);
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<WeatherProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? const Color(0xFF1E88E5)
                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
            ),
            boxShadow: [
              BoxShadow(
                color: _focusNode.hasFocus
                    ? const Color(0xFF1E88E5).withOpacity(0.15)
                    : Colors.transparent,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search,
                color: _focusNode.hasFocus ? const Color(0xFF1E88E5) : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onChanged,
                  onSubmitted: (v) {
                    if (v.isNotEmpty) _selectCity(v);
                  },
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A2F4A),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: Colors.grey,
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _suggestions = [];
                      _showSuggestions = false;
                    });
                  },
                ),
              if (widget.onClose != null)
                TextButton(
                  onPressed: widget.onClose,
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF1E88E5))),
                ),
            ],
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2F4A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _suggestions.asMap().entries.map((entry) {
                final i = entry.key;
                final city = entry.value;
                return InkWell(
                  onTap: () => _selectCity(city),
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: i == _suggestions.length - 1 ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: i > 0
                          ? Border(
                              top: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey.withOpacity(0.1),
                              ),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_city, size: 18, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            city,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1A2F4A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.north_west, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Recent & Favorites
        if (!_showSuggestions && _controller.text.isEmpty) ...[
          if (provider.favorites.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildQuickList('Favorites', provider.favorites, Icons.favorite, Colors.redAccent, isDark),
          ],
          if (provider.recentSearches.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildQuickList('Recent', provider.recentSearches.take(5).toList(), Icons.history, Colors.grey, isDark),
          ],
        ],
      ],
    );
  }

  Widget _buildQuickList(
    String title, List<String> items, IconData icon, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((city) {
            return GestureDetector(
              onTap: () => _selectCity(city),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(
                      city,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF1A2F4A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
