typedef PetrelRegisterActionFunction<T> = Future<T> Function(
    [dynamic arguments]);

class PetrelRegisterAction<T> {
  final String methodName;
  final PetrelRegisterActionFunction<T> action;

  PetrelRegisterAction({
    required this.methodName,
    required this.action,
  });
}
