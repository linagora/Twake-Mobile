enum SheetFlow {
  addChannel,
  editChannel,
  direct,
  workspace,
  profile,
}

class SheetRepository {
  final SheetFlow flow;
  SheetRepository({this.flow});

  static Future<SheetRepository> load() async {
    return SheetRepository(flow: SheetFlow.addChannel);
  }

  Future<void> cache() async {
  }

  Future<void> clear() async {
  }

  Future<void> process() async {
  }
}
