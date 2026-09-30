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
        var demo = Application.Properties.getValue("demoMode") == true;
        var data = demo ? FixtureData.make() : Application.Storage.getValue("usage");
        var rows = UsageData.accounts(data);
        var selected = UsageData.account(data, Application.Storage.getValue("selectedAccountId"));
        if (selected == null && rows.size() > 0) {
            selected = rows[0];
        }
        var title = selected == null ? "AI USAGE" : UsageData.text(selected, "provider", "") + " " + UsageData.text(selected, "name", "");
        while (title.length() > 0 && dc.getTextWidthInPixels(title, Graphics.FONT_XTINY) > dc.getWidth() - 12) {
            title = title.substring(0, title.length() - 1);
        }
        dc.drawText(6, 4, Graphics.FONT_XTINY, title, Graphics.TEXT_JUSTIFY_LEFT);
        var valueY = dc.getHeight() - dc.getFontHeight(Graphics.FONT_SMALL) - 4;
        dc.setColor(selected != null && selected["provider"] == "claude" ? Theme.CLAUDE : Theme.CODEX, Graphics.COLOR_TRANSPARENT);
        dc.drawText(6, valueY, Graphics.FONT_SMALL, UsageData.percentText(UsageData.headline(selected)), Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Theme.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() - 6, valueY + 5, Graphics.FONT_XTINY, demo ? "DEMO" : (selected == null ? "NO DATA" : "SAVED"), Graphics.TEXT_JUSTIFY_RIGHT);
    }
}
