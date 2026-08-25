import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

(:glance)
class AiUsageGlanceView extends WatchUi.GlanceView {
    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc) {
        dc.setColor(Theme.FOREGROUND, Theme.BACKGROUND);
        dc.clear();

        var data = Application.Storage.getValue("usage");
        var codex = UsageData.headline(UsageData.provider(data, "codex"));
        var claude = UsageData.headline(UsageData.provider(data, "claude"));

        dc.setColor(Theme.FOREGROUND, Graphics.COLOR_TRANSPARENT);
        dc.drawText(6, 4, Graphics.FONT_XTINY, "AI USAGE", Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Theme.CODEX, Graphics.COLOR_TRANSPARENT);
        dc.drawText(6, dc.getHeight() - 21, Graphics.FONT_SMALL, "C " + UsageData.percent(codex).format("%d") + "%", Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Theme.CLAUDE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() - 6, dc.getHeight() - 21, Graphics.FONT_SMALL, "CL " + UsageData.percent(claude).format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);
    }
}
