// Generated from fixtures/usage.json by pnpm fixture:generate.
(:glance)
module FixtureData {
    function make() {
        return {
            "accounts" => [
                {
                    "id" => "codex-work",
                    "name" => "Work",
                    "provider" => "codex",
                    "status" => "ready",
                    "updatedAt" => 1790787600,
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
                {
                    "id" => "codex-personal",
                    "name" => "Personal",
                    "provider" => "codex",
                    "status" => "ready",
                    "updatedAt" => 1790787600,
                    "headline" => {
                        "label" => "Current session",
                        "usedPercent" => 19,
                        "resetLabel" => "resets in 45m"
                    },
                    "limits" => [
                        {
                            "id" => "session",
                            "label" => "Current session",
                            "usedPercent" => 19,
                            "resetLabel" => "resets in 45m"
                        },
                        {
                            "id" => "weekly",
                            "label" => "Weekly",
                            "usedPercent" => 31,
                            "resetLabel" => "resets Tue 8:00 PM"
                        }
                    ]
                },
                {
                    "id" => "claude-work",
                    "name" => "Work",
                    "provider" => "claude",
                    "status" => "ready",
                    "updatedAt" => 1790787600,
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
                },
                {
                    "id" => "claude-personal",
                    "name" => "Personal",
                    "provider" => "claude",
                    "status" => "ready",
                    "updatedAt" => 1790787600,
                    "headline" => {
                        "label" => "Current session",
                        "usedPercent" => 81,
                        "resetLabel" => "resets in 1h 20m"
                    },
                    "limits" => [
                        {
                            "id" => "session",
                            "label" => "Current session",
                            "usedPercent" => 81,
                            "resetLabel" => "resets in 1h 20m"
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
            ]
        };
    }
}
