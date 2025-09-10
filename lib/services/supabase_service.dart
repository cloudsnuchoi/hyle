import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase client will be initialized in main.dart
  SupabaseClient get client => Supabase.instance.client;
  
  // Helper method to check if Supabase is initialized
  bool get isInitialized {
    try {
      final _ = Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Auth helper methods
  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;
  bool get isAuthenticated => currentSession != null;

  // Stream subscriptions for real-time features
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Database operations
  Future<List<Map<String, dynamic>>> getStudySessions(String userId) async {
    try {
      final response = await client
          .from('study_sessions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching study sessions: $e');
      return [];
    }
  }

  Future<void> createStudySession({
    required String userId,
    required String subject,
    required int duration,
    required DateTime timestamp,
  }) async {
    try {
      await client.from('study_sessions').insert({
        'user_id': userId,
        'subject': subject,
        'duration': duration,
        'timestamp': timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Error creating study session: $e');
      rethrow;
    }
  }

  // Todo operations
  Future<List<Map<String, dynamic>>> getTodos(String userId) async {
    try {
      final response = await client
          .from('todos')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching todos: $e');
      return [];
    }
  }

  Future<void> createTodo({
    required String userId,
    required String content,
    required String category,
    String? priority,
  }) async {
    try {
      await client.from('todos').insert({
        'user_id': userId,
        'content': content,
        'category': category,
        'priority': priority ?? 'medium',
        'completed': false,
      });
    } catch (e) {
      print('Error creating todo: $e');
      rethrow;
    }
  }

  Future<void> updateTodo({
    required String todoId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      await client.from('todos').update(updates ?? {}).eq('id', todoId);
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await client.from('todos').delete().eq('id', todoId);
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  // User profile operations
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('users_profile')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await client
          .from('users_profile')
          .upsert({
            'id': userId,
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToUserTodos(String userId, Function(List<Map<String, dynamic>>) callback) {
    return client
        .channel('todos:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'todos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            // Fetch updated todos when changes occur
            final todos = await getTodos(userId);
            callback(todos);
          },
        )
        .subscribe();
  }

  // Storage operations (for profile images, etc.)
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
  }) async {
    try {
      final Uint8List uint8List = Uint8List.fromList(bytes);
      final response = await client.storage
          .from(bucket)
          .uploadBinary(path, uint8List);
      
      final url = client.storage
          .from(bucket)
          .getPublicUrl(path);
      
      return url;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage
          .from(bucket)
          .remove([path]);
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}