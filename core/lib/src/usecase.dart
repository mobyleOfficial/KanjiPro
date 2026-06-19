abstract class UseCase<Params, Output> {
  Future<Output> call([Params params]);
}
