import 'dart:io';

import 'package:aad_oauth/bloc/aad_bloc.dart';
import 'package:aad_oauth/repository/token_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AzureLoginWidget extends StatelessWidget {
  final TokenRepository tokenRepository;
  final Widget whenAuthenticated;
  final Widget whenSignedOut;
  final Widget whenInitial;
  final Widget whenLoginFailed;
  AzureLoginWidget({
    required this.tokenRepository,
    required this.whenAuthenticated,
    required this.whenInitial,
    required this.whenSignedOut,
    required this.whenLoginFailed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (BuildContext context) => AadBloc(
        tokenRepository: tokenRepository,
      ),
      child: _AzureLoginSubTree(
        whenAuthenticated: whenAuthenticated,
        whenSignedOut: whenSignedOut,
        whenInitial: whenInitial,
        whenLoginFailed: whenLoginFailed,
      ),
    );
  }
}

class _AzureLoginSubTree extends StatelessWidget {
  final Widget whenAuthenticated;
  final Widget whenSignedOut;
  final Widget whenInitial;
  final Widget whenLoginFailed;

  _AzureLoginSubTree(
      {required this.whenAuthenticated,
      required this.whenInitial,
      required this.whenSignedOut,
      required this.whenLoginFailed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadBloc, AadState>(builder: (context, state) {
      if (state is AadInitial) {
        return whenInitial;
      }
      if (state is AadFullFlow) {
        return _FullLoginFlowWidget();
      }
      if (state is AadLoginFailed) {
        return whenLoginFailed;
      }
      if (state is AadLoggedOut) {
        return whenSignedOut;
      }
      if (state is AadStateWithToken) {
        return whenAuthenticated;
      }
      if (state is AadInternalError) {
        return Center(child: Text(state.message));
      }
      return Center(
          child:
              Text('Unknown Azure AD State encountered: ${state.runtimeType}'));
    });
  }
}

class _FullLoginFlowWidget extends StatelessWidget {
  _FullLoginFlowWidget() {
    // Enable hybrid composition on Android
    if (Platform.isAndroid && !kIsWeb) {
      WebView.platform = SurfaceAndroidWebView();
    }
    // Ensure we get a fresh start
    // Do we think this is necessary?
    CookieManager().clearCookies();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadBloc, AadState>(
      builder: (context, state) {
        final bloc = BlocProvider.of<AadBloc>(context);
        return WebView(
          initialUrl: bloc.tokenRepository.authorizationUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onPageStarted: (String url) {
            bloc.add(AadFullLoginFlowPageLoad(url));
          },
          onWebResourceError: (WebResourceError wre) {
            bloc.add(AadSignInError(wre.description));
          },
        );
      },
    );
  }
}
