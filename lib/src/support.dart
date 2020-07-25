<<<<<<< HEAD
typedef Useable<T> = T Function();

void using<T>(
  Useable<T> object, {
  void Function(T obj) perform,
}) =>
    perform(object);
=======
// This file contains support code used for bakecode exclusively

void using<T>(T object, {void Function(T obj) perform}) => perform(object);
>>>>>>> 62ff68b1a541ac77d43a810805d733b0d05a7ac4
