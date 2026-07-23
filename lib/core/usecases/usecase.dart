// Package imports:
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/errors/failures.dart';

// ── Base use case classes ────────────────────────────────────────────────────

abstract class UseCase<TResult, TParams> {
  Future<Either<Failure, TResult>> call(TParams params);
}

abstract class NoParamsUseCase<TResult> {
  Future<Either<Failure, TResult>> call();
}

abstract class StreamUseCase<TResult, TParams> {
  Stream<TResult> call(TParams params);
}

abstract class NoParamsStreamUseCase<TResult> {
  Stream<TResult> call();
}

// ── Parameters classes for use cases ─────────────────────────────────────────

abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}

class NoParams extends UseCaseParams {
  const NoParams();

  @override
  List<Object?> get props => [];
}

class SingleParam<T> extends UseCaseParams {
  const SingleParam(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

class DualParams<T1, T2> extends UseCaseParams {
  const DualParams(this.first, this.second);

  final T1 first;
  final T2 second;

  @override
  List<Object?> get props => [first, second];
}

class TripleParams<T1, T2, T3> extends UseCaseParams {
  const TripleParams(this.first, this.second, this.third);

  final T1 first;
  final T2 second;
  final T3 third;

  @override
  List<Object?> get props => [first, second, third];
}
