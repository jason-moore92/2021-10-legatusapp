import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class PlanningState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final Map<String, dynamic>? planningData;

  PlanningState({
    @required this.progressState,
    @required this.message,
    @required this.planningData,
  });

  factory PlanningState.init() {
    return PlanningState(
      progressState: 0,
      message: "",
      planningData: Map<String, dynamic>(),
    );
  }

  PlanningState copyWith({
    int? progressState,
    String? message,
    Map<String, dynamic>? planningData,
  }) {
    return PlanningState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      planningData: planningData ?? this.planningData,
    );
  }

  PlanningState update({
    int? progressState,
    String? message,
    Map<String, dynamic>? planningData,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      planningData: planningData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "planningData": planningData,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        planningData!,
      ];

  @override
  bool get stringify => true;
}
