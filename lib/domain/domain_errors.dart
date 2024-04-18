import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_errors.freezed.dart';

abstract class DomainError {}

@freezed
class NotFoundError<T> with _$NotFoundError<T> implements DomainError {
  const factory NotFoundError({
    required Type type,
    @Default(null) String? reason,
  }) = _NotFoundError<T>;
}

@freezed
sealed class NetworkError with _$NetworkError implements DomainError {
  const factory NetworkError.badRequest({
    required int code,
    Uri? url,
    @Default(null) Exception? error,
  }) = NetworkErrorBadRequest;

  const factory NetworkError.serverError({
    required int code,
    Uri? url,
    @Default(null) Exception? error,
  }) = NetworkErrorServerError;

  const factory NetworkError.timeout({
    Uri? url,
  }) = NetworkErrorTimeout;

  const factory NetworkError.unknown({
    Uri? url,
    @Default(null) Exception? error,
  }) = NetworkErrorUnknown;
}
