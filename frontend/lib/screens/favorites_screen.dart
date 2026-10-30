import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/car_wash.dart';
import '../models/car_wash_catalog_model.dart';
import '../models/favorites_model.dart';
import '../widgets/car_wash_logo.dart';
import '../widgets/error_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CarWashCatalogModel>();
    final favorites = context.watch<FavoritesModel>();

    final Widget body;
    if (catalog.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (catalog.error != null) {
      body = ErrorView(
        message: catalog.error!,
        onRetry: () => context.read<CarWashCatalogModel>().load(),
      );
    } else {
      final washes = catalog.washes
          .where((w) => favorites.contains(w.id))
          .toList();
      body = _buildList(context, washes);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECE8DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECE8DF),
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3A33),
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildList(BuildContext context, List<CarWash> washes) {
    if (washes.isEmpty) {
      return const Center(
        child: Text(
          'No favorites yet.\nTap ♡ on a car wash to add it.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6F7D78)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: washes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final wash = washes[index];

        return Dismissible(
          key: ValueKey(wash.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.heart_broken_rounded, color: Colors.white),
          ),
          onDismissed: (_) => context.read<FavoritesModel>().remove(wash.id),
          child: _buildTile(context, wash),
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, CarWash wash) {
    return Material(
      color: const Color(0xFFF7F4EE),
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: SizedBox(
          width: 48,
          child: CarWashLogo(asset: wash.logoAsset, iconSize: 32),
        ),
        title: Text(
          wash.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3A33),
          ),
        ),
        subtitle: Text('${wash.area}, ${wash.city}'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('/search/${wash.id}'),
      ),
    );
  }
}
