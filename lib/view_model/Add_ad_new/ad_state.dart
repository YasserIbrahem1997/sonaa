part of 'ad_cubit.dart';

sealed class AdState extends Equatable {
  const AdState();
}

final class AdInitial extends AdState {
  @override
  List<Object> get props => [];
}
