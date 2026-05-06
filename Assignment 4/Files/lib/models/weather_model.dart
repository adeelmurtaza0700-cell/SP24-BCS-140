class WeatherData {
  final String cityName;
  final String country;
  final double lat;
  final double lon;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String icon;
  final String main;
  final int pressure;
  final int visibility;
  final int sunrise;
  final int sunset;
  final int timezone;
  final int cloudiness;
  final double? rain1h;
  final double? snow1h;
  final int dt;
  final int uvIndex;

  const WeatherData({
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.icon,
    required this.main,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
    required this.cloudiness,
    this.rain1h,
    this.snow1h,
    required this.dt,
    this.uvIndex = 0,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;
    final coord = json['coord'] as Map<String, dynamic>;

    return WeatherData(
      cityName: json['name'] as String,
      country: sys['country'] as String? ?? '',
      lat: (coord['lat'] as num).toDouble(),
      lon: (coord['lon'] as num).toDouble(),
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      windDeg: (wind['deg'] as num?)?.toInt() ?? 0,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      main: weather['main'] as String,
      pressure: main['pressure'] as int,
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      sunrise: sys['sunrise'] as int,
      sunset: sys['sunset'] as int,
      timezone: json['timezone'] as int,
      cloudiness: (json['clouds'] as Map<String, dynamic>?)?['all'] as int? ?? 0,
      rain1h: ((json['rain'] as Map<String, dynamic>?)?['1h'] as num?)?.toDouble(),
      snow1h: ((json['snow'] as Map<String, dynamic>?)?['1h'] as num?)?.toDouble(),
      dt: json['dt'] as int,
    );
  }

  bool get isRaining => main == 'Rain' || main == 'Drizzle' || (rain1h != null && rain1h! > 0);
  bool get isSnowing => main == 'Snow' || (snow1h != null && snow1h! > 0);
  bool get isCloudy => main == 'Clouds';
  bool get isClear => main == 'Clear';
  bool get isThundering => main == 'Thunderstorm';
}

class HourlyWeather {
  final int dt;
  final double temperature;
  final double feelsLike;
  final String description;
  final String icon;
  final String main;
  final int humidity;
  final double windSpeed;
  final double? rain;
  final double? snow;
  final int cloudiness;
  final double pop;

  const HourlyWeather({
    required this.dt,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.main,
    required this.humidity,
    required this.windSpeed,
    this.rain,
    this.snow,
    required this.cloudiness,
    required this.pop,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final mainData = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return HourlyWeather(
      dt: json['dt'] as int,
      temperature: (mainData['temp'] as num).toDouble(),
      feelsLike: (mainData['feels_like'] as num).toDouble(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      main: weather['main'] as String,
      humidity: mainData['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      rain: ((json['rain'] as Map<String, dynamic>?)?['3h'] as num?)?.toDouble(),
      snow: ((json['snow'] as Map<String, dynamic>?)?['3h'] as num?)?.toDouble(),
      cloudiness: (json['clouds'] as Map<String, dynamic>?)?['all'] as int? ?? 0,
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyForecast {
  final int dt;
  final double tempMin;
  final double tempMax;
  final double tempDay;
  final double tempNight;
  final String description;
  final String icon;
  final String main;
  final int humidity;
  final double windSpeed;
  final double? rain;
  final double? snow;
  final double pop;
  final int sunrise;
  final int sunset;
  final double uvi;

  const DailyForecast({
    required this.dt,
    required this.tempMin,
    required this.tempMax,
    required this.tempDay,
    required this.tempNight,
    required this.description,
    required this.icon,
    required this.main,
    required this.humidity,
    required this.windSpeed,
    this.rain,
    this.snow,
    required this.pop,
    required this.sunrise,
    required this.sunset,
    required this.uvi,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final temp = json['temp'] as Map<String, dynamic>;

    return DailyForecast(
      dt: json['dt'] as int,
      tempMin: (temp['min'] as num).toDouble(),
      tempMax: (temp['max'] as num).toDouble(),
      tempDay: (temp['day'] as num).toDouble(),
      tempNight: (temp['night'] as num).toDouble(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      main: weather['main'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['wind_speed'] as num).toDouble(),
      rain: (json['rain'] as num?)?.toDouble(),
      snow: (json['snow'] as num?)?.toDouble(),
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
      sunrise: json['sunrise'] as int,
      sunset: json['sunset'] as int,
      uvi: (json['uvi'] as num).toDouble(),
    );
  }
}

class AirQuality {
  final int aqi;
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;

  const AirQuality({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final list = json['list'][0] as Map<String, dynamic>;
    final main = list['main'] as Map<String, dynamic>;
    final components = list['components'] as Map<String, dynamic>;

    return AirQuality(
      aqi: main['aqi'] as int,
      co: (components['co'] as num).toDouble(),
      no: (components['no'] as num).toDouble(),
      no2: (components['no2'] as num).toDouble(),
      o3: (components['o3'] as num).toDouble(),
      so2: (components['so2'] as num).toDouble(),
      pm2_5: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      nh3: (components['nh3'] as num).toDouble(),
    );
  }

  String get aqiLabel {
    switch (aqi) {
      case 1: return 'Good';
      case 2: return 'Fair';
      case 3: return 'Moderate';
      case 4: return 'Poor';
      case 5: return 'Very Poor';
      default: return 'Unknown';
    }
  }
}
