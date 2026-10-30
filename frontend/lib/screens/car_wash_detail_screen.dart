import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/car_wash.dart';
import '../models/car_wash_catalog_model.dart';
import '../models/favorites_model.dart';
import '../widgets/delete_car_wash_dialog.dart';
import '../widgets/car_wash_logo.dart';
import '../widgets/error_view.dart';

class CarWashDetailScreen extends StatelessWidget {
  final int id;

  const CarWashDetailScreen({super.key, required this.id});

  Future<void> _delete(BuildContext context, CarWash wash) async {
    final ok = await showDeleteCarWashDialog(context, wash.name);
    if (!ok || !context.mounted) return;

    final error = await context.read<CarWashCatalogModel>().remove(wash.id);
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.read<FavoritesModel>().remove(wash.id);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CarWashCatalogModel>();
    final wash = catalog.byId(id);

    if (wash == null) {
      final Widget body;
      if (catalog.isLoading) {
        body = const Center(child: CircularProgressIndicator());
      } else if (catalog.error != null) {
        body = ErrorView(
          message: catalog.error!,
          onRetry: () => context.read<CarWashCatalogModel>().load(),
        );
      } else {
        body = const Center(child: Text('Car wash does not exist'));
      }

      return Scaffold(
        backgroundColor: const Color(0xFFECE8DF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFECE8DF),
          title: const Text('Car wash'),
        ),
        body: body,
      );
    }

    final isFavorite = context.watch<FavoritesModel>().contains(wash.id);

    return Scaffold(
      backgroundColor: const Color(0xFFECE8DF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECE8DF),
        elevation: 0,
        title: Text(
          wash.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3A33),
          ),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () => context.read<FavoritesModel>().toggle(wash.id),
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: const Color(0xFF1F3A33),
            ),
          ),
          IconButton(
            tooltip: 'Delete car wash',
            onPressed: () => _delete(context, wash),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFF1F3A33),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 210,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EE),
                borderRadius: BorderRadius.circular(30),
              ),
              child: CarWashLogo(asset: wash.logoAsset, iconSize: 96),
            ),
            const SizedBox(height: 28),
            Text(
              wash.name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F3A33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${wash.area}, ${wash.city}',
              style: const TextStyle(fontSize: 17, color: Color(0xFF6F7D78)),
            ),
            const Spacer(),

            if (wash.id == 3)
              FilledButton.icon(
                onPressed: () {
                  context.push('/search/${wash.id}/map');
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open live map'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFF1F3A33),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
