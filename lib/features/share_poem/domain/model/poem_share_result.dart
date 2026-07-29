/// Outcome of a poem share attempt.
///
/// Maps from platform-specific share results without exposing
/// the underlying platform types.
enum PoemShareResult {
  /// The share completed successfully.
  completed,

  /// The user dismissed the share sheet.
  dismissed,

  /// The platform could not determine the final user action.
  unavailable,
}
