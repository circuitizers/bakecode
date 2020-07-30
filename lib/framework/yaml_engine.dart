import 'package:yaml/yaml.dart';

/*

apply plugin PLUGIN_NAME

[turn    on                dispenser    CHOCOLATE]
ACTION   ACTION_STATUS    OBJECT       OBJECT_ID
*/

class NoSuchStepDefined implements Exception {
  @override
  String toString() {
    return 'No such step defined';
  }
}

void foo() {
  print('hi');
}

class YamlParser {
  Map<String, void> actions = {
    'turn': foo,
    'stir': foo,
  };

  bool parser(String yaml) {
    Map getFromYaml = loadYaml(yaml);
    for (var index = 1; index < getFromYaml.length + 1; index++) {
      // not case sensitive
      List tokens = getFromYaml['step $index'].toLowerCase().split(' ');

      // token broken into instructions
      String action = tokens[0];
      String action_status = tokens[1];
      String object = tokens[2];
      // TODO: let users type name with spaces
      String object_id = tokens[3];

      print('$action, $action_status, $object, $object_id');
      try {
        (actions[action] as Function)();
      } on NoSuchMethodError {
        print('Exception occured at step $index,');
        print('\t$NoSuchStepDefined: ${NoSuchStepDefined()} as $action');
        print("\t>> step $index: ${tokens.join(' ')}");
      }
    }
    return true;
  }
}

void test_yaml() {
  var yaml = '''
  apply plugin zak_shake

  step 1: turn on dispenser chocoklajdskldadaklda
  step 2: turn2 on dispenser CHOCOLATE2
  step 3: shakeNstir cup
  ''';
  var y = YamlParser();
  y.parser(yaml);
}

void main() {
  test_yaml();
}
