part of 'aad_bloc.dart';

@immutable
abstract class AadEvent extends Equatable {}

class AadAccessTokenNeedsRefresh extends AadEvent {
  AadAccessTokenNeedsRefresh();

  @override
  List<Object> get props => [AadAccessTokenNeedsRefresh];
}

class AadAccessTokenRejected extends AadEvent {
  AadAccessTokenRejected();

  @override
  List<Object> get props => [AadAccessTokenRejected];
}

class AadRefreshTokenRejected extends AadEvent {
  AadRefreshTokenRejected();

  @override
  List<Object> get props => [AadRefreshTokenRejected];
}

class AadSignInError extends AadEvent {
  final String description;

  AadSignInError(this.description);

  @override
  List<Object> get props => [AadRefreshTokenRejected, description];
}

class AadUserLogsOut extends AadEvent {
  @override
  List<Object> get props => [AadUserLogsOut];
}

class AadUserRequestsLogIn extends AadEvent {
  @override
  List<Object> get props => [AadUserRequestsLogIn];
}

class AadFullLoginFlowPageLoad extends AadEvent {
  final String url;

  AadFullLoginFlowPageLoad(this.url);
  @override
  List<Object> get props => [AadFullLoginFlowPageLoad, url];
}
