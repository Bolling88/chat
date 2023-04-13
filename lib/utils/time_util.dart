import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String getLastMessageTimeFromTimeStamp(Timestamp timeStamp) {
  final DateFormat dateFormat = DateFormat('dd MMM');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = timeStamp.toDate().toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < SECONDS_IN_DAY) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

String getTimeSince(Timestamp timeStamp) {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = timeStamp.toDate().toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < SECONDS_IN_DAY) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

Duration getDurationFromNow(Timestamp timeStamp) {
  final localDate = timeStamp.toDate().toLocal();
  final now = DateTime.now();
  return now.difference(localDate);
}

String getFormattedDate(Timestamp timeStamp) {
  final DateFormat dateFormat = DateFormat('d MMM yyyy');
  final localDate = timeStamp.toDate().toLocal();
  return dateFormat.format(localDate);
}

String getFormattedTime(Timestamp timeStamp) {
  final DateFormat dateFormat = DateFormat('HH:mm');
  final localDate = timeStamp.toDate().toLocal();
  return dateFormat.format(localDate);
}

String getMessageDate(Timestamp timeStamp) {
  final DateFormat dateFormat = DateFormat('EEEE dd MMM HH:mm');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = timeStamp.toDate().toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < SECONDS_IN_DAY) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

const SECONDS_IN_DAY = 86400;
const SECONDS_IN_HOUR = 3600;
