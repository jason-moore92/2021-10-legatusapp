import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class BridgeState extends Equatable {
  final String? event;
  final Map<String, dynamic>? data;

  BridgeState({@required this.event, @required this.data});

  factory BridgeState.init() {
    return BridgeState(event: "", data: {});
  }

  BridgeState copyWith({String? event, Map<String, dynamic>? data}) {
    return BridgeState(
      event: event ?? this.event,
      data: data ?? this.data,
    );
  }

  BridgeState update({String? event, Map<String, dynamic>? data}) {
    return copyWith(event: event, data: data);
  }

  Map<String, dynamic> toJson() {
    return {"event": event, "data": data};
  }

  @override
  List<Object> get props => [event!, data!];

  @override
  bool get stringify => true;
}
