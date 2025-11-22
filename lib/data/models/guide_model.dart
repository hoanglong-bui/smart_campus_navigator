class GuideModel {
  final String guideId;
  final String title; // Đã chọn theo ngôn ngữ
  final String? description; // Đã chọn theo ngôn ngữ
  final String targetUser;
  final List<GuideStep> steps;

  GuideModel({
    required this.guideId,
    required this.title,
    this.description,
    required this.targetUser,
    required this.steps,
  });
}

class GuideStep {
  final int stepId;
  final int stepOrder;
  final String title; // Đã chọn theo ngôn ngữ
  final String? description; // Đã chọn theo ngôn ngữ
  final int? linkedServiceId;

  GuideStep({
    required this.stepId,
    required this.stepOrder,
    required this.title,
    this.description,
    this.linkedServiceId,
  });
}
