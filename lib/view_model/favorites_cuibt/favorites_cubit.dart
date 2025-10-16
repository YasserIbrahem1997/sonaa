import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/repositories/favorites_repository.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  FavoritesCubit({required this.repository}) : super(FavoritesInitial());

  /// ✅ تحميل المفضلة
  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getUserFavorites();
      emit(FavoritesLoaded(favoriteIds: favorites));
    } catch (e) {
      emit(FavoritesError(error: e.toString()));
    }
  }

  /// ✅ إضافة/إزالة من المفضلة
  Future<void> toggleFavorite(String adId) async {
    try {
      final currentState = state;
      if (currentState is FavoritesLoaded) {
        final isCurrentlyFavorited = currentState.favoriteIds.contains(adId);

        if (isCurrentlyFavorited) {
          await repository.removeFromFavorites(adId);
          final updatedFavorites = List<String>.from(currentState.favoriteIds)..remove(adId);
          emit(FavoritesLoaded(favoriteIds: updatedFavorites));
        } else {
          await repository.addToFavorites(adId);
          final updatedFavorites = List<String>.from(currentState.favoriteIds)..add(adId);
          emit(FavoritesLoaded(favoriteIds: updatedFavorites));
        }
      }
    } catch (e) {
      emit(FavoritesError(error: e.toString()));
    }
  }

  /// ✅ التحقق إذا الإعلان في المفضلة
  bool isAdFavorited(String adId) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.favoriteIds.contains(adId);
    }
    return false;
  }
}