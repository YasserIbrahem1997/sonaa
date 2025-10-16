import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/model/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  StreamSubscription? _messagesSubscription;
  String? _currentChatId;
  bool _isInitialized = false;

  ChatCubit({required this.repository}) : super(const ChatState());

  /// ✅ تهيئة Chat مع Real-time streaming
  Future<void> initializeChat({
    required String adId,
    required String sellerId,
  }) async {
    if (_isInitialized) return; // منع التهيئة المزدوجة

    emit(state.copyWith(isLoading: true, error: null));

    try {
      print('🚀 Initializing chat for ad: $adId');

      // إنشاء أو جلب Chat
      final chat = await repository.getOrCreateChat(
        adId: adId,
        sellerId: sellerId,
      );

      _currentChatId = chat.id;
      _isInitialized = true;


      // جلب الرسائل الحالية أولاً
      final initialMessages = await repository.getMessages(chat.id);

      emit(state.copyWith(
        chat: chat,
        messages: initialMessages,
        isLoading: false,
      ));

      // بدء الـ Real-time streaming
      _startListeningToMessages(chat.id);

      // تحديد الرسائل كـ مقروءة
      await repository.markMessagesAsRead(chat.id);

    } catch (e) {
      print('❌ Error initializing chat: $e');
      emit(state.copyWith(
          isLoading: false,
          error: e.toString()
      ));
    }
  }

  /// ✅ بدء الاستماع للرسائل Real-time - الإصدار المحسن
  void _startListeningToMessages(String chatId) {
    _messagesSubscription?.cancel();

    _messagesSubscription = repository.streamMessages(chatId).listen(
          (messages) {

        // تحديث الرسائل مع الحفاظ على الترتيب
        final sortedMessages = List<MessageModel>.from(messages)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        emit(state.copyWith(messages: sortedMessages));
      },
      onError: (error) {
        print('❌ Stream error: $error');
        emit(state.copyWith(error: error.toString()));
      },
      cancelOnError: false,
    );

    print('🎧 Started listening to messages for chat: $chatId');
  }

  /// ✅ إرسال رسالة مع تحديث فوري
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.chat == null) return;

    final trimmedText = text.trim();

    emit(state.copyWith(isSending: true));

    try {
      // إضافة الرسالة محلياً فوراً (Optimistic Update)
      final tempMessage = MessageModel(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        chatId: state.chat!.id,
        senderId: _getCurrentUserId(),
        text: trimmedText,
        isRead: false,
        createdAt: DateTime.now(),
      );

      final updatedMessages = List<MessageModel>.from(state.messages)..add(tempMessage);
      emit(state.copyWith(
        messages: updatedMessages,
        isSending: true, // استمرار حالة الإرسال
      ));

      // إرسال الرسالة فعلياً
      await repository.sendMessage(
        chatId: state.chat!.id,
        text: trimmedText,
      );

      emit(state.copyWith(isSending: false));

    } catch (e) {
      print('❌ Error sending message: $e');

      // إزالة الرسالة المؤقتة في حالة الخطأ
      final filteredMessages = state.messages.where((m) => !m.id.startsWith('temp-')).toList();

      emit(state.copyWith(
        messages: filteredMessages,
        isSending: false,
        error: e.toString(),
      ));
    }
  }

  /// ✅ إرسال صورة
  Future<void> sendImage(String imageUrl) async {
    if (state.chat == null) return;

    emit(state.copyWith(isSending: true));

    try {
      await repository.sendMessage(
        chatId: state.chat!.id,
        text: '📷 Image',
        imageUrl: imageUrl,
      );

      emit(state.copyWith(isSending: false));
    } catch (e) {
      emit(state.copyWith(
          isSending: false,
          error: e.toString()
      ));
    }
  }

  /// ✅ تحديث حالة القراءة
  Future<void> markAsRead() async {
    if (_currentChatId != null) {
      await repository.markMessagesAsRead(_currentChatId!);
    }
  }

  /// ✅ إعادة تحميل الرسائل
  Future<void> refreshMessages() async {
    if (_currentChatId == null) return;

    try {
      final messages = await repository.getMessages(_currentChatId!);
      emit(state.copyWith(messages: messages));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// ✅ الحصول على ID المستخدم الحالي
  String _getCurrentUserId() {
    return repository.getCurrentUserId(); // سنضيف هذه الدالة في الـ Repository
  }

  @override
  Future<void> close() {
    print('🔚 Closing chat cubit');
    _messagesSubscription?.cancel();
    _isInitialized = false;
    return super.close();
  }
}