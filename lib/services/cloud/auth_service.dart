/// Abstract interface for cloud authentication services.
///
/// Provides a contract for sign-in, sign-out, and user session management.
/// Concrete implementations should use Firebase Auth or another provider.
abstract class AuthService {
  /// Signs in the user with their Google account.
  /// Returns a [CloudUser] on success.
  Future<CloudUser> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();

  /// Returns the currently authenticated user, or null if not signed in.
  CloudUser? getCurrentUser();

  /// Returns true if a user is currently signed in.
  bool isSignedIn();
}

/// Represents an authenticated cloud user.
class CloudUser {
  const CloudUser({
    required this.id,
    required this.email,
    this.displayName = '',
    this.photoUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
  };

  factory CloudUser.fromMap(Map<String, dynamic> map) => CloudUser(
    id: map['id'] as String,
    email: map['email'] as String,
    displayName: map['displayName'] as String? ?? '',
    photoUrl: map['photoUrl'] as String?,
  );
}

/// Stub implementation of [AuthService] for environments without cloud support.
///
/// All methods return errors or placeholder values. Use this as a default
/// when Firebase or another auth provider is not configured.
class AuthServiceStub implements AuthService {
  @override
  Future<CloudUser> signInWithGoogle() async {
    throw UnimplementedError('Cloud auth is not configured.');
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError('Cloud auth is not configured.');
  }

  @override
  CloudUser? getCurrentUser() => null;

  @override
  bool isSignedIn() => false;
}
