import Toybox.Test;

(:test)
function acceptsAccountsAndDecimalUsage(logger) {
    var data = FixtureData.make();
    Test.assert(UsageData.isValid(data));
    data["accounts"][0]["headline"]["usedPercent"] = 64.5;
    Test.assert(UsageData.isValid(data));
    Test.assertEqual(UsageData.percent(data["accounts"][0]["headline"]), 64);
    Test.assertEqual(UsageData.percentText(null), "--");
    return true;
}

(:test)
function rejectsMalformedUsage(logger) {
    var values = [null, "64", -1, 101];
    for (var index = 0; index < values.size(); index += 1) {
        var data = FixtureData.make();
        data["accounts"][0]["headline"]["usedPercent"] = values[index];
        Test.assert(!UsageData.isValid(data));
    }
    return true;
}

(:test)
function rejectsDuplicateIdsAndInvalidMetadata(logger) {
    var data = FixtureData.make();
    data["accounts"][1]["id"] = data["accounts"][0]["id"];
    Test.assert(!UsageData.isValid(data));
    data = FixtureData.make();
    data["accounts"][0]["provider"] = "other";
    Test.assert(!UsageData.isValid(data));
    data = FixtureData.make();
    data["accounts"][0]["updatedAt"] = "yesterday";
    Test.assert(!UsageData.isValid(data));
    return true;
}

(:test)
function preservesUnavailableAccountCacheWithoutHidingHealthyAccounts(logger) {
    var saved = FixtureData.make();
    var data = FixtureData.make();
    var row = data["accounts"][0];
    row["status"] = "unavailable";
    row["updatedAt"] = null;
    row["headline"] = null;
    row["limits"] = [];
    data["accounts"][1]["headline"]["usedPercent"] = 27;
    Test.assert(UsageData.isValid(data));
    var merged = UsageData.merge(data, saved);
    Test.assert(UsageData.isValid(merged));
    Test.assertEqual(merged["accounts"][0]["status"], "unavailable");
    Test.assertEqual(merged["accounts"][0]["updatedAt"], saved["accounts"][0]["updatedAt"]);
    Test.assertEqual(UsageData.percent(merged["accounts"][0]["headline"]), 64);
    Test.assertEqual(UsageData.percent(merged["accounts"][1]["headline"]), 27);
    return true;
}

(:test)
function doesNotRestoreRemovedAccountsOrBorrowOtherAccountUsage(logger) {
    var saved = FixtureData.make();
    Test.assertEqual(UsageData.accounts(UsageData.merge({"accounts" => []}, saved)).size(), 0);
    var data = {"accounts" => [{"id" => "new", "name" => "New", "provider" => "codex", "status" => "unavailable", "updatedAt" => null, "headline" => null, "limits" => []}]};
    var merged = UsageData.merge(data, saved);
    Test.assert(UsageData.isValid(merged));
    Test.assertEqual(UsageData.headline(merged["accounts"][0]), null);
    Test.assertEqual(UsageData.account(saved, "codex-personal")["name"], "Personal");
    data["accounts"][0]["id"] = "codex-work";
    data["accounts"][0]["provider"] = "claude";
    Test.assertEqual(UsageData.headline(UsageData.merge(data, saved)["accounts"][0]), null);
    return true;
}

(:test)
function formatsPerAccountAgeAndHandlesFutureClockSkew(logger) {
    var account = FixtureData.make()["accounts"][0];
    account["updatedAt"] = 1000;
    Test.assertEqual(UsageData.ageLabel(account, 1120), "2m ago");
    Test.assertEqual(UsageData.ageLabel(account, 8200), "2h ago");
    Test.assertEqual(UsageData.ageLabel(account, 173800), "2d ago");
    Test.assertEqual(UsageData.ageLabel(account, 900), "just now");
    return true;
}
