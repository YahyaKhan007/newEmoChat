class Emotions {
  static List<String> emotions = [
    "assets/normalMode.png",
    "assets/funny.gif",
    "assets/sad.gif",
    "assets/sad.gif",
    "assets/angry.gif",
    "assets/sleepy.gif",
  ];

  static int findStringIndex(String searchString) {
    List<String> modesIndex = [
      'neutral',
      "happy",
      'sad',
    ];

    for (int i = 0; i < modesIndex.length; i++) {
      if (modesIndex[i] == searchString) {
        return i; // Return the index when the string is found.
      }
    }
    return -1; // Return -1 to indicate that the string was not found in the list.
  }
}
