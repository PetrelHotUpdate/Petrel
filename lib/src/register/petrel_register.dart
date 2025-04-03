import 'package:petrel/src/register/petrel_register_action.dart';

abstract class PetrelRegister {
  String get libraryName;
  String get registerName;
  final List<PetrelRegisterAction> actions = [];

  void addAction(PetrelRegisterAction action) {
    actions.add(action);
  }

  void addActions(List<PetrelRegisterAction> actions) {
    this.actions.addAll(actions);
  }
}
