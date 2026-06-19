// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// admin 배너에만 노출되는 앱 버전 표시 (pubspec.yaml의 version 값을 런타임에 읽음)

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// admin 배너에만 노출되는 앱 버전 표시 (pubspec.yaml의 version 값을 런타임에 읽음)

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// admin 배너에만 노출되는 앱 버전 표시 (pubspec.yaml의 version 값을 런타임에 읽음)
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'e818a922f231ed565e1d815b276c36790b78ac30';

@ProviderFor(Admin)
final adminProvider = AdminProvider._();

final class AdminProvider extends $NotifierProvider<Admin, AdminUiState> {
  AdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminHash();

  @$internal
  @override
  Admin create() => Admin();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminUiState>(value),
    );
  }
}

String _$adminHash() => r'eb1be113c49e21f5476545cfc48e39b725629d0b';

abstract class _$Admin extends $Notifier<AdminUiState> {
  AdminUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdminUiState, AdminUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminUiState, AdminUiState>,
              AdminUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
