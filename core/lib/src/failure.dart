abstract class Failure {
  const Failure(this.message);
  final String message;
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class DataFailure extends Failure {
  const DataFailure(super.message);
}
