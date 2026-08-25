import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const fixtureUrl = new URL("../fixtures/usage.json", import.meta.url);
const usage = JSON.parse(await readFile(fixtureUrl, "utf8"));

assert.equal(Number.isNaN(Date.parse(usage.updatedAt)), false);
assert.deepEqual(Object.keys(usage.providers).sort(), ["claude", "codex"]);

for (const [providerId, provider] of Object.entries(usage.providers)) {
  assert.equal(typeof provider.headline.label, "string", `${providerId} headline label`);
  assert.equal(typeof provider.headline.resetLabel, "string", `${providerId} headline reset`);
  assert.equal(
    provider.headline.usedPercent >= 0 && provider.headline.usedPercent <= 100,
    true,
    `${providerId} headline percent`,
  );
  assert.equal(provider.limits.length > 0, true, `${providerId} limits`);

  for (const limit of provider.limits) {
    assert.equal(typeof limit.id, "string");
    assert.equal(typeof limit.label, "string");
    assert.equal(typeof limit.resetLabel, "string");
    assert.equal(limit.usedPercent >= 0 && limit.usedPercent <= 100, true);
  }
}

assert.deepEqual(
  usage.providers.claude.limits.map(({ id }) => id),
  ["session", "all-models", "fable"],
);

console.log("usage fixture valid");
