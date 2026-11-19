// L5: CarWashCatalogModel — ломти, guard loadMore() и поиск, без сети.
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/car_wash.dart';
import 'package:frontend/data/car_wash_repository.dart';
import 'package:frontend/data/result.dart';
import 'package:frontend/models/car_wash_catalog_model.dart';

// 45 моек «на сервере»; запоминает, какие страницы у него просили.
class _PagedRepo implements CarWashRepository {
  final all = [
    for (var i = 1; i <= 45; i++)
      CarWash(
        id: i,
        name: i == 7 ? 'Ботаника' : 'Wash $i',
        area: 'A',
        city: 'C',
      ),
  ];
  final asked = <String>[];

  @override
  Future<Result<List<CarWash>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    asked.add('$page:${search ?? ''}');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final found = all.where((w) => w.name.contains(search ?? ''));
    return Ok(found.skip((page - 1) * limit).take(limit).toList());
  }

  @override
  Future<Result<CarWash>> fetchById(int id) => throw UnimplementedError();
  @override
  Future<Result<CarWash>> create(CarWash wash) async {
    final created = wash.copyWith(id: all.length + 1); // id даёт «сервер»
    all.add(created);
    return Ok(created);
  }

  @override
  Future<Result<CarWash>> update(CarWash wash) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(int id) => throw UnimplementedError();
}

void main() {
  test('страницы приклеиваются: 20 → 40 → 45, затем hasMore = false', () async {
    final model = CarWashCatalogModel(_PagedRepo());
    await model.load();
    expect(model.washes.length, 20);
    expect(model.hasMore, isTrue);

    await model.loadMore();
    expect(model.washes.length, 40);

    await model.loadMore();
    expect(model.washes.length, 45);
    expect(model.hasMore, isFalse); // неполная страница → больше нет
  });

  test(
    'guard: два loadMore() подряд просят страницу 2 только один раз',
    () async {
      final repo = _PagedRepo();
      final model = CarWashCatalogModel(repo);
      await model.load();

      await Future.wait([model.loadMore(), model.loadMore()]);
      expect(repo.asked, ['1:', '2:']); // без дублей
      expect(model.washes.map((w) => w.id).toSet().length, 40);
    },
  );

  test('loadMore() не извещает в начале (безопасно из itemBuilder)', () async {
    final model = CarWashCatalogModel(_PagedRepo());
    await model.load();
    var notified = 0;
    model.addListener(() => notified++);

    final pending = model.loadMore();
    expect(notified, 0); // синхронно — ни одного notifyListeners()
    await pending;
    expect(notified, 1); // один раз, когда страница приклеилась
  });

  test(
    'поиск уходит в repository, retry (load без search) его сохраняет',
    () async {
      final repo = _PagedRepo();
      final model = CarWashCatalogModel(repo);
      await model.load(search: 'Ботан');
      expect(model.washes.single.id, 7);

      await model.load(); // как кнопка Retry
      expect(repo.asked.last, '1:Ботан');
      expect(model.search, 'Ботан');
    },
  );

  test(
    'add() + loadMore(): новая запись не дублируется в следующей странице',
    () async {
      final repo = _PagedRepo();
      final model = CarWashCatalogModel(repo);
      await model.load(); // 20 из 45
      await model.add(
        const CarWash(id: 0, name: 'Sun Wash', area: 'A', city: 'C'),
      );
      await model.loadMore();
      await model.loadMore(); // страница 3 содержит id 46 — уже добавленную
      final ids = model.washes.map((w) => w.id).toList();
      expect(ids.length, ids.toSet().length);
      expect(ids.where((id) => id == 46).length, 1);
    },
  );
}
