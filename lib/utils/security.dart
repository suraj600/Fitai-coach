/// Security utilities — input sanitization, prompt injection guard, rate limiter,
/// schema validation for LLM responses.
library;

import 'dart:convert';

// ─── Input Sanitizer ────────────────────────────────────────────────────────

class InputSanitizer {
  InputSanitizer._();

  /// Max lengths for user-supplied strings stored in Firestore.
  static const int maxNameLength = 100;
  static const int maxFoodNameLength = 200;
  static const int maxChatMessageLength = 2000;
  static const int maxInjuryLength = 200;
  static const int maxPortionLength = 100;

  /// Strip control characters and trim whitespace. Truncate to [maxLen].
  static String sanitize(String input, {int maxLen = 500}) {
    // Remove null bytes, control chars (except newline/tab for chat)
    final cleaned = input
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .trim();
    if (cleaned.length > maxLen) return cleaned.substring(0, maxLen);
    return cleaned;
  }

  /// Sanitize a name field — letters, spaces, hyphens, apostrophes only.
  static String sanitizeName(String input) {
    final cleaned = input
        .replaceAll(RegExp(r"[^\p{L}\p{M}\s\-']", unicode: true), '')
        .trim();
    if (cleaned.length > maxNameLength) {
      return cleaned.substring(0, maxNameLength);
    }
    return cleaned;
  }

  /// Sanitize numeric input — returns null if not a valid positive number.
  static double? sanitizePositiveNumber(String input, {double max = 999}) {
    final value = double.tryParse(input.trim());
    if (value == null || value <= 0 || value > max || value.isNaN || value.isInfinite) {
      return null;
    }
    return value;
  }

  /// Sanitize integer input.
  static int? sanitizePositiveInt(String input, {int max = 9999}) {
    final value = int.tryParse(input.trim());
    if (value == null || value <= 0 || value > max) return null;
    return value;
  }

  /// Validate email with proper regex (RFC 5322 simplified).
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    ).hasMatch(email);
  }
}

// ─── Prompt Injection Guard ─────────────────────────────────────────────────

class PromptGuard {
  PromptGuard._();

  /// Known prompt injection patterns to neutralize.
  static final List<RegExp> _injectionPatterns = [
    RegExp(r'ignore\s+(all\s+)?(previous|above|prior)\s+(instructions|prompts)', caseSensitive: false),
    RegExp(r'(system|hidden)\s*prompt', caseSensitive: false),
    RegExp(r'you\s+are\s+now\s+', caseSensitive: false),
    RegExp(r'new\s+instructions?\s*:', caseSensitive: false),
    RegExp(r'act\s+as\s+(if|though)?\s*you', caseSensitive: false),
    RegExp(r'forget\s+(everything|all|your)', caseSensitive: false),
    RegExp(r'override\s+(your|the|all)', caseSensitive: false),
    RegExp(r'(reveal|show|display|output|print)\s+(the\s+)?(system|hidden|secret)', caseSensitive: false),
    RegExp(r'```\s*(system|instruction|prompt)', caseSensitive: false),
    RegExp(r'\[INST\]|\[/INST\]|<\|im_start\|>|<\|im_end\|>', caseSensitive: false),
  ];

  /// Sanitize user text before injecting into an LLM prompt.
  /// Wraps the input in clear delimiters and neutralizes known injection patterns.
  static String sanitizeForPrompt(String userInput, {int maxLen = 1000}) {
    var sanitized = InputSanitizer.sanitize(userInput, maxLen: maxLen);

    // Replace injection patterns with [FILTERED]
    for (final pattern in _injectionPatterns) {
      sanitized = sanitized.replaceAll(pattern, '[FILTERED]');
    }

    return sanitized;
  }

  /// Wrap user-supplied data in a clearly delimited block so the LLM
  /// can distinguish it from instructions.
  static String wrapUserData(String label, String value) {
    final sanitized = sanitizeForPrompt(value);
    return '[$label]: $sanitized';
  }
}

// ─── LLM Response Validator ─────────────────────────────────────────────────

class LlmResponseValidator {
  LlmResponseValidator._();

  /// Parse and validate a calorie estimation response from LLM.
  /// Returns null if the response is invalid.
  static Map<String, dynamic>? validateCalorieEstimate(String rawText) {
    try {
      // Extract JSON from potential markdown wrapping
      final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(rawText);
      if (jsonMatch == null) return null;

      final data = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      // Validate required fields exist and are within sane ranges
      final foodName = data['foodName'];
      if (foodName is! String || foodName.isEmpty || foodName.length > 200) {
        return null;
      }

      final calories = _toNum(data['calories']);
      if (calories == null || calories < 0 || calories > 10000) return null;

      final protein = _toDouble(data['proteinG']);
      final carbs = _toDouble(data['carbsG']);
      final fat = _toDouble(data['fatG']);
      final confidence = _toDouble(data['confidenceScore']);

      // Clamp values to sane ranges
      return {
        'foodName': InputSanitizer.sanitize(foodName, maxLen: 200),
        'calories': calories.clamp(0, 10000),
        'proteinG': (protein ?? 0).clamp(0, 500).toDouble(),
        'carbsG': (carbs ?? 0).clamp(0, 1000).toDouble(),
        'fatG': (fat ?? 0).clamp(0, 500).toDouble(),
        'portionSize': InputSanitizer.sanitize(
            (data['portionSize'] as String?) ?? '1 serving',
            maxLen: 100),
        'confidenceScore': (confidence ?? 0.5).clamp(0, 1).toDouble(),
      };
    } catch (_) {
      return null;
    }
  }

  static num? _toNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

// ─── Rate Limiter ───────────────────────────────────────────────────────────

class RateLimiter {
  final Duration window;
  final int maxCalls;
  final List<DateTime> _timestamps = [];

  RateLimiter({required this.window, required this.maxCalls});

  /// Returns true if the call is allowed, false if rate limited.
  bool tryCall() {
    final now = DateTime.now();
    // Remove expired timestamps
    _timestamps.removeWhere((t) => now.difference(t) > window);

    if (_timestamps.length >= maxCalls) return false;

    _timestamps.add(now);
    return true;
  }

  /// Seconds until next call is allowed. 0 if allowed now.
  int get cooldownSeconds {
    if (_timestamps.length < maxCalls) return 0;
    final oldest = _timestamps.first;
    final remaining = window - DateTime.now().difference(oldest);
    return remaining.inSeconds.clamp(0, window.inSeconds);
  }
}
