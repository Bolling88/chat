String getGenderImageUrl(int gender) {
  if (gender == 0) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/genders%2Fwoman.png?alt=media&token=e0400e5d-3735-453f-98fd-93cfbe6d163b';
  } else if (gender == 1) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/genders%2Fman.png?alt=media&token=79537759-e1dd-4883-8f4b-268d1c118d74';
  } else {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/genders%2Fnonbinary.png?alt=media&token=e573bbe2-a7ca-4518-8a3a-be1a2ba702fd';
  }
}
