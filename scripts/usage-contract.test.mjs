import assert from "node:assert/strict";
import test from "node:test";
import { usage, validateUsage, assertValidUsage } from "./usage-contract.mjs";

const unavailableAccount = {
  id: "claude-other", name: "Other", provider: "claude", status: "unavailable",
  updatedAt: null, headline: null, limits: [],
};

test("accepts multiple accounts of the same provider, decimals, and additional limits", () => {
  const data = structuredClone(usage);
  data.accounts[0].headline.usedPercent = 64.5;
  data.accounts[2].limits.push({ id: "another-model", label: "Another model", usedPercent: 0, resetLabel: "resets tomorrow" });
  assertValidUsage(data);
});

test("accepts no accounts and an unavailable account alongside healthy accounts", () => {
  assertValidUsage({ accounts: [] });
  const data = structuredClone(usage);
  data.accounts.push(unavailableAccount);
  assertValidUsage(data);
});

test("accepts an unavailable account with its last known usage", () => {
  const data = structuredClone(usage);
  data.accounts[0].status = "unavailable";
  assertValidUsage(data);
});

test("rejects duplicate account IDs even when their usage differs", () => {
  const data = structuredClone(usage);
  data.accounts[1].id = data.accounts[0].id;
  assert.throws(() => assertValidUsage(data), /IDs must be unique/);
});

for (const value of ["64", null, -1, 101, NaN, Infinity]) {
  test(`rejects invalid usage: ${String(value)}`, () => {
    const data = structuredClone(usage);
    data.accounts[0].headline.usedPercent = value;
    assert.equal(validateUsage(data), false);
  });
}

for (const [name, mutate] of [
  ["invalid timestamp", (data) => { data.accounts[0].updatedAt = "yesterday"; }],
  ["fractional timestamp", (data) => { data.accounts[0].updatedAt = 1.5; }],
  ["missing account name", (data) => { delete data.accounts[0].name; }],
  ["unknown provider", (data) => { data.accounts[0].provider = "other"; }],
  ["unknown status", (data) => { data.accounts[0].status = "loading"; }],
  ["empty ready limits", (data) => { data.accounts[0].limits = []; }],
  ["empty label", (data) => { data.accounts[0].headline.label = ""; }],
  ["missing reset label", (data) => { delete data.accounts[0].limits[0].resetLabel; }],
  ["unknown field", (data) => { data.accounts[0].headline.remainingPercent = 36; }],
  ["ready account without data", (data) => { data.accounts[0] = { ...unavailableAccount, status: "ready" }; }],
  ["unavailable account with an orphan timestamp", (data) => { data.accounts[0] = { ...unavailableAccount, updatedAt: 123 }; }],
]) {
  test(`rejects ${name}`, () => {
    const data = structuredClone(usage);
    mutate(data);
    assert.equal(validateUsage(data), false);
  });
}
