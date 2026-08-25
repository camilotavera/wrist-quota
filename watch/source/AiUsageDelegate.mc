import Toybox.WatchUi;

class AiUsageDelegate extends WatchUi.BehaviorDelegate {
    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(event) {
        var coordinates = event.getCoordinates();

        if (_view.isOverview()) {
            _view.showProvider(coordinates[0] < 195 ? "codex" : "claude");
            return true;
        }

        if (coordinates[0] < 95 && coordinates[1] < 110) {
            _view.showOverview();
            return true;
        }

        return false;
    }

    function onBack() {
        if (!_view.isOverview()) {
            _view.showOverview();
            return true;
        }

        return false;
    }
}
