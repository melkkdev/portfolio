// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Portfolio)
final portfolioProvider = PortfolioProvider._();

final class PortfolioProvider
    extends $AsyncNotifierProvider<Portfolio, PortfolioState> {
  PortfolioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioHash();

  @$internal
  @override
  Portfolio create() => Portfolio();
}

String _$portfolioHash() => r'19b9ea00f8e410cfd9ee9f16d36e0e37b503fa10';

abstract class _$Portfolio extends $AsyncNotifier<PortfolioState> {
  FutureOr<PortfolioState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PortfolioState>, PortfolioState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PortfolioState>, PortfolioState>,
              AsyncValue<PortfolioState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
