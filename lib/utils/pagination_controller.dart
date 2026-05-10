class PaginationController<T> {
  final int pageSize;
  int _currentPage = 0;

  PaginationController({this.pageSize = 10});

  int get currentPage => _currentPage;

  /// Returns the current batch of items from the [allItems] list.
  List<T> getPaginatedItems(List<T> allItems) {
    if (allItems.isEmpty) return <T>[];
    final startIndex = _currentPage * pageSize;
    return allItems.skip(startIndex).take(pageSize).toList();
  }

  bool hasNextPage(int totalItems) {
    return (_currentPage + 1) * pageSize < totalItems;
  }

  bool hasPreviousPage() {
    return _currentPage > 0;
  }

  bool nextPage(int totalItems) {
    if (hasNextPage(totalItems)) {
      _currentPage++;
      return true;
    }
    return false;
  }

  bool previousPage() {
    if (hasPreviousPage()) {
      _currentPage--;
      return true;
    }
    return false;
  }

  void reset() {
    _currentPage = 0;
  }
}
