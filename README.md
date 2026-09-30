# AI Usage for Garmin

A private Connect IQ watch app for viewing multiple Codex and Claude accounts on a Garmin vívoactive 5.

## Watch behavior

- Four accounts per overview page, with separate usage percentages and reset labels.
- Tap an account to inspect its limits. Swipe up/left for the next page and down/right for the previous page. Details show three limits per page; none are silently discarded.
- Tap the footer to refresh. Press Back or tap ‹ to return to the account list.
- Saved live data appears immediately on launch. Request failures preserve it and show saved-data labels. An unavailable account can retain its own cached usage while healthy accounts update.
- The glance shows the last selected live account, falling back to the first account, and labels its values as saved. Demo mode never overwrites live data or the live-account selection.
- Drawing is event-driven. There is no polling timer or animated loading indicator.

The watch receives normalized usage from one private HTTPS endpoint through Garmin Connect Mobile. Provider credentials and per-account collection belong to the collector, which is not implemented in this repository.

## Data contract

See `fixtures/usage.json` and `schema/usage.schema.json`. The response contains an `accounts` array. This replaces the earlier provider-only draft; old cached responses are ignored.

Each account has:

- `id`: a stable, unique identifier. Keep it consistent between responses so cached values and selection remain associated with the correct account.
- `name`: a short display name such as Work or Personal.
- `provider`: `codex` or `claude`.
- `status`: `ready` or `unavailable`.
- `updatedAt`: UTC Unix epoch seconds for that account's last successful collection.
- `headline` and `limits`: usage consumed (0–100) and collector-provided reset labels. Decimal usage is displayed as a whole number rounded toward zero.

For an account with no available data, use `status: "unavailable"`, `updatedAt: null`, `headline: null`, and `limits: []`. An unavailable account may also include its last known usage and timestamp. The watch can restore cached values for the same account ID and provider. Accounts omitted from a response are removed; `accounts: []` represents an empty account list. A malformed account rejects the response, leaving the previous cache intact.

Saved reset labels are observations from the last collection, not a live countdown. Account age is recalculated when the screen redraws; demo values and names are illustrative.

Install dependencies with `pnpm install`. Run `pnpm test` to validate the schema, malformed payload cases, unique account IDs, and demo synchronization. After editing `fixtures/usage.json`, run `pnpm fixture:generate` to regenerate the watch demo data.

## Run

1. Install Garmin Connect IQ SDK Manager and an SDK with the vívoactive 5 device definition.
2. Generate a Garmin developer key.
3. From `watch/`, build for `vivoactive5`:

   ```sh
   mkdir -p bin
   monkeyc -d vivoactive5 -f monkey.jungle -o bin/ai-usage.prg -y /path/to/developer_key.der
   ```

4. Start the simulator with `connectiq`, then run:

   ```sh
   monkeydo bin/ai-usage.prg vivoactive5
   ```

Demo mode is enabled by default. Disable it and configure the HTTPS endpoint and access token in the app settings when the collector is ready. Overlapping requests are ignored while a fetch is pending.

To run native payload/cache tests, compile with `monkeyc -t` using the same build arguments, then run `monkeydo bin/ai-usage.prg vivoactive5 -t` with the simulator open.
