import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class PlanningState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final String? contextName;
  final String? currentDate;
  final Map<String, dynamic>? planningData;

  const PlanningState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.currentDate,
    @required this.planningData,
  });

  factory PlanningState.init() {
    return const PlanningState(
      progressState: 0,
      message: "",
      contextName: "",
      currentDate: "",
      planningData: <String, dynamic>{},
    );
  }

  PlanningState copyWith({
    int? progressState,
    String? message,
    String? contextName,
    String? currentDate,
    Map<String, dynamic>? planningData,
  }) {
    return PlanningState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      currentDate: currentDate ?? this.currentDate,
      planningData: planningData ?? this.planningData,
    );
  }

  PlanningState update({
    int? progressState,
    String? message,
    String? contextName,
    String? currentDate,
    Map<String, dynamic>? planningData,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      currentDate: currentDate,
      planningData: planningData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "contextName": contextName,
      "currentDate": currentDate,
      "planningData": planningData,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        contextName!,
        currentDate!,
        planningData!,
      ];

  @override
  bool get stringify => true;
}
