import Toybox.Application;
import Toybox.Test;

(:test)
function pagesThroughAccountPairsAndClampsAfterAccountRemoval(logger) {
    var data = FixtureData.make();
    data["accounts"].add({"id" => "fifth", "name" => "Other", "provider" => "codex", "status" => "unavailable", "updatedAt" => null, "headline" => null, "limits" => []});
    var view = new AiUsageView();
    view.onUsage(data, null);
    Test.assert(!view.changePage(-1));
    Test.assert(!view.showAccount(-1));
    Test.assert(!view.showAccount(2));
    Test.assert(view.changePage(1));
    Test.assert(view.showAccount(0));
    Test.assertEqual(Application.Storage.getValue("selectedAccountId"), "claude-work");
    Test.assert(!view.isOverview());
    view.showOverview();
    Test.assert(view.changePage(1));
    Test.assert(view.showAccount(0));
    Test.assertEqual(Application.Storage.getValue("selectedAccountId"), "fifth");
    view.showOverview();
    Test.assert(!view.showAccount(1));
    Test.assert(!view.changePage(1));
    view.onUsage({"accounts" => [data["accounts"][0], data["accounts"][1]]}, null);
    Test.assert(!view.changePage(-1));
    Test.assert(view.showAccount(1));
    Test.assertEqual(Application.Storage.getValue("selectedAccountId"), "codex-personal");
    return true;
}
