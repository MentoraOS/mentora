abstract class BaseRepository<T> {
  const BaseRepository();

  List<T> findAll();

  T? findById(String id);
}
