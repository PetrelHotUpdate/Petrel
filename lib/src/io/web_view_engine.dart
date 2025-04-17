abstract class WebViewEngine {
  void runJavaScript(String script);
}

class DefaultWebViewEngine implements WebViewEngine {
  const DefaultWebViewEngine();
  @override
  void runJavaScript(String script) {
    throw UnimplementedError();
  }
}
