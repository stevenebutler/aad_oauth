import 'dart:async';
import 'package:aad_oauth/model/token.dart';
import 'package:aad_oauth/repository/token_repository.dart';
import 'package:equatable/equatable.dart';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'aad_event.dart';
part 'aad_state.dart';

class AadBloc extends Bloc<AadEvent, AadState> {
  AadBloc({
    required this.tokenRepository,
  }) : super(AadInitial()) {
    add(AadUserRequestsLogIn());
  }
  final TokenRepository tokenRepository;

  @override
  Stream<AadState> mapEventToState(
    AadEvent event,
  ) async* {
    if (event is AadUserRequestsLogIn) {
      yield await processLoginRequested();
    } else if (event is AadAccessTokenNeedsRefresh) {
      yield await processAccessTokenRefresh();
    } else if (event is AadUserLogsOut) {
      await tokenRepository.clearTokenFromCache();
      yield AadLoggedOut();
    } else if (event is AadAccessTokenRejected) {
      yield await processAccessTokenRefresh();
    } else if (event is AadRefreshTokenRejected) {
      yield AadFullFlow();
    } else if (event is AadFullLoginFlowPageLoad) {
      yield await processFullLoginFlowPageLoadUrl(event.url);
    } else if (event is AadSignInError) {
      yield await AadInternalError(event.description);
    } else {
      yield AadInternalError(
          'Unexpected/unhandled AadEvent type ${event} received');
    }
  }

  Future<AadState> processFullLoginFlowPageLoadUrl(String url) async {
    var uri = Uri.parse(url);

    if (uri.queryParameters['error'] != null) {
      return AadLoginFailed();
    }
    final code = uri.queryParameters['code'];
    if (code != null) {
      final token = await tokenRepository.requestTokenWithCode(code);
      if (token.hasValidAccessToken()) {
        return AadLoginSuccess(token: token);
      } else {
        return AadLoginFailed();
      }
    }
    return state;
  }

  Future<AadState> processLoginRequested() async {
    try {
      final token = await tokenRepository.loadTokenFromCache();
      if (token.hasValidAccessToken()) {
        return AadLoginSuccess(token: token);
      } else if (token.hasRefreshToken()) {
        return await _processRefreshWithToken(token);
      }
    } catch (e) {
      print(e);
    }
    return AadFullFlow();
  }

  Future<AadState> processAccessTokenRefresh() async {
    final aState = state;
    if (aState is AadStateWithToken) {
      final token = aState.token;

      return await _processRefreshWithToken(token);
    } else {
      // If state has no token, we always attempt full flow
      return AadFullFlow();
    }
  }

  Future<AadState> _processRefreshWithToken(Token token) async {
    try {
      final newToken = await tokenRepository.refreshAccessTokenFlow(token);
      await tokenRepository.saveTokenToCache(newToken);
      if (newToken.hasValidAccessToken()) {
        return AadLoginSuccess(token: newToken);
      }
    } catch (e) {
      print(e);
    }
    // Fall-through is full flow
    return AadFullFlow();
  }
}
