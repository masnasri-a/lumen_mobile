import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();
      return await _googleSignIn.authenticate();
    } catch (_) {
      return null;
    }
  }

  /// Returns the Google ID token for the given account.
  /// This token is sent to the backend for verification.
  static Future<String?> getIdToken(GoogleSignInAccount account) async {
    try {
      final auth = account.authentication;
      return auth.idToken;
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
