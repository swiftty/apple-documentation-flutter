import 'dart:io';

Future<String> fixture(String name) async {
  final dir = Directory.current.path;
  return File('$dir/test/fixtures/$name').readAsString();
}
