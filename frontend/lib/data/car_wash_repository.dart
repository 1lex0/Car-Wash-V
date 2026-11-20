import 'car_wash.dart';
import 'result.dart';

abstract class CarWashRepository {
  Future<Result<List<CarWash>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<Result<CarWash>> fetchById(int id);
  Future<Result<CarWash>> create(CarWash wash);
  Future<Result<CarWash>> update(CarWash wash);
  Future<Result<void>> delete(int id);
}
