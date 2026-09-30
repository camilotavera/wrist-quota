import assert from "node:assert/strict";
import { readFile, writeFile } from "node:fs/promises";
import { assertValidUsage, usage } from "./usage-contract.mjs";

assertValidUsage(usage);

function toMonkeyC(value, depth = 2) {
  const indent = "    ".repeat(depth);
  const childIndent = "    ".repeat(depth + 1);
  if (Array.isArray(value)) {
    return `[\n${value.map((item) => childIndent + toMonkeyC(item, depth + 1)).join(",\n")}\n${indent}]`;
  }
  if (value !== null && typeof value === "object") {
    const entries = Object.entries(value).map(([key, item]) => `${childIndent}${JSON.stringify(key)} => ${toMonkeyC(item, depth + 1)}`);
    return `{\n${entries.join(",\n")}\n${indent}}`;
  }
  return JSON.stringify(value);
}

const source = `// Generated from fixtures/usage.json by pnpm fixture:generate.\n(:glance)\nmodule FixtureData {\n    function make() {\n        return ${toMonkeyC(usage)};\n    }\n}\n`;
const target = new URL("../watch/source/FixtureData.mc", import.meta.url);

if (process.argv.includes("--check")) {
  assert.equal(await readFile(target, "utf8"), source, "Demo data is out of sync. Run pnpm fixture:generate.");
} else {
  await writeFile(target, source);
}
