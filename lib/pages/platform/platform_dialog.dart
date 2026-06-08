import 'dart:async';

import 'package:flutter/material.dart';

const double _dialogMediumBreakpointWidth = 840;

class PlatformDialog {
  static final PlatformDialogObserver observer = PlatformDialogObserver();

  PlatformDialog._internal();

  static Future<T?> show<T>({
    BuildContext? context,
    bool? clickMaskDismiss,
    VoidCallback? onDismiss,
    required WidgetBuilder builder,
  }) async {
    final ctx = context ?? observer.currentContext;
    if (ctx != null && ctx.mounted) {
      try {
        final result = await showDialog<T>(
          context: ctx,
          barrierDismissible: clickMaskDismiss ?? true,
          builder: builder,
          routeSettings: const RouteSettings(name: 'PlatformDialog'),
        );
        onDismiss?.call();
        return result;
      } catch (error) {
        debugPrint('Platform Dialog Error: Failed to show dialog: $error');
        return null;
      }
    }

    debugPrint('Platform Dialog Error: No context available to show dialog');
    return null;
  }

  static void showToast({
    required String message,
    BuildContext? context,
    bool showActionButton = false,
    String? actionLabel,
    Function()? onActionPressed,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ctx = context ?? observer.scaffoldContext;
    if (ctx != null && ctx.mounted) {
      try {
        ScaffoldMessenger.of(ctx)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              width: MediaQuery.sizeOf(ctx).width > _dialogMediumBreakpointWidth
                  ? 600
                  : null,
              duration: duration,
              persist: false,
              action: showActionButton
                  ? SnackBarAction(
                      label: actionLabel ?? 'Dismiss',
                      onPressed: () {
                        onActionPressed?.call();
                        ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                      },
                    )
                  : null,
            ),
          );
      } catch (error) {
        debugPrint('Platform Dialog Error: Failed to show toast: $error');
      }
      return;
    }

    debugPrint(
      'Platform Dialog Error: No scaffold context available to show toast',
    );
  }

  static Future<void> showLoading({
    BuildContext? context,
    String? msg,
    bool barrierDismissible = false,
    Function()? onDismiss,
  }) async {
    final ctx = context ?? observer.currentContext;
    if (ctx != null && ctx.mounted) {
      try {
        await showDialog<void>(
          context: ctx,
          barrierDismissible: barrierDismissible,
          builder: (context) {
            return Center(
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        msg ?? 'Loading...',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          routeSettings: const RouteSettings(name: 'PlatformDialog'),
        );
        onDismiss?.call();
      } catch (error) {
        debugPrint(
          'Platform Dialog Error: Failed to show loading dialog: $error',
        );
      }
      return;
    }

    debugPrint(
      'Platform Dialog Error: No context available to show loading dialog',
    );
  }

  static Future<T?> showBottomSheet<T>({
    BuildContext? context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = true,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    bool useSafeArea = false,
  }) async {
    final ctx = context ?? observer.rootContext ?? observer.currentContext;
    if (ctx != null && ctx.mounted) {
      try {
        return await showModalBottomSheet<T>(
          context: ctx,
          builder: builder,
          backgroundColor: backgroundColor,
          elevation: elevation,
          shape: shape,
          clipBehavior: clipBehavior,
          constraints: constraints,
          barrierColor: barrierColor,
          isScrollControlled: isScrollControlled,
          useRootNavigator: useRootNavigator,
          isDismissible: isDismissible,
          enableDrag: enableDrag,
          routeSettings:
              routeSettings ?? const RouteSettings(name: 'PlatformBottomSheet'),
          transitionAnimationController: transitionAnimationController,
          anchorPoint: anchorPoint,
          useSafeArea: useSafeArea,
        );
      } catch (error) {
        debugPrint(
          'Platform Dialog Error: Failed to show bottom sheet: $error',
        );
        return null;
      }
    }

    debugPrint(
      'Platform Dialog Error: No context available to show bottom sheet',
    );
    return null;
  }

  static void dismiss<T>({T? popWith}) {
    if (observer.hasPlatformDialog && observer.platformDialogContext != null) {
      try {
        Navigator.of(observer.platformDialogContext!).pop(popWith);
      } catch (error) {
        debugPrint('Platform Dialog Error: Failed to dismiss dialog: $error');
      }
    } else {
      debugPrint('Platform Dialog Debug: No active platform dialog to dismiss');
    }
  }

  static void showTimedSuccessDialog({
    required String title,
    required String message,
    required VoidCallback onComplete,
    Duration duration = const Duration(seconds: 3),
  }) {
    PlatformDialog.show<bool>(
      clickMaskDismiss: false,
      builder: (context) => _TimedSuccessDialog(
        title: title,
        message: message,
        duration: duration,
      ),
    ).then((completed) {
      if (completed == true) {
        onComplete();
      }
    });
  }
}

class _TimedSuccessDialog extends StatefulWidget {
  const _TimedSuccessDialog({
    required this.title,
    required this.message,
    required this.duration,
  });

  final String title;
  final String message;
  final Duration duration;

  @override
  State<_TimedSuccessDialog> createState() => _TimedSuccessDialogState();
}

class _TimedSuccessDialogState extends State<_TimedSuccessDialog> {
  Timer? _countdownTimer;
  late final Stopwatch _stopwatch = Stopwatch()..start();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final totalMs = widget.duration.inMilliseconds.clamp(1, 1 << 31);
      final elapsed = _stopwatch.elapsedMilliseconds;
      final nextProgress = (elapsed / totalMs).clamp(0.0, 1.0).toDouble();
      if (!mounted) return;
      setState(() {
        _progress = nextProgress;
      });
      if (elapsed >= totalMs) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        PlatformDialog.dismiss(popWith: true);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 52,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: _progress,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlatformDialogObserver extends NavigatorObserver {
  final List<Route<dynamic>> _platformDialogRoutes = [];
  BuildContext? _currentContext;
  BuildContext? _scaffoldContext;
  BuildContext? _rootContext;

  BuildContext? get currentContext => _currentContext;
  BuildContext? get scaffoldContext => _scaffoldContext ?? _currentContext;
  BuildContext? get rootContext =>
      _rootContext ?? _scaffoldContext ?? _currentContext;

  bool get hasPlatformDialog => _platformDialogRoutes.isNotEmpty;

  BuildContext? get platformDialogContext => _platformDialogRoutes.isNotEmpty
      ? _platformDialogRoutes.last.navigator?.context
      : null;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (_isPlatformDialogRoute(route)) {
      _platformDialogRoutes.add(route);
    }
    if (route.navigator?.context != null) {
      _updateContexts(route.navigator!.context, route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _removeCurrentSnackBar(route);
    if (_isPlatformDialogRoute(route)) {
      _platformDialogRoutes.remove(route);
    }
    if (previousRoute?.navigator?.context != null) {
      _updateContexts(previousRoute!.navigator!.context, previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null && _isPlatformDialogRoute(oldRoute)) {
      _platformDialogRoutes.remove(oldRoute);
    }
    if (newRoute != null && _isPlatformDialogRoute(newRoute)) {
      _platformDialogRoutes.add(newRoute);
    }
    if (newRoute?.navigator?.context != null) {
      _updateContexts(newRoute!.navigator!.context, newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (_isPlatformDialogRoute(route)) {
      _platformDialogRoutes.remove(route);
    }
    if (previousRoute?.navigator?.context != null) {
      _updateContexts(previousRoute!.navigator!.context, previousRoute);
    }
  }

  void _updateContexts(BuildContext context, Route<dynamic> route) {
    _currentContext = context;
    if (_hasScaffold(context)) {
      _scaffoldContext = context;
      _rootContext = context;
    }
  }

  bool _hasScaffold(BuildContext context) {
    return Scaffold.maybeOf(context) != null;
  }

  bool _isPlatformDialogRoute(Route<dynamic> route) {
    return route.settings.name == 'PlatformDialog' ||
        route.settings.name == 'PlatformBottomSheet';
  }

  void _removeCurrentSnackBar(Route<dynamic>? route) {
    if (route?.navigator?.context != null) {
      try {
        ScaffoldMessenger.maybeOf(
          route!.navigator!.context,
        )?.removeCurrentSnackBar();
      } catch (_) {}
    }
  }
}
