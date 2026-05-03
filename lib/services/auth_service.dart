import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int universityId,
    required int facultyId,
    required int departmentId,
    DateTime? birthDate,
    String? studentEmail,
    required bool privacyAccepted,
    required String privacyAcceptedAt,
    required bool termsAccepted,
    required String termsAcceptedAt,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'privacy_accepted': privacyAccepted,
          'privacy_accepted_at': privacyAcceptedAt,
          'terms_accepted': termsAccepted,
          'terms_accepted_at': termsAcceptedAt,
        },
      ).timeout(const Duration(seconds: 20));

      final User? user = response.user;

      if (user != null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'first_name': firstName,
          'last_name': lastName,
          'full_name': '$firstName $lastName',
          'email': email,
          'personal_email': email,
          'student_email': studentEmail,
          'university_id': universityId,
          'faculty_id': facultyId,
          'department_id': departmentId,
          'birth_date': birthDate?.toIso8601String(),
          'is_verified': false,
          'privacy_accepted': privacyAccepted,
          'privacy_accepted_at': privacyAcceptedAt,
          'terms_accepted': termsAccepted,
          'terms_accepted_at': termsAcceptedAt,
          'created_at': DateTime.now().toIso8601String(),
        }).timeout(const Duration(seconds: 20));
      }

      return response;
    } on AuthException catch (e) {
      debugPrint("Supabase Auth Error: ${e.message} (Status: ${e.statusCode})");

      if (e.message.contains("email rate limit exceeded") || e.statusCode == '429') {
        throw const AuthException(
          "Güvenlik nedeniyle kısa süreliğine engellendiniz. Lütfen 1-2 dakika bekleyip tekrar deneyin veya farklı bir internet ağına bağlanın.",
        );
      } else if (e.message.contains("User already registered")) {
        throw const AuthException("Bu e-posta adresi zaten kayıtlı. Lütfen giriş yapın.");
      } else if (e.message.contains("Password should be at least")) {
        throw const AuthException("Şifreniz en az 6 karakter olmalıdır.");
      } else if (e.message.contains("Email signups are disabled")) {
        throw const AuthException("E-posta ile kayıt olma özelliği şu an kapalıdır.");
      }

      rethrow;
    } on TimeoutException {
      throw const AuthException("Bağlantı zaman aşımına uğradı. İnternetinizi kontrol edin.");
    } catch (e) {
      debugPrint("Unexpected Auth Error: $e");
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 20));
    } on AuthException catch (e) {
      if (e.statusCode == '429') {
        throw const AuthException("Çok fazla giriş denemesi. Lütfen bekleyin.");
      }
      rethrow;
    } on TimeoutException {
      throw const AuthException("Giriş işlemi zaman aşımına uğradı.");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Profile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Profile.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}