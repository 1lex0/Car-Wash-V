import '../../../data/result.dart';
import '../models/wash_live_state.dart';

abstract class IWashRepository {
  Future<Result<WashLiveState>> fetchLiveState(int washId);
}
