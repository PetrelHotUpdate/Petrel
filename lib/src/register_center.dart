import 'package:petrel/petrel.dart';

class RegisterCenter {
  final List<PetrelRegister> _registers = [];
  List<PetrelRegister> get registers => _registers;
  RegisterCenter();

  void addRegister<T extends PetrelRegister>(T register) {
    logger.d('正在添加注册器: ${T.toString()}');
    _registers.add(register);
  }

  void removeRegister<T extends PetrelRegister>(T register) {
    logger.d('正在移除注册器: ${T.toString()}');
    _registers.remove(register);
  }
}
