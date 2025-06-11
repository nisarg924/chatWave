import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<Map<String, dynamic>> users;
  UsersLoaded(this.users);
}

class UsersError extends UsersState {
  final String error;
  UsersError(this.error);
}

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  /// Load all users (remove the isLoggedIn filter if it’s causing your list to be empty)
  void loadUsers() {
    emit(UsersLoading());

    // If you want *all* users (not just isLoggedIn:true), do:
    _subscription = FirebaseFirestore.instance
        .collection('users')
    //.where('isLoggedIn', isEqualTo: true)  // ← remove or comment out
        .snapshots()
        .listen((snapshot) {
      final users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return <String, dynamic>{
          'uid': data['uid'],
          'name': data['name'],
          'phoneNumber': data['phoneNumber'],
          'lastLogin': data['lastLogin'],
          'imageUrl': data['imageUrl'] as String? ?? '',
        };
      }).toList();
      emit(UsersLoaded(users));
    }, onError: (error) {
      emit(UsersError(error.toString()));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
