part of 'session_validation_bloc.dart';

abstract class SessionValidationState extends ScreenState {}

class SessionValidationInitState extends SessionValidationState {}

class SessionValidationProgressState extends SessionValidationState {}

class SessionValidState extends SessionValidationState {}

class SessionInValidState extends SessionValidationState {}
