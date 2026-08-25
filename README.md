# AI Usage for Garmin

A private Connect IQ watch app for viewing Codex and Claude usage on a Garmin vívoactive 5.

## Current scope

- Dual-ring overview for the providers' current usage windows.
- Tap either provider to inspect every limit returned by the service.
- HTTPS JSON client through Garmin Connect Mobile.
- Demo mode with screenshot-shaped Claude data.
- Glance summary backed by the last successful response.

The watch never receives OpenAI or Anthropic credentials. It only receives normalized usage data from a private endpoint.

## Data contract

See `fixtures/usage.json`. The detail view renders up to three limits per provider in response order, so model-specific limits such as Fable do not require watch releases.

Validate the fixture contract with `pnpm test`.

## Run

1. Install Garmin Connect IQ SDK Manager and an SDK with the vívoactive 5 device definition.
2. Generate a Garmin developer key.
3. From `watch/`, build for `vivoactive5`:

   ```sh
   monkeyc -d vivoactive5 -f monkey.jungle -o bin/ai-usage.prg -y /path/to/developer_key.der
   ```

4. Start the simulator with `connectiq`, then run:

   ```sh
   monkeydo bin/ai-usage.prg vivoactive5
   ```

Demo mode is enabled by default. Disable it and set the HTTPS endpoint plus access token from the app settings when the collector endpoint is ready.
