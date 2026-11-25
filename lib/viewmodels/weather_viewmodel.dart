import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/local_storage_service.dart';

enum WeatherLoadState { initial, loading, loaded, error }

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocalStorageService _storageService;

  WeatherViewModel({
    WeatherService? weatherService,
    LocalStorageService? storageService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _storageService = storageService ?? LocalStorageService();

  // ─── State ────────────────────────────────────────────────────────────────
  WeatherLoadState _loadState = WeatherLoadState.initial;
  WeatherModel? _weather;
  LocationModel? _selectedLocation;
  String? _errorMessage;
  List<LocationModel> _favorites = [];
  bool _isFavorite = false;

  // ─── Getters ──────────────────────────────────────────────────────────────
  WeatherLoadState get loadState => _loadState;
  WeatherModel? get weather => _weather;
  LocationModel? get selectedLocation => _selectedLocation;
  String? get errorMessage => _errorMessage;
  List<LocationModel> get favorites => _favorites;
  bool get isFavorite => _isFavorite;
  bool get isLoading => _loadState == WeatherLoadState.loading;

  // ─── Initialization ───────────────────────────────────────────────────────
  Future<void> init() async {
    _favorites = await _storageService.getFavorites();
    final lastLocation = await _storageService.getLastLocation();
    if (lastLocation != null) {
      await selectLocation(lastLocation);
    }
    notifyListeners();
  }

  // ─── Select Location & Load Weather ──────────────────────────────────────
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _loadState = WeatherLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _weatherService.getWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _loadState = WeatherLoadState.loaded;
      _isFavorite = await _storageService.isFavorite(location.id);
      await _storageService.saveLastLocation(location);
    } catch (e) {
      _loadState = WeatherLoadState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  // ─── Toggle Favorite ──────────────────────────────────────────────────────
  Future<void> toggleFavorite() async {
    if (_selectedLocation == null) return;
    if (_isFavorite) {
      await _storageService.removeFavorite(_selectedLocation!.id);
      _favorites.removeWhere((l) => l.id == _selectedLocation!.id);
      _isFavorite = false;
    } else {
      await _storageService.addFavorite(_selectedLocation!);
      if (!_favorites.any((l) => l.id == _selectedLocation!.id)) {
        _favorites.add(_selectedLocation!);
      }
      _isFavorite = true;
    }
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    if (_selectedLocation != null) {
      await selectLocation(_selectedLocation!);
    }
  }
}
