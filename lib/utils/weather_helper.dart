/// Helper untuk mengonversi kode cuaca WMO ke deskripsi dan ikon emoji.
class WeatherHelper {
  static String getDescription(int code) {
    if (code == 0) return 'Cerah';
    if (code == 1) return 'Sebagian Besar Cerah';
    if (code == 2) return 'Sebagian Berawan';
    if (code == 3) return 'Berawan';
    if (code >= 45 && code <= 48) return 'Berkabut';
    if (code >= 51 && code <= 55) return 'Gerimis';
    if (code >= 61 && code <= 65) return 'Hujan';
    if (code >= 71 && code <= 77) return 'Salju';
    if (code >= 80 && code <= 82) return 'Hujan Lebat';
    if (code == 95) return 'Badai Petir';
    if (code >= 96 && code <= 99) return 'Badai Petir + Hujan Es';
    return 'Tidak Diketahui';
  }

  static String getEmoji(int code) {
    if (code == 0) return '☀️';
    if (code == 1) return '🌤️';
    if (code == 2) return '⛅';
    if (code == 3) return '☁️';
    if (code >= 45 && code <= 48) return '🌫️';
    if (code >= 51 && code <= 55) return '🌦️';
    if (code >= 61 && code <= 65) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌧️';
    if (code == 95) return '⛈️';
    if (code >= 96 && code <= 99) return '⛈️';
    return '🌡️';
  }

  static String formatTemp(double temp) => '${temp.round()}°C';
  static String formatHumidity(double h) => '${h.round()}%';
  static String formatWind(double w) => '${w.round()} km/h';
  static String formatPrecipitation(double p) => '${p.toStringAsFixed(1)} mm';
  static String formatProbability(double p) => '${p.round()}%';

  /// Gradien warna latar berdasarkan kode cuaca
  static List<int> getGradientColors(int code) {
    if (code == 0 || code == 1) return [0xFF1E90FF, 0xFF87CEEB]; // cerah biru
    if (code == 2 || code == 3) return [0xFF6B7B8D, 0xFF9BAAB8]; // berawan
    if (code >= 45 && code <= 48) return [0xFF8E9EAB, 0xFFB0BEC5]; // kabut
    if (code >= 51 && code <= 82) return [0xFF4A6FA5, 0xFF5F87B3]; // hujan
    if (code >= 71 && code <= 77) return [0xFF90A4AE, 0xFFB0BEC5]; // salju
    if (code >= 95) return [0xFF37474F, 0xFF546E7A]; // badai
    return [0xFF1976D2, 0xFF42A5F5];
  }
}
