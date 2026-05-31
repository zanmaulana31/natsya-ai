class CompletionResult {
  final String response;

  const CompletionResult({required this.response});
}

class StreamedCompletionResult {
  final Stream<String> stream;

  const StreamedCompletionResult({required this.stream});
}
