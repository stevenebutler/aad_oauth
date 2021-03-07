part of 'aad_bloc.dart';

@immutable
abstract class AadState extends Equatable {}

// Typical spinner
class AadInitial extends AadState {
  @override
  List<Object> get props => [AadInitial];
}

// Will be showing WebView
class AadFullFlow extends AadState {
  @override
  List<Object> get props => [AadFullFlow];
}

class AadLoginFailed extends AadState {
  @override
  List<Object> get props => [AadLoginFailed];
}

class AadLoggedOut extends AadState {
  @override
  List<Object> get props => [AadLoggedOut];
}

abstract class AadStateWithToken extends AadState {
  final Token token;
  AadStateWithToken({required this.token});

  @override
  List<Object> get props => [AadStateWithToken, token];
}

// Will be silently refreshing - could display indication refresh is in progress
class AadTokenRefreshInProgress extends AadStateWithToken {
  AadTokenRefreshInProgress({required Token token}) : super(token: token);

  @override
  List<Object> get props => [AadTokenRefreshInProgress, token];
}

class AadLoginSuccess extends AadStateWithToken {
  AadLoginSuccess({required Token token}) : super(token: token);

  @override
  List<Object> get props => [AadLoginSuccess, token];
}

class AadInternalError extends AadState {
  final String message;
  AadInternalError(this.message);

  @override
  List<Object?> get props => [AadInternalError, message];
}
