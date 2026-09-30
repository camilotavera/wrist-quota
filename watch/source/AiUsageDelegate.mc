import Toybox.WatchUi;

class AiUsageDelegate extends WatchUi.BehaviorDelegate {
    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(event) {
        var coordinates = event.getCoordinates();
        if (!_view.hasData() || coordinates[1] >= 326) {
            _view.refresh();
            return true;
        }
        if (_view.isOverview()) {
            if (coordinates[0] >= 58 && coordinates[0] <= 332 && coordinates[1] >= 86 && coordinates[1] < 316) {
                return _view.showAccount(coordinates[0] < 195 ? 0 : 1);
            }
            return false;
        }
        if (coordinates[0] < 95 && coordinates[1] < 100) {
            _view.showOverview();
            return true;
        }
        return false;
    }

    function onSwipe(event) {
        var direction = event.getDirection();
        if (direction == WatchUi.SWIPE_UP || direction == WatchUi.SWIPE_LEFT) {
            return _view.changePage(1);
        }
        if (direction == WatchUi.SWIPE_DOWN) {
            return _view.changePage(-1);
        }
        if (direction == WatchUi.SWIPE_RIGHT) {
            if (_view.changePage(-1)) {
                return true;
            }
            return onBack();
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
