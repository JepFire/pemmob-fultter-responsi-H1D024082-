import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../models/location_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().init();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectLocation(
    BuildContext context,
    LocationModel loc, {
    bool saveHistory = true,
  }) {
    final vm = context.read<SearchViewModel>();
    if (saveHistory) {
      // Simpan teks pencarian utuh yang diketik user (bukan nama opsi yang dipilih)
      final typedQuery = _controller.text.trim();
      if (typedQuery.isNotEmpty) {
        vm.commitSearchHistory(typedQuery);
      }
    }
    vm.clearResults();
    Navigator.pop(context, loc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchBar(),
        titleSpacing: 0,
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, vm, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vm.isLoading)
                const LinearProgressIndicator(color: Colors.blue),
              Expanded(
                child: _buildContent(context, vm),
              ),
              if (vm.favorites.isNotEmpty)
                _buildFavoritesSection(context, vm.favorites),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<SearchViewModel>(
      builder: (context, vm, _) {
        return TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            hintText: 'Cari kota...',
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _controller.clear();
                      vm.clearResults();
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {}); // rebuild for suffix icon
            if (value.length >= 2) {
              vm.search(value);
            } else if (value.isEmpty) {
              vm.clearResults();
            }
          },
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) {
              vm.search(trimmed);
              vm.commitSearchHistory(trimmed);
            }
          },
          textInputAction: TextInputAction.search,
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SearchViewModel vm) {
    // Tampilkan error
    if (vm.searchState == SearchState.error) {
      return _buildError(vm.errorMessage ?? 'Terjadi kesalahan');
    }

    // Tampilkan hasil pencarian
    if (vm.searchState == SearchState.loaded) {
      if (vm.searchResults.isEmpty) {
        return _buildEmpty();
      }
      return _buildSearchResults(context, vm.searchResults);
    }

    // Idle — tampilkan riwayat & favorit
    return _buildIdleContent(context, vm);
  }

  Widget _buildSearchResults(BuildContext context, List<LocationModel> results) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(color: Colors.white12, height: 1),
      itemBuilder: (context, i) {
        final loc = results[i];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: Colors.blue, size: 20),
          ),
          title: Text(loc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          subtitle: Text(
            [loc.admin1, loc.country].where((e) => e != null && e.isNotEmpty).join(', '),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          onTap: () => _selectLocation(context, loc),
        );
      },
    );
  }

  Widget _buildIdleContent(BuildContext context, SearchViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Riwayat Pencarian
        if (vm.searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Pencarian', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: vm.clearHistory,
                child: const Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...vm.searchHistory.map((query) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, color: Colors.white38, size: 18),
                title: Text(query, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                onTap: () {
                  setState(() {
                    _controller.text = query;
                  });
                  context.read<SearchViewModel>().search(query);
                },
                dense: true,
              )),
          const SizedBox(height: 16),
        ],

        if (vm.searchHistory.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Column(
              children: [
                Icon(Icons.search, size: 60, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'Ketik nama kota untuk mencari',
                  style: TextStyle(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFavoritesSection(
    BuildContext context,
    List<LocationModel> favorites,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13263A),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite, color: Colors.amber, size: 16),
                SizedBox(width: 6),
                Text(
                  'Lokasi Favorit',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: favorites.length,
                itemBuilder: (context, i) {
                  final loc = favorites[i];
                  final subtitle = [loc.admin1, loc.country]
                      .where((e) => e != null && e.isNotEmpty)
                      .join(', ');
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.amber, size: 14),
                    ),
                    title: Text(
                      loc.name,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    subtitle: subtitle.isNotEmpty
                        ? Text(
                            subtitle,
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          )
                        : null,
                    onTap: () => _selectLocation(context, loc, saveHistory: false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 60, color: Colors.white24),
          SizedBox(height: 16),
          Text('Kota tidak ditemukan', style: TextStyle(color: Colors.white54, fontSize: 16)),
          SizedBox(height: 8),
          Text('Coba nama kota yang berbeda', style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Gagal mencari lokasi', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
