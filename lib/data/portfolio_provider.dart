import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'portfolio_state.dart';

part 'portfolio_provider.g.dart';

@Riverpod(keepAlive: true)
class Portfolio extends _$Portfolio {
  @override
  Future<PortfolioState> build() => PortfolioState.load();

  /// 새 데이터가 준비될 때까지 기존 데이터를 유지한 채 갱신한다 (화면 깜빡임 없음).
  Future<void> reload() async {
    state = await AsyncValue.guard(() => PortfolioState.load());
  }
}
