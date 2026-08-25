import Toybox.Application;
import Toybox.WatchUi;

class AiUsageApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var view = new AiUsageView();
        return [view, new AiUsageDelegate(view)];
    }

    function getGlanceView() {
        return [new AiUsageGlanceView()];
    }
}

function getApp() as AiUsageApp {
    return Application.getApp() as AiUsageApp;
}
