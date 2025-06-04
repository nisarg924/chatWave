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

  StreamSubscription<QuerySnapshot>? _subscription;

  /// Subscribes to Firestore `users` where `isLoggedIn == true`
  void loadLoggedInUsers() {
    emit(UsersLoading());

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
        final users = snapshot.docs.map((doc) {
          final data = doc.data();
          return <String, dynamic>{
            'uid': data['uid'],
            'name': data['name'],
            'phoneNumber': data['phoneNumber'],
            'lastLogin': data['lastLogin'],
            'imageUrl': data['imageUrl'] as String? ?? "",
          };
        }).toList();
        emit(UsersLoaded(users));
      },
      onError: (error) {
        emit(UsersError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}