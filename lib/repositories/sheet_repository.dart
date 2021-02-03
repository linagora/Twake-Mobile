enum SheetFlow {
  channel,
  direct,
  workspace,
}

class SheetRepository {
  final SheetFlow flow;
  SheetRepository({this.flow});

  static Future<SheetRepository> load() async {
    return SheetRepository(flow: SheetFlow.channel);
  }

  Future<void> cache() async {
  }

  Future<void> clear() async {
  }

  Future<void> process() async {
  }
}
