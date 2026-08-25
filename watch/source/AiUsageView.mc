import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class AiUsageView extends WatchUi.View {
    private var _client;
    private var _data;
    private var _error;
    private var _screen;

    function initialize() {
        View.initialize();
        _client = new UsageClient();
        _data = null;
        _error = null;
        _screen = "overview";
    }

    function onShow() {
        _client.fetch(method(:onUsage));
    }

    function onUsage(data, error) {
        _data = data;
        _error = error;

        if (data != null) {
            Application.Storage.setValue("usage", data);
        }

        WatchUi.requestUpdate();
    }

    function isOverview() {
        return _screen == "overview";
    }

    function showProvider(providerId) {
        _screen = providerId;
        WatchUi.requestUpdate();
    }

    function showOverview() {
        _screen = "overview";
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Theme.FOREGROUND, Theme.BACKGROUND);
        dc.clear();

        if (_data == null) {
            drawStatus(dc, _error == null ? "Loading" : _error);
            return;
        }

        if (_screen == "overview") {
            drawOverview(dc);
        } else {
            drawDetails(dc, _screen);
        }
    }

    private function drawStatus(dc, text) {
        dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawOverview(dc) {
        drawProvider(dc, "CODEX", "codex", 120, Theme.CODEX);
        drawProvider(dc, "CLAUDE", "claude", 270, Theme.CLAUDE);

        dc.setColor(Theme.DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 324, Graphics.FONT_XTINY, "CURRENT WINDOWS", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawProvider(dc, label, providerId, centerX, color) {
        var provider = UsageData.provider(_data, providerId);
        var headline = UsageData.headline(provider);
        var percent = UsageData.percent(headline);
        var reset = UsageData.text(headline, "resetLabel", "reset unknown");

        dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 82, Graphics.FONT_SMALL, label, Graphics.TEXT_JUSTIFY_CENTER);
        drawRing(dc, centerX, 186, 58, percent, color);
        dc.drawText(centerX, 172, Graphics.FONT_LARGE, percent.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 255, Graphics.FONT_XTINY, reset, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawRing(dc, centerX, centerY, radius, percent, color) {
        dc.setPenWidth(9);
        dc.setColor(Theme.TRACK, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(centerX, centerY, radius);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90 + ((percent * 359) / 100));
        dc.setPenWidth(1);
    }

    private function drawDetails(dc, providerId) {
        var isCodex = providerId == "codex";
        var provider = UsageData.provider(_data, providerId);
        var limits = UsageData.limits(provider);

        dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
        dc.drawText(57, 61, Graphics.FONT_LARGE, "‹", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(195, 67, Graphics.FONT_MEDIUM, isCodex ? "CODEX" : "CLAUDE", Graphics.TEXT_JUSTIFY_CENTER);

        var rowCount = limits.size();
        if (rowCount > 3) {
            rowCount = 3;
        }
        var firstY = rowCount == 3 ? 106 : 126;
        var rowHeight = rowCount == 3 ? 72 : 92;

        for (var index = 0; index < rowCount; index += 1) {
            drawLimit(dc, limits[index], firstY + (index * rowHeight), colorForLimit(providerId, limits[index]));
        }

        dc.setColor(Theme.DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 337, Graphics.FONT_XTINY, "TAP ‹ OR PRESS BACK", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawLimit(dc, limit, top, color) {
        var label = UsageData.text(limit, "label", "Usage");
        var reset = UsageData.text(limit, "resetLabel", "reset unknown");
        var percent = UsageData.percent(limit);

        dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
        dc.drawText(72, top, Graphics.FONT_SMALL, label, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(318, top, Graphics.FONT_MEDIUM, percent.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(72, top + 26, Graphics.FONT_XTINY, reset, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Theme.TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(72, top + 48, 246, 6);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(72, top + 48, (246 * percent) / 100, 6);
    }

    private function colorForLimit(providerId, limit) {
        if (UsageData.text(limit, "id", "") == "fable") {
            return Theme.FABLE;
        }

        return providerId == "codex" ? Theme.CODEX : Theme.CLAUDE;
    }
}
