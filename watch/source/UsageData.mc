import Toybox.Lang;

(:glance)
module UsageData {
    function provider(data, providerId) {
        if (!(data instanceof Lang.Dictionary)) {
            return null;
        }

        var providers = data["providers"];
        if (!(providers instanceof Lang.Dictionary)) {
            return null;
        }

        var value = providers[providerId];
        return value instanceof Lang.Dictionary ? value : null;
    }

    function headline(provider) {
        if (!(provider instanceof Lang.Dictionary)) {
            return null;
        }

        var value = provider["headline"];
        return value instanceof Lang.Dictionary ? value : null;
    }

    function limits(provider) {
        if (!(provider instanceof Lang.Dictionary)) {
            return [];
        }

        var value = provider["limits"];
        return value instanceof Lang.Array ? value : [];
    }

    function percent(limit) {
        if (!(limit instanceof Lang.Dictionary)) {
            return 0;
        }

        var value = limit["usedPercent"];
        if (!(value instanceof Lang.Number)) {
            return 0;
        }

        if (value < 0) {
            return 0;
        }

        if (value > 100) {
            return 100;
        }

        return value;
    }

    function text(limit, key, fallback) {
        if (!(limit instanceof Lang.Dictionary)) {
            return fallback;
        }

        var value = limit[key];
        return value instanceof Lang.String ? value : fallback;
    }
}
