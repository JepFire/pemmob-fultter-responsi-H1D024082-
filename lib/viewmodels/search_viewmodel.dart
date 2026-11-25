import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';
import '../services/local_storage_service.dart';

enum SearchState { idle, loading, loaded, error }

class SearchViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocalStorageService _storageService;

  SearchViewModel({
    WeatherService? weatherService,
    LocalStorageService? storageService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _storageService = storageService ?? LocalStorageService();

  // ─── State ────────────────────────────────────────────────────────────────
  SearchState _searchState = SearchState.idle;
  List<LocationModel> _searchResults = [];
  List<String> _searchHistory = [];
  List<LocationModel> _favorites = [];
  String? _errorMessage;
  String _query = '';

  // ─── Getters ──────────────────────────────────────────────────────────────
  SearchState get searchState => _searchState;
  List<LocationModel> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;
  List<LocationModel> get favorites => _favorites;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _searchState == SearchState.loading;
  String get query => _query;

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _searchHistory = await _storageService.getSearchHistory();
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  // ─── Search (live, tanpa simpan history) ─────────────────────────────────
  Future<void> search(String query) async {
    _query = query;
    if (query.trim().isEmpty) {
      _searchState = SearchState.idle;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchState = SearchState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _weatherService.searchLocations(query);
      _searchState = SearchState.loaded;
    } catch (e) {
      _searchState = SearchState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchResults = [];
    }
    notifyListeners();
  }

  /// Simpan ke history — panggil hanya saat user submit (tekan Enter / pilih lokasi).
  Future<void> commitSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    await _storageService.addToSearchHistory(query.trim());
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    _searchHistory = [];
    notifyListeners();
  }

  Future<void> refreshFavorites() async {
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  void clearResults() {
    _searchResults = [];
    _searchState = SearchState.idle;
    _query = '';
    notifyListeners();
  }
}
