import 'package:flutter/material.dart';
import 'package:legutus/Models/user_model.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

enum LoginState {
  IsLogin,
  IsNotLogin,
}

class AuthState extends Equatable {
  final int? progressState;
  final String? message;
  final String? description;
  final int? statusCode;
  final LoginState? loginState;
  final String? contextName;
  final bool? smsCode;
  final UserModel? userModel;

  AuthState({
    @required this.progressState,
    @required this.message,
    @required this.description,
    @required this.statusCode,
    @required this.loginState,
    @required this.contextName,
    @required this.smsCode,
    @required this.userModel,
  });

  factory AuthState.init() {
    return AuthState(
      progressState: 0,
      message: "",
      description: "",
      statusCode: 0,
      loginState: LoginState.IsNotLogin,
      contextName: "",
      smsCode: false,
      userModel: UserModel(),
    );
  }

  AuthState copyWith({
    int? progressState,
    String? message,
    String? description,
    int? statusCode,
    LoginState? loginState,
    String? contextName,
    bool? smsCode,
    UserModel? userModel,
  }) {
    return AuthState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      description: description ?? this.description,
      statusCode: statusCode ?? this.statusCode,
      loginState: loginState ?? this.loginState,
      contextName: contextName ?? this.contextName,
      smsCode: smsCode ?? this.smsCode,
      userModel: userModel ?? this.userModel,
    );
  }

  AuthState update({
    int? progressState,
    String? message,
    String? description,
    int? statusCode,
    LoginState? loginState,
    String? contextName,
    bool? smsCode,
    UserModel? userModel,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      description: description,
      statusCode: statusCode,
      loginState: loginState,
      contextName: contextName,
      smsCode: smsCode,
      userModel: userModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "description": description,
      "statusCode": statusCode,
      "loginState": loginState,
      "contextName": contextName,
      "smsCode": smsCode,
      "userModel": userModel!.toJson(),
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        description!,
        statusCode!,
        loginState!,
        contextName!,
        smsCode!,
        userModel!,
      ];

  @override
  bool get stringify => true;
}
