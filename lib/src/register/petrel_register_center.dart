import 'package:petrel/src/register/petrel_register.dart';
import 'package:petrel/src/register/petrel_register_action.dart';

final List<PetrelRegister> _registerList = [];

class PetrelRegisterCenter {
  static void register(PetrelRegister register, {bool replace = false}) {
    final isRegisterExit = _registerList
        .any((element) => element.registerName == register.registerName);
    if (isRegisterExit && !replace) {
      throw Exception(
        'libraryName: ${register.libraryName} registerName: ${register.registerName} is already registered',
      );
    }
    _registerList.add(register);
  }

  static Future<T> call<T>({
    required String libraryName,
    required String registerName,
    required String methodName,
    dynamic arguments,
  }) async {
    final register = _registerList
        .where((element) =>
            element.registerName == registerName &&
            element.libraryName == libraryName)
        .firstOrNull;
    if (register == null) {
      throw Exception(
          'libraryName: $libraryName registerName: $registerName register not found');
    }
    final action =
        register.actions.where((e) => e.methodName == methodName).firstOrNull;
    if (action == null) {
      throw Exception(
          'methodName: $methodName not implemented in ${register.runtimeType}');
    }
    if (action is! PetrelRegisterAction<T>) {
      throw Exception(
          'return not ${T.runtimeType} type in ${register.runtimeType}');
    }
    return action.action(arguments);
  }

  static T where<T extends PetrelRegister>() {
    final register = _registerList.whereType<T>().firstOrNull;
    if (register == null) {
      throw Exception('register not found in ${T.toString()}');
    }
    return register;
  }
}
