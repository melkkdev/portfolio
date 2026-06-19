// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
