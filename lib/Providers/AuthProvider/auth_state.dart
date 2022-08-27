import 'package:flutter/material.dart';
import 'package:legatus/Models/user_model.dart';
import 'package:equatable/equatable.dart';

enum LoginState {
  isLogin,
  isNotLogin,
}

class AuthState extends Equatable {
  final int? progressState;
  final String? message;
  final String? contextName;
  final String? description;
  final int? statusCode;
  final LoginState? loginState;
  final bool? smsCode;
  final UserModel? userModel;

  const AuthState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.description,
    @required this.statusCode,
    @required this.loginState,
    @required this.smsCode,
    @required this.userModel,
  });

  factory AuthState.init() {
    return AuthState(
      progressState: 0,
      message: "",
      contextName: "",
      description: "",
      statusCode: 0,
      loginState: LoginState.isNotLogin,
      smsCode: false,
      userModel: UserModel(),
    );
  }

  AuthState copyWith({
    int? progressState,
    String? message,
    String? contextName,
    String? description,
    int? statusCode,
    LoginState? loginState,
    bool? smsCode,
    UserModel? userModel,
  }) {
    return AuthState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      description: description ?? this.description,
      statusCode: statusCode ?? this.statusCode,
      loginState: loginState ?? this.loginState,
      smsCode: smsCode ?? this.smsCode,
      userModel: userModel ?? this.userModel,
    );
  }

  AuthState update({
    int? progressState,
    String? message,
    String? contextName,
    String? description,
    int? statusCode,
    LoginState? loginState,
    bool? smsCode,
    UserModel? userModel,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      description: description,
      statusCode: statusCode,
      loginState: loginState,
      smsCode: smsCode,
      userModel: userModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "contextName": contextName,
      "description": description,
      "statusCode": statusCode,
      "loginState": loginState,
      "smsCode": smsCode,
      "userModel": userModel!.toJson(),
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        contextName!,
        description!,
        statusCode!,
        loginState!,
        smsCode!,
        userModel!,
      ];

  @override
  bool get stringify => true;
}
