import Toybox.Lang;

(:glance)
module UsageData {
    function isValid(data) {
        if (!(data instanceof Lang.Dictionary) || !(data["accounts"] instanceof Lang.Array)) {
            return false;
        }
        var rows = data["accounts"];
        var ids = {};
        for (var index = 0; index < rows.size(); index += 1) {
            var account = rows[index];
            var id = text(account, "id", "");
            var provider = text(account, "provider", "");
            var status = text(account, "status", "");
            if (id.length() == 0 || ids.hasKey(id) || text(account, "name", "").length() == 0
                || (!provider.equals("codex") && !provider.equals("claude"))
                || (!status.equals("ready") && !status.equals("unavailable"))) {
                return false;
            }
            ids[id] = true;
            if (!(account["limits"] instanceof Lang.Array) || !account.hasKey("headline") || !account.hasKey("updatedAt")) {
                return false;
            }
            var limits = account["limits"];
            if (account["headline"] == null) {
                if (!status.equals("unavailable") || account["updatedAt"] != null || limits.size() != 0) {
                    return false;
                }
                continue;
            }
            var timestamp = account["updatedAt"];
            if (!(timestamp instanceof Lang.Number || timestamp instanceof Lang.Long) || timestamp < 0
                || !isValidLimit(account["headline"], false) || limits.size() == 0) {
                return false;
            }
            for (var row = 0; row < limits.size(); row += 1) {
                if (!isValidLimit(limits[row], true)) {
                    return false;
                }
            }
        }
        return true;
    }

    function isValidLimit(limit, requireId) {
        if (!(limit instanceof Lang.Dictionary)) {
            return false;
        }
        var value = limit["usedPercent"];
        return isNumeric(value) && value >= 0 && value <= 100
            && text(limit, "label", "").length() > 0
            && text(limit, "resetLabel", "").length() > 0
            && (!requireId || text(limit, "id", "").length() > 0);
    }

    function isNumeric(value) {
        return value instanceof Lang.Number || value instanceof Lang.Float
            || value instanceof Lang.Double || value instanceof Lang.Long;
    }

    function accounts(data) {
        if (!(data instanceof Lang.Dictionary)) {
            return [];
        }
        var value = data["accounts"];
        return value instanceof Lang.Array ? value : [];
    }

    function account(data, id) {
        var rows = accounts(data);
        for (var index = 0; index < rows.size(); index += 1) {
            if (text(rows[index], "id", "").equals(id)) {
                return rows[index];
            }
        }
        return null;
    }

    function headline(account) {
        if (!(account instanceof Lang.Dictionary)) {
            return null;
        }
        var value = account["headline"];
        return value instanceof Lang.Dictionary ? value : null;
    }

    function limits(account) {
        if (!(account instanceof Lang.Dictionary)) {
            return [];
        }
        var value = account["limits"];
        return value instanceof Lang.Array ? value : [];
    }

    function merge(data, cached) {
        var rows = accounts(data);
        for (var index = 0; index < rows.size(); index += 1) {
            var row = rows[index];
            var saved = account(cached, row["id"]);
            if (row["status"].equals("unavailable") && headline(row) == null
                && saved != null && saved["provider"].equals(row["provider"]) && headline(saved) != null) {
                row["headline"] = saved["headline"];
                row["limits"] = saved["limits"];
                row["updatedAt"] = saved["updatedAt"];
            }
        }
        return data;
    }

    function percent(limit) {
        if (!(limit instanceof Lang.Dictionary)) {
            return null;
        }
        var value = limit["usedPercent"];
        if (!isNumeric(value) || !(value >= 0 && value <= 100)) {
            return null;
        }
        return value.toNumber();
    }

    function percentText(limit) {
        var value = percent(limit);
        return value == null ? "--" : value.format("%d") + "%";
    }

    function ageLabel(account, now) {
        if (!(account instanceof Lang.Dictionary) || account["updatedAt"] == null) {
            return "age unknown";
        }
        var minutes = ((now - account["updatedAt"]) / 60).toNumber();
        if (minutes < 1) {
            return "just now";
        }
        if (minutes < 60) {
            return minutes.format("%d") + "m ago";
        }
        if (minutes < 1440) {
            return (minutes / 60).toNumber().format("%d") + "h ago";
        }
        return (minutes / 1440).toNumber().format("%d") + "d ago";
    }

    function text(value, key, fallback) {
        if (!(value instanceof Lang.Dictionary)) {
            return fallback;
        }
        var result = value[key];
        return result instanceof Lang.String ? result : fallback;
    }
}
