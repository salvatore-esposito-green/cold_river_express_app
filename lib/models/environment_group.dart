import 'package:cold_river_express_app/models/box_summary.dart';

class EnvironmentGroup {
  final String environment;
  final List<BoxSummary> summary;
  final List<String> numbers;

  EnvironmentGroup({
    required this.environment,
    required this.summary,
    required this.numbers,
  });
}
