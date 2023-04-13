import 'package:equatable/equatable.dart';

import 'message.dart';

class MessageItem extends Equatable {
  final Message? message;
  final String? messageDate;

  const MessageItem(this.message, this.messageDate);

  @override
  List<Object?> get props => [message, messageDate];
}
