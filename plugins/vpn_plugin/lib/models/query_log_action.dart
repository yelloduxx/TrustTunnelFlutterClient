enum QueryLogAction {
  bypass('bypass'),
  tunnel('tunnel'),
  reject('reject');

  final String value;

  const QueryLogAction(this.value);
}
