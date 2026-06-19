enum JlptLevel {
  n5,
  n4,
  n3,
  n2,
  n1;

  String get id => name;

  static JlptLevel fromId(String value) =>
      JlptLevel.values.firstWhere((level) => level.name == value);
}
