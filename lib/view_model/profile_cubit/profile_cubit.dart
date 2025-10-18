import 'package:bloc/bloc.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(const ProfileState());

  /// ✅ تحميل بيانات الملف الشخصي
  Future<void> loadProfileData() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // جلب الإحصائيات
      final stats = await repository.getUserStats();

      // جلب إعلانات المستخدم
      final userAds = await repository.getUserAds();

      emit(state.copyWith(
        stats: stats,
        userAds: userAds,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// ✅ حذف إعلان
  Future<void> deleteAd(String adId) async {
    try {
      await repository.deleteAd(adId);

      // تحديث القائمة محلياً
      final updatedAds = state.userAds.where((ad) => ad.id != adId).toList();
      emit(state.copyWith(userAds: updatedAds));

      // إعادة تحميل الإحصائيات
      final stats = await repository.getUserStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// ✅ تحديث الملف الشخصي
  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await repository.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      // إعادة تحميل البيانات
      await loadProfileData();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}