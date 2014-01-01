part of SiteLib;
class TopMenuController {

  TopMenuController() {
    _setupDropdown();
  }

  _setupDropdown(){
    // When a dropdown option is selected, navigate to /auth/OPTION
    context.callMethod("jQuery", ['.ui.dropdown']).callMethod('dropdown', [new JsObject.jsify({
        'performance': false,
        'debug'      : false,
        'verbose'    : false,
        'duration'   : 250,
        'onChange'   : new JsFunction.withThis((dynamic thing, String arg1, String arg2 ) => window.location.assign("/auth/"+arg1) )
    })]);
  }
}