import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'ad_state.dart';

class AdCubit extends Cubit<AdState> {
  AdCubit() : super(AdInitial());
}
