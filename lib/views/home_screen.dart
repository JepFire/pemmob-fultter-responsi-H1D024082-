import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../models/weather_model.dart';
import '../utils/weather_helper.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, _) {
        final colors = vm.weather != null
            ? WeatherHelper.getGradientColors(vm.weather!.current.weatherCode)
            : [0xFF1976D2, 0xFF42A5F5];

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(colors[0]), Color(colors[1])],
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: vm.refreshWeather,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildAppBar(context, vm),
                    _buildBody(context, vm),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WeatherViewModel vm) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      title: GestureDetector(
        onTap: () => _openSearch(context, vm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.selectedLocation?.name ?? 'Pilih Kota...',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.search, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
      actions: [
        if (vm.selectedLocation != null)
          IconButton(
            icon: Icon(
              vm.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: vm.toggleFavorite,
            tooltip: vm.isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    return SliverFillRemaining(
      child: _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, WeatherViewModel vm) {
    switch (vm.loadState) {
      case WeatherLoadState.initial:
        return _buildInitialState(context, vm);
      case WeatherLoadState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case WeatherLoadState.loaded:
        return _buildWeatherContent(context, vm);
      case WeatherLoadState.error:
        return _buildErrorState(vm);
    }
  }

  Widget _buildInitialState(BuildContext context, WeatherViewModel vm) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_outlined, size: 80, color: Colors.white70),
          const SizedBox(height: 20),
          const Text(
            'Selamat Datang!',
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cari kota untuk melihat info cuaca',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          // Favorit
          if (vm.favorites.isNotEmpty) ...[
            const Text('Favorit Anda:', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: vm.favorites.map((loc) {
                return ActionChip(
                  label: Text(loc.name),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.white),
                  onPressed: () => vm.selectLocation(loc),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: () => _openSearch(context, vm),
            icon: const Icon(Icons.search),
            label: const Text('Cari Kota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WeatherViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              vm.errorMessage ?? 'Terjadi kesalahan',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: vm.refreshWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherViewModel vm) {
    final weather = vm.weather!;
    final location = vm.selectedLocation!;
    final current = weather.current;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Lokasi
            Text(
              location.displayName,
              style: const TextStyle(fontSize: 20, color: Colors.white70, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Cuaca emoji besar
            Text(
              WeatherHelper.getEmoji(current.weatherCode),
              style: const TextStyle(fontSize: 90),
            ),
            // Suhu utama
            Text(
              WeatherHelper.formatTemp(current.temperature2m),
              style: const TextStyle(
                fontSize: 72,
                color: Colors.white,
                fontWeight: FontWeight.w200,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            // Deskripsi cuaca
            Text(
              WeatherHelper.getDescription(current.weatherCode),
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            // Suhu dirasakan
            Text(
              'Terasa ${WeatherHelper.formatTemp(current.apparentTemperature)}',
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 24),
            // Kartu info cuaca tambahan
            _buildWeatherInfoCards(current),
            const SizedBox(height: 20),
            // Prakiraan mingguan
            _buildDailyForecast(weather.daily),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfoCards(CurrentWeather current) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _infoTile(Icons.water_drop, 'Kelembapan', WeatherHelper.formatHumidity(current.relativeHumidity2m)),
              const SizedBox(width: 16),
              _infoTile(Icons.air, 'Angin', WeatherHelper.formatWind(current.windSpeed10m)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoTile(Icons.umbrella, 'Curah Hujan', WeatherHelper.formatPrecipitation(current.precipitation)),
              const SizedBox(width: 16),
              _infoTile(Icons.thermostat, 'Terasa', WeatherHelper.formatTemp(current.apparentTemperature)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecast(List<DailyWeather> daily) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              const Text(
                'PRAKIRAAN 7 HARI',
                style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...daily.map((d) => _dailyRow(d)),
        ],
      ),
    );
  }

  Widget _dailyRow(DailyWeather d) {
    final dayName = DateFormat('EEEE', 'id_ID').format(d.date);
    final isToday = DateFormat('yyyy-MM-dd').format(d.date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              isToday ? 'Hari Ini' : dayName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(WeatherHelper.getEmoji(d.weatherCode), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.umbrella, size: 12, color: Colors.white60),
                const SizedBox(width: 2),
                Text(
                  WeatherHelper.formatProbability(d.precipitationProbabilityMax),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            WeatherHelper.formatTemp(d.temperatureMin),
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            WeatherHelper.formatTemp(d.temperatureMax),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _openSearch(BuildContext context, WeatherViewModel vm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (result != null && context.mounted) {
      await vm.selectLocation(result);
    }
  }
}
