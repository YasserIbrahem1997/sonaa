part of 'favorites_cubit.dart';

@immutable
abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<String> favoriteIds;

  FavoritesLoaded({required this.favoriteIds});
}

class FavoritesError extends FavoritesState {
  final String error;

  FavoritesError({required this.error});
}