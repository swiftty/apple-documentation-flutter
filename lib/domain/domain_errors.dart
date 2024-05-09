import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_errors.freezed.dart';

abstract class DomainException implements Exception {}

@freezed
class NotFoundException<T> with _$NotFoundException<T> implements DomainException {
  const factory NotFoundException({
    required Type type,
    @Default(null) String? reason,
  }) = _NotFoundException<T>;
}

@freezed
class UnexpectedError<T> with _$UnexpectedError<T> implements DomainException {
  const factory UnexpectedError({
    @Default(null) String? reason,
    @Default(null) Exception? error,
  }) = _UnexpectedError<T>;
}

@freezed
sealed class NetworkException with _$NetworkException implements DomainException {
  const factory NetworkException.badRequest({
    required int code,
    Uri? url,
    @Default(null) Exception? error,
  }) = NetworkExceptionBadRequest;

  const factory NetworkException.serverError({
    required int code,
    Uri? url,
    @Default(null) Exception? error,
  }) = NetworkExceptionServerError;

  const factory NetworkException.timeout({
    Uri? url,
  }) = NetworkExceptionTimeout;
}
