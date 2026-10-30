import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/data/car_wash.dart';
import 'package:frontend/data/mock_car_wash_repository.dart';
import 'package:frontend/data/result.dart';
import 'package:frontend/features/iwash/repositories/mock_iwash_repository.dart';
import 'package:frontend/models/car_wash_catalog_model.dart';
import 'package:frontend/models/favorites_model.dart';
import 'package:frontend/models/iwash_live_model.dart';

const _draft = CarWash(
  id: 0,
  name: 'Aqua Wash',
  area: 'Ciocana',
  city: 'Chișinău',
);

void main() {
  group('FavoritesModel', () {
    test('toggle и remove вызывают notifyListeners', () {
      final model = FavoritesModel();
      var notified = 0;
      model.addListener(() => notified++);

      model.add(3);
      model.toggle(1);
      model.toggle(1);
      model.remove(3);

      expect(notified, 4);
      expect(model.count, 0);
    });

    test('ids нельзя менять снаружи', () {
      final model = FavoritesModel()..add(1);
      expect(() => model.ids.add(2), throwsUnsupportedError);
      expect(model.count, 1);
    });
  });

  group('MockCarWashRepository', () {
    test('fetchAll возвращает копию списка', () async {
      final repo = MockCarWashRepository();
      final result = await repo.fetchAll();

      expect(result, isA<Ok<List<CarWash>>>());
      final list = (result as Ok<List<CarWash>>).value;
      expect(list.map((w) => w.name), ['Lux Wash', 'E-Wash', 'I-Wash']);

      list.clear();
      final again = await repo.fetchAll() as Ok<List<CarWash>>;
      expect(again.value.length, 3);
    });

    test('есть задержка как у сети', () async {
      final watch = Stopwatch()..start();
      await MockCarWashRepository().fetchAll();
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(750));
    });

    test('create дает id начиная с 1000', () async {
      final repo = MockCarWashRepository();
      final created = await repo.create(_draft) as Ok<CarWash>;
      expect(created.value.id, 1000);
      expect(created.value.name, 'Aqua Wash');
    });

    test('несуществующий id возвращает Err', () async {
      final repo = MockCarWashRepository();
      expect(await repo.fetchById(999), isA<Err<CarWash>>());
      expect(await repo.delete(999), isA<Err<void>>());
    });

    test('simulateError ломает все методы', () async {
      final repo = MockCarWashRepository()..simulateError = true;
      final result = await repo.fetchAll();
      expect(result, isA<Err<List<CarWash>>>());
      expect((result as Err).msg, contains('Server is not responding'));
    });
  });

  group('CarWashCatalogModel', () {
    test('load загружает данные', () async {
      final model = CarWashCatalogModel(MockCarWashRepository());
      final states = <bool>[];
      model.addListener(() => states.add(model.isLoading));

      await model.load();

      expect(states, [true, false]);
      expect(model.washes.length, 3);
      expect(model.error, isNull);
      expect(model.byId(3)?.name, 'I-Wash');
      expect(model.byId(42), isNull);
    });

    test('load с ошибкой', () async {
      final model = CarWashCatalogModel(
        MockCarWashRepository()..simulateError = true,
      );
      await model.load();
      expect(model.error, isNotNull);
      expect(model.washes, isEmpty);
    });

    test('add и remove', () async {
      final repo = MockCarWashRepository();
      final model = CarWashCatalogModel(repo);
      await model.load();

      expect(await model.add(_draft), isNull);
      expect(model.washes.length, 4);
      expect(model.byId(1000)?.name, 'Aqua Wash');

      expect(await model.remove(1000), isNull);
      expect(model.byId(1000), isNull);
      expect((await repo.fetchAll() as Ok<List<CarWash>>).value.length, 3);
    });

    test('add при ошибке не меняет список', () async {
      final repo = MockCarWashRepository();
      final model = CarWashCatalogModel(repo);
      await model.load();

      repo.simulateError = true;
      expect(await model.add(_draft), isNotNull);
      expect(await model.remove(1), isNotNull);
      expect(model.washes.length, 3);
    });

    test('update меняет мойку по id', () async {
      final model = CarWashCatalogModel(MockCarWashRepository());
      await model.load();

      const renamed = CarWash(
        id: 2,
        name: 'E-Wash 24/7',
        area: 'Rîșcani',
        city: 'Chișinău',
      );
      expect(await model.update(renamed), isNull);
      expect(model.byId(2)?.name, 'E-Wash 24/7');
    });

    test('washes нельзя менять снаружи', () async {
      final model = CarWashCatalogModel(MockCarWashRepository());
      await model.load();
      expect(() => model.washes.add(_draft), throwsUnsupportedError);
    });
  });

  group('IWashLiveModel', () {
    test('load(3) загружает боксы', () async {
      final model = IWashLiveModel(MockIWashRepository());
      await model.load(3);
      expect(model.state?.bays.length, 11);
      expect(model.state?.waitingCarsCount, 5);
      expect(model.error, isNull);
    });

    test('ошибка сервера', () async {
      final model = IWashLiveModel(MockIWashRepository()..simulateError = true);
      await model.load(3);
      expect(model.error, isNotNull);
    });
  });
}
