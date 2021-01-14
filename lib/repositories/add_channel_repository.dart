enum FlowStage {
  info,
  groups,
  type,
  participants,
}

enum ChannelType {
  public,
  private,
  direct,
}

class AddChannelRepository {
  FlowStage flow;
  ChannelType type;

  AddChannelRepository({this.flow, this.type});

  static Future<AddChannelRepository> load() async {
    return AddChannelRepository(
      flow: FlowStage.info,
      type: ChannelType.public,
    );
  }

  // Future<AddChannelData> load() async {
  //
  // }

  void setStage(FlowStage flow) {
    this.flow = flow;
  }

  Future<void> cache() async {}

  Future<void> clear() async {}

  Future<void> process() async {}
}
