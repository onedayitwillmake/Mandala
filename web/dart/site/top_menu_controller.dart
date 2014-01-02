part of SiteLib;
class TopMenuController {

  TopMenuController() {
    _setupDropdown();
  }

  _setupDropdown(){
    // Sign in dropdown
    // When a dropdown option is selected, navigate to /auth/OPTION
    context.callMethod("jQuery", ['#top-menu-dropdown']).callMethod('dropdown', [new JsObject.jsify({
        'performance': false,
        'debug'      : false,
        'verbose'    : false,
        'duration'   : 250,
        'onChange'   : new JsFunction.withThis((dynamic thing, String arg1, String arg2 ) => window.location.assign("/auth/"+arg1) )
    })]);

    // info drop down
    context.callMethod("jQuery", ['#top-menu-info-dropdown']).callMethod('dropdown', [new JsObject.jsify({
        'performance': false,
        'debug'      : false,
        'verbose'    : false,
        'duration'   : 250,
        'onChange'   : new JsFunction.withThis((dynamic thing, String arg1, String arg2 ) {
          if( arg1 == "github") window.location.assign("https://github.com/onedayitwillmake/Mandala");
      })
    })]);
  }
}