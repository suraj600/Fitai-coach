# Security Configuration Guide — FitAI Coach

## Build-time API Key

**Never hardcode API keys in source code.** The Gemini API key is loaded
via Dart's `--dart-define` at build time:

```bash
# Development
flutter run --dart-define=GEMINI_API_KEY=your_key_here

# Release build
flutter build apk --dart-define=GEMINI_API_KEY=your_key_here --obfuscate --split-debug-info=build/debug-info
```

If no key is provided, the app falls back to mock/demo responses.

## Firestore Security Rules

Deploy `firestore.rules` before going to production:

```bash
firebase deploy --only firestore:rules
```

Rules enforce:
- Users can only read/write their own data (`request.auth.uid == userId`)
- Profile fields are type-checked and range-validated
- Workout logs and meal logs are immutable (no client-side edits)
- Chat messages are append-only with a 2000-char limit
- Water count is capped at 0–50

## Certificate Pinning (Production)

Add `http_certificate_pinning` or `ssl_pinning_plugin` to `pubspec.yaml`
for production. Pin SHA-256 hashes of the Gemini API and Firebase certs:

```yaml
dependencies:
  http_certificate_pinning: ^2.0.0
```

Then in `ai_service.dart`, replace `http.post()` with the pinned client.

## Code Obfuscation (Release Builds)

Always build release APKs with obfuscation:

```bash
flutter build apk --obfuscate --split-debug-info=build/debug-info
```

Add `android-proguard-rules.pro` contents to `android/app/proguard-rules.pro`
and reference it in `build.gradle`:

```groovy
buildTypes {
    release {
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## Security Controls Summary

| # | Threat | Mitigation | File |
|---|--------|------------|------|
| 1 | API key in source | `--dart-define` env var | `constants.dart` |
| 2 | No Firestore rules | Rules file with uid checks | `firestore.rules` |
| 3 | UID tampering | `_assertAuthorized()` on all writes | `firestore_service.dart` |
| 4 | Prompt injection | `PromptGuard` sanitization | `security.dart`, `ai_service.dart` |
| 5 | LLM response manipulation | `LlmResponseValidator` | `security.dart`, `ai_service.dart` |
| 6 | Demo mode bypass | Block `local_` UIDs from Firestore | `firestore_service.dart` |
| 7 | API abuse | `RateLimiter` per endpoint | `security.dart`, `ai_service.dart` |
| 8 | Key in URL query | `x-goog-api-key` header | `ai_service.dart` |
| 9 | XSS in stored data | `InputSanitizer` on all inputs | `security.dart`, `nutrition_screen.dart` |
| 10 | Unbounded chat history | Auto-prune at 200 messages | `firestore_service.dart` |
| 11 | MITM attacks | Cert pinning (see above) | Production setup |
| 12 | APK reverse engineering | ProGuard + obfuscation | `android-proguard-rules.pro` |
| 13 | Weak email validation | RFC 5322 regex | `security.dart`, `login_screen.dart` |
