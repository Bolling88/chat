import 'package:intl/intl.dart';

String getLastMessageTimeFromDateTime(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('dd MMM');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < secondsInDay) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

String getTimeSince(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < secondsInDay) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

Duration getDurationFromNow(DateTime dateTime) {
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  return now.difference(localDate);
}

String getFormattedDate(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('d MMM yyyy');
  final localDate = dateTime.toLocal();
  return dateFormat.format(localDate);
}

String getFormattedTime(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  return dateFormat.format(localDate);
}

String getMessageDate(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('EEEE dd MMM HH:mm');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < secondsInDay) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

const secondsInDay = 86400;
const secondsInHour = 3600;
