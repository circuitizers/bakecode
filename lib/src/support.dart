typedef Useable<T> = T Function();

void using<T>(
  Useable<T> object, {
  void Function(T obj) perform,
}) =>
    perform(object);
