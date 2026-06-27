import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dentconnect_app/core/services/storage_service.dart';
import 'package:dentconnect_app/features/auth/models/auth_response.dart';
import 'package:dentconnect_app/features/auth/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? role;
  final String? displayName;
  final String? error;

  const AuthState({
    required this.status,
    this.userId,
    this.role,
    this.displayName,
    this.error,
  });

  const AuthState.initial() : this(status: AuthStatus.unknown);

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? role,
    String? displayName,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final StorageService _storageService;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthNotifier(this._authRepository, this._storageService)
      : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final accessToken = await _storageService.getAccessToken();
      final userId = await _storageService.getUserId();
      final role = await _storageService.getUserRole();
      final displayName = await _storageService.getDisplayName();

      if (accessToken != null && userId != null && role != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          userId: userId,
          role: role,
          displayName: displayName,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> loginWithGoogle({String? selectedRole}) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown, error: null);

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseToken = await userCredential.user!.getIdToken();

      final authResponse = await _authRepository.loginWithFirebaseToken(
        firebaseToken!,
        role: selectedRole,
        displayName: googleUser.displayName,
      );

      await _saveAuth(authResponse);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractErrorMessage(e),
      );
    }
  }

  Future<void> loginWithEmail(
    String email,
    String password,
    String role,
  ) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown, error: null);

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseToken = await userCredential.user!.getIdToken();

      final authResponse = await _authRepository.loginWithFirebaseToken(
        firebaseToken!,
        role: role,
      );

      await _saveAuth(authResponse);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractErrorMessage(e),
      );
    }
  }

  Future<void> registerWithEmail(
    String email,
    String password,
    String role,
    String displayName,
  ) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown, error: null);

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(displayName);
      final firebaseToken = await userCredential.user!.getIdToken();

      final authResponse = await _authRepository.loginWithFirebaseToken(
        firebaseToken!,
        role: role,
        displayName: displayName,
      );

      await _saveAuth(authResponse);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractErrorMessage(e),
      );
    }
  }

  Future<void> loginWithFirebaseToken(
    String token, {
    String? role,
    String? phone,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.unknown, error: null);
      final authResponse = await _authRepository.loginWithFirebaseToken(
        token,
        role: role,
        phone: phone,
      );
      await _saveAuth(authResponse);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _extractErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        await _authRepository.logout(refreshToken);
      }
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      await _storageService.clearAll();
    } catch (_) {
      // Always clear local state
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _saveAuth(AuthResponse authResponse) async {
    await _storageService.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );
    await _storageService.saveUserInfo(
      userId: authResponse.userId,
      role: authResponse.role,
      displayName: authResponse.displayName,
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: authResponse.userId,
      role: authResponse.role,
      displayName: authResponse.displayName,
    );
  }

  String _extractErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return e.toString();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(authRepository, storageService);
});
