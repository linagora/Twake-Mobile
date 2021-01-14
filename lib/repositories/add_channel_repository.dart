enum FlowStage {
  info,
  groups,
  type,
  participants,
}

class AddChannelRepository {
  FlowStage flow;
  AddChannelRepository({this.flow});

  static Future<AddChannelRepository> load() async {
    return AddChannelRepository(flow: FlowStage.info);
  }

  // Future<AddChannelData> load() async {
  //
  // }

  void setStage(FlowStage flow) {
    this.flow = flow;
  }

  Future<void> cache() async {
  }

  Future<void> clear() async {
  }

  Future<void> process() async {
  }
}
