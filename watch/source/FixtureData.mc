(:glance)
module FixtureData {
    function make() {
        return {
            "updatedAt" => "2026-08-24T21:32:28-05:00",
            "providers" => {
                "codex" => {
                    "headline" => {
                        "label" => "Current session",
                        "usedPercent" => 64,
                        "resetLabel" => "resets in 2h 14m"
                    },
                    "limits" => [
                        {
                            "id" => "session",
                            "label" => "Current session",
                            "usedPercent" => 64,
                            "resetLabel" => "resets in 2h 14m"
                        },
                        {
                            "id" => "weekly",
                            "label" => "Weekly",
                            "usedPercent" => 31,
                            "resetLabel" => "resets Tue 8:00 PM"
                        }
                    ]
                },
                "claude" => {
                    "headline" => {
                        "label" => "Current session",
                        "usedPercent" => 38,
                        "resetLabel" => "resets in 7m"
                    },
                    "limits" => [
                        {
                            "id" => "session",
                            "label" => "Current session",
                            "usedPercent" => 38,
                            "resetLabel" => "resets in 7m"
                        },
                        {
                            "id" => "all-models",
                            "label" => "All models",
                            "usedPercent" => 72,
                            "resetLabel" => "resets Wed 1:59 PM"
                        },
                        {
                            "id" => "fable",
                            "label" => "Fable",
                            "usedPercent" => 26,
                            "resetLabel" => "resets Wed 1:59 PM"
                        }
                    ]
                }
            }
        };
    }
}
