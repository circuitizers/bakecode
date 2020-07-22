// This file contains support code used for bakecode exclusively

void using<T>(T object, {void Function(T obj) perform}) => perform(object);
