enum Gender {
  female(0),
  male(1),
  nonBinary(2),
  secret(3);

  const Gender(this.value);

  static Gender fromValue(num i) {
    if (i < 0 || i > 3) {
      i = 3;
    }
    return Gender.values.firstWhere((x) => x.value == i);
  }

  static List<Gender> getAsList() {
    return Gender.values;
  }

  final int value;
}

const onlineDuration = Duration(hours: 3);

enum ApprovedImage {
  notReviewed(0),
  notApproved(1),
  approved(2),
  notSet(3);

  const ApprovedImage(this.value);

  static ApprovedImage fromValue(num i) {
    if (i < 0 || i > 3) {
      i = 0;
    }
    return ApprovedImage.values.firstWhere((x) => x.value == i);
  }

  static List<ApprovedImage> getAsList() {
    return ApprovedImage.values;
  }

  final int value;
}

enum ChatType {
  message(0),
  joined(1),
  left(2),
  giphy(3),
  date(4),
  image(5);

  const ChatType(this.value);

  final num value;
}
