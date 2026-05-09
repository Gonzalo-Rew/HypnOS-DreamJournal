/// String extensions
extension StringExtensions on String {
  /// Check if string is a valid email
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Check if string is empty or whitespace only
  bool get isBlank => trim().isEmpty;

  /// Check if string is NOT empty or whitespace only
  bool get isNotBlank => !isBlank;
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as human readable date (e.g., "Today", "Yesterday", "2 days ago")
  String toRelativeString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisDay = DateTime(year, month, day);

    if (thisDay == today) {
      return 'Today';
    } else if (thisDay == yesterday) {
      return 'Yesterday';
    } else {
      final difference = today.difference(thisDay).inDays;
      if (difference > 0 && difference < 7) {
        return '$difference days ago';
      } else {
        return 'MMM d, yyyy';
      }
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Safely get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Safely get last element or null
  T? get lastOrNull => isEmpty ? null : last;
}

/// Map extensions
extension MapExtensions<K, V> on Map<K, V> {
  /// Get value or default if key not present
  V? getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }
}
