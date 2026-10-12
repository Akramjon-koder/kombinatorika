/// Centralized route paths — use these constants instead of hardcoded URL
/// strings so locations stay consistent across the router and navigation calls.
abstract final class Routes {
  /// Welcome: role picker (learner / teacher).
  static const String welcome = '/';

  /// City map with all problem islands (learner only).
  static const String city = '/city';

  /// One problem by id: `/problem/3`.
  static const String problem = '/problem/:id';

  /// Teacher dashboard: results + answer key.
  static const String teacher = '/teacher';

  /// Location of problem [id].
  static String problemOf(int id) => '/problem/$id';
}
