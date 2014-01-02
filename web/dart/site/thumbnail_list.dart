part of SiteLib;
class ThumbnailList {
  ThumbnailList() {
    context.callMethod("jQuery", ['.ui.rating']).callMethod('rating', ['enable']);
  }
}