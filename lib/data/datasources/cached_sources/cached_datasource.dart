abstract class BaseCachedDatasource {
  Future<void> clear();
}

abstract class CachedDataSource<T> extends BaseCachedDatasource {
  Future<List<T>> getAll();

  Future<T?> getById({required covariant Object id});

  Future<void> save({required T entity});

  Future<void> update({required T entity});

  Future<void> delete({required covariant Object id});
}
