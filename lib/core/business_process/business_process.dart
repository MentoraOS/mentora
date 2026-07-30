abstract class BusinessProcess<T> {
  const BusinessProcess();

  String get name;

  Future<T> run();
}
