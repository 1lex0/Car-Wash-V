import 'car_wash.dart';
import 'result.dart';

abstract class CarWashRepository {
  Future<Result<List<CarWash>>> fetchAll();
  Future<Result<CarWash>> fetchById(int id);
  Future<Result<CarWash>> create(CarWash wash);
  Future<Result<CarWash>> update(CarWash wash);
  Future<Result<void>> delete(int id);
}
