import Toybox.Application;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.WatchUi;

class AiUsageView extends WatchUi.View {
    private var _client;
    private var _data;
    private var _error;
    private var _accountId;
    private var _accountPage;
    private var _limitPage;
    private var _cached;
    private var _loading;
    private var _demo;

    function initialize() {
        View.initialize();
        _client = new UsageClient();
        _data = null;
        _error = null;
        _accountId = null;
        _accountPage = 0;
        _limitPage = 0;
        _cached = false;
        _loading = false;
        _demo = false;
    }

    function onShow() {
        if (_loading) {
            return;
        }
        loadSettings();
        refresh();
    }

    private function loadSettings() {
        var demo = Application.Properties.getValue("demoMode") == true;
        if (_demo != demo) {
            _accountId = null;
            _accountPage = 0;
            _limitPage = 0;
        }
        _demo = demo;
        _data = null;
        _cached = false;
        if (!_demo) {
            var saved = Application.Storage.getValue("usage");
            if (UsageData.isValid(saved)) {
                _data = saved;
                _cached = true;
            }
        }
    }

    function refresh() {
        if (_loading) {
            return;
        }
        if (_demo != (Application.Properties.getValue("demoMode") == true)) {
            loadSettings();
        }
        _loading = true;
        _error = null;
        WatchUi.requestUpdate();
        _client.fetch(method(:onUsage));
    }

    function onUsage(data, error) {
        _loading = false;
        _error = error;
        if (data != null) {
            _data = UsageData.merge(data, _data);
            _cached = false;
            if (!_demo) {
                Application.Storage.setValue("usage", _data);
            }
        } else {
            _cached = _data != null;
        }
        if (_accountId != null && UsageData.account(_data, _accountId) == null) {
            _accountId = null;
        }
        clampPages();
        WatchUi.requestUpdate();
    }

    function isOverview() {
        return _accountId == null;
    }

    function hasData() {
        return _data != null;
    }

    function showAccount(row) {
        var rows = UsageData.accounts(_data);
        var index = _accountPage * 4 + row;
        if (index < 0 || index >= rows.size()) {
            return false;
        }
        _accountId = rows[index]["id"];
        _limitPage = 0;
        if (!_demo) {
            Application.Storage.setValue("selectedAccountId", _accountId);
        }
        WatchUi.requestUpdate();
        return true;
    }

    function showOverview() {
        _accountId = null;
        WatchUi.requestUpdate();
    }

    function changePage(direction) {
        var count = isOverview() ? UsageData.accounts(_data).size()
            : UsageData.limits(UsageData.account(_data, _accountId)).size();
        var size = isOverview() ? 4 : 3;
        var current = isOverview() ? _accountPage : _limitPage;
        var next = current + direction;
        if (next < 0 || next * size >= count) {
            return false;
        }
        if (isOverview()) {
            _accountPage = next;
        } else {
            _limitPage = next;
        }
        WatchUi.requestUpdate();
        return true;
    }

    private function clampPages() {
        if (_accountPage * 4 >= UsageData.accounts(_data).size()) {
            _accountPage = 0;
        }
        if (_limitPage * 3 >= UsageData.limits(UsageData.account(_data, _accountId)).size()) {
            _limitPage = 0;
        }
    }

    function onUpdate(dc) {
        dc.setColor(Theme.FOREGROUND, Theme.BACKGROUND);
        dc.clear();
        if (_data == null) {
            drawStatus(dc, _error == null ? "Loading" : _error);
            drawFooter(dc, "Tap to retry");
            return;
        }
        if (isOverview()) {
            drawOverview(dc);
        } else {
            drawDetails(dc, UsageData.account(_data, _accountId));
        }
    }

    private function drawStatus(dc, text) {
        dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
        drawFitted(dc, 195, 180, Graphics.FONT_SMALL, text, 290, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawOverview(dc) {
        var rows = UsageData.accounts(_data);
        dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 53, Graphics.FONT_SMALL, "ACCOUNTS", Graphics.TEXT_JUSTIFY_CENTER);
        drawPage(dc, _accountPage, rows.size(), 4);
        if (rows.size() == 0) {
            drawStatus(dc, "No accounts");
        }
        var end = (_accountPage + 1) * 4;
        if (end > rows.size()) {
            end = rows.size();
        }
        for (var index = _accountPage * 4; index < end; index += 1) {
            var account = rows[index];
            var top = 92 + (index % 4) * 61;
            dc.setColor(colorForAccount(account), Graphics.COLOR_TRANSPARENT);
            drawFitted(dc, 63, top, Graphics.FONT_XTINY, accountTitle(account), 185, Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
            dc.drawText(327, top - 4, Graphics.FONT_SMALL, UsageData.percentText(UsageData.headline(account)), Graphics.TEXT_JUSTIFY_RIGHT);
            dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
            drawFitted(dc, 63, top + 24, Graphics.FONT_XTINY, accountStatus(account), 264, Graphics.TEXT_JUSTIFY_LEFT);
            if (index + 1 < end) {
                dc.setColor(Theme.DIVIDER, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(63, top + 52, 327, top + 52);
            }
        }
        drawFooter(dc, _loading ? "Updating..." : (_demo ? "DEMO | Refresh" : (_error != null ? "Saved | Retry" : "Refresh")));
    }

    private function drawDetails(dc, account) {
        var limits = UsageData.limits(account);
        dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
        dc.drawText(57, 55, Graphics.FONT_LARGE, "‹", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(colorForAccount(account), Graphics.COLOR_TRANSPARENT);
        drawFitted(dc, 205, 62, Graphics.FONT_XTINY, accountTitle(account), 220, Graphics.TEXT_JUSTIFY_CENTER);
        drawPage(dc, _limitPage, limits.size(), 3);
        if (limits.size() == 0) {
            drawStatus(dc, "Unavailable");
        }
        var end = (_limitPage + 1) * 3;
        if (end > limits.size()) {
            end = limits.size();
        }
        var rowHeight = limits.size() <= 2 ? 95 : 73;
        var firstY = limits.size() <= 2 ? 126 : 106;
        for (var index = _limitPage * 3; index < end; index += 1) {
            drawLimit(dc, limits[index], firstY + (index % 3) * rowHeight, account);
        }
        var status = _demo ? "DEMO" : (_cached || account["status"] == "unavailable" ? "Saved " : "Updated ") + UsageData.ageLabel(account, Time.now().value());
        drawFooter(dc, _loading ? "Updating..." : status + " | Refresh");
    }

    private function drawLimit(dc, limit, top, account) {
        dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
        drawFitted(dc, 72, top, Graphics.FONT_XTINY, limit["label"], 165, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(318, top - 4, Graphics.FONT_SMALL, UsageData.percentText(limit), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
        drawFitted(dc, 72, top + 26, Graphics.FONT_XTINY, limit["resetLabel"], 246, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Theme.TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(72, top + 51, 246, 6);
        dc.setColor(limit["id"] == "fable" ? Theme.FABLE : colorForAccount(account), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(72, top + 51, (246 * UsageData.percent(limit)) / 100, 6);
    }

    private function drawFooter(dc, text) {
        dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
        drawFitted(dc, 195, 335, Graphics.FONT_XTINY, text, 244, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawPage(dc, page, count, size) {
        if (count > size) {
            dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(isOverview() ? 300 : 195, isOverview() ? 57 : 82, Graphics.FONT_XTINY, (page + 1).format("%d") + "/" + ((count + size - 1) / size).toNumber().format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    private function drawFitted(dc, x, y, font, text, width, justification) {
        if (dc.getTextWidthInPixels(text, font) > width) {
            while (text.length() > 0 && dc.getTextWidthInPixels(text + "...", font) > width) {
                text = text.substring(0, text.length() - 1);
            }
            text += "...";
        }
        dc.drawText(x, y, font, text, justification);
    }

    private function accountTitle(account) {
        return (account["provider"] == "codex" ? "Codex" : "Claude") + " · " + account["name"];
    }

    private function colorForAccount(account) {
        return account["provider"] == "codex" ? Theme.CODEX : Theme.CLAUDE;
    }

    private function accountStatus(account) {
        if (UsageData.headline(account) == null) {
            return "Unavailable";
        }
        if (!_demo && (_cached || account["status"] == "unavailable")) {
            return "Saved " + UsageData.ageLabel(account, Time.now().value());
        }
        return UsageData.text(UsageData.headline(account), "resetLabel", "reset unknown");
    }
}
