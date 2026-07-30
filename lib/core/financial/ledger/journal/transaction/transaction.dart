abstract interface class Transaction {
  Future<T> execute<T>(Future<T> Function() action);
}
