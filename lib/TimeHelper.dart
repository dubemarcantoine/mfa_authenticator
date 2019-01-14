class TimeHelper {
  static int getSecondsUntilNextRefresh() {
    final int seconds = DateTime.now().second;
    if (seconds <= 30) {
      return (seconds - 30).abs();
    } else {
      return (seconds - 60).abs();
    }
  }
}