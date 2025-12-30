import 'package:flutter/material.dart';
import 'package:prembly_kyc/prembly_kyc.dart';
import 'package:prembly_kyc/src/models/prembly_sheet_result.dart';
import 'package:prembly_kyc/src/ui/prembly_webview.dart';
import 'package:prembly_kyc/src/utils/constants.dart';

/// Shows the Prembly KYC sheet as a modal bottom sheet.
///
/// Returns the result of the verification, or `null` if dismissed.
Future<PremblySheetResult?> showPremblySheet({
  required BuildContext context,
  required PremblyConfig config,
}) {
  return Navigator.of(context, rootNavigator: true).push<PremblySheetResult>(
    _PremblySheetRoute(config: config),
  );
}

/// Custom modal route for the Prembly sheet.
class _PremblySheetRoute extends ModalRoute<PremblySheetResult> {
  _PremblySheetRoute({required this.config});

  final PremblyConfig config;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => sheetAnimationDuration;

  @override
  Duration get reverseTransitionDuration => sheetAnimationDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _PremblySheet(
      config: config,
      animation: animation,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// The actual sheet widget.
class _PremblySheet extends StatefulWidget {
  const _PremblySheet({
    required this.config,
    required this.animation,
  });

  final PremblyConfig config;
  final Animation<double> animation;

  @override
  State<_PremblySheet> createState() => _PremblySheetState();
}

class _PremblySheetState extends State<_PremblySheet> {
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: widget.animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleSuccess(PremblyResponse response) {
    _close(PremblySheetSuccess(response));
  }

  void _handleError(PremblyError error) {
    _close(PremblySheetError(error));
  }

  void _handleCancelled() {
    _close(const PremblySheetCancelled());
  }

  void _close(PremblySheetResult? result) {
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final sheetHeight = screenHeight * sheetHeightFraction;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(
                    alpha: 0.54 * _fadeAnimation.value,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: keyboardHeight,
                height: sheetHeight,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildSheet(context, sheetHeight),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSheet(BuildContext context, double height) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(sheetCornerRadius),
          topRight: Radius.circular(sheetCornerRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(sheetCornerRadius),
          topRight: Radius.circular(sheetCornerRadius),
        ),
        child: Column(
          children: [
            _buildHandle(),
            Expanded(
              child: PremblyWebView(
                config: widget.config,
                onSuccess: _handleSuccess,
                onError: _handleError,
                onCancelled: _handleCancelled,
              ),
            ),
            _buildBottomCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCloseButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _attemptClose,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _attemptClose() async {
    _handleCancelled();
  }
}
