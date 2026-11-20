import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/car_wash.dart';
import '../models/car_wash_catalog_model.dart';
import '../widgets/car_wash_card.dart';
import '../widgets/error_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _searchController = TextEditingController(
    text: context.read<CarWashCatalogModel>().search,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CarWashCatalogModel>();

    final Widget body;
    if (catalog.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (catalog.error != null) {
      body = ErrorView(
        message: catalog.error!,
        onRetry: () => context.read<CarWashCatalogModel>().load(),
      );
    } else {
      body = _buildGrid(catalog.washes, catalog.hasMore);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECE8DF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Find a car wash',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F3A33),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    tooltip: 'Add car wash',
                    onPressed: () => context.push('/search/new'),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3A33),
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (q) =>
                    context.read<CarWashCatalogModel>().load(search: q.trim()),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF7F4EE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<CarWash> washes, bool hasMore) {
    if (washes.isEmpty) {
      return const Center(child: Text('No car washes found'));
    }

    return GridView.builder(
      itemCount: washes.length + (hasMore ? 1 : 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        if (index == washes.length) {
          context.read<CarWashCatalogModel>().loadMore();
          return const Center(child: CircularProgressIndicator());
        }
        final wash = washes[index];

        return CarWashCard(
          key: ValueKey(wash.id),
          wash: wash,
          onTap: () {
            context.push('/search/${wash.id}');
          },
        );
      },
    );
  }
}
