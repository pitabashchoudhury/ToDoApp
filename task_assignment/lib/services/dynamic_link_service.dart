import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:go_router/go_router.dart';

class DynamicLinksService {
  static final DynamicLinksService _singleton = DynamicLinksService._internal();

  DynamicLinksService._internal();

  static DynamicLinksService get instance => _singleton;
  late GoRouter _router;

  void setRouter(GoRouter router) {
    _router = router;
  }

  Future<Uri> createDynamicLibks(String taskId) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://testassignment.page.link.com/task?id=$taskId"),
      uriPrefix: "https://testassignment.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.example.task_assignment",
      ),
      iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
      dynamicLinkParams,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    return dynamicLink.shortUrl;
  }

  /// 🔍 Handle dynamic links
  Future<void> handleDynamicLinks() async {
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data?.link);

    FirebaseDynamicLinks.instance.onLink.listen(
      (linkData) {
        _handleDeepLink(linkData.link);
      },
      onError: (error) {
        print("Dynamic Link Error: $error");
      },
    );
  }

  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;

    final taskId = uri.queryParameters['id'];
    if (taskId != null && taskId.isNotEmpty) {
      _router.go('/task/$taskId');
    }
  }
}
