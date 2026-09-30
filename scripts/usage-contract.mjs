import { readFile } from "node:fs/promises";
import Ajv from "ajv/dist/2020.js";
import addFormats from "ajv-formats";

const schema = JSON.parse(await readFile(new URL("../schema/usage.schema.json", import.meta.url), "utf8"));
const ajv = new Ajv({ allErrors: true });
addFormats(ajv);

export const validateUsage = ajv.compile(schema);
export const usage = JSON.parse(await readFile(new URL("../fixtures/usage.json", import.meta.url), "utf8"));

export function assertValidUsage(value) {
  if (!validateUsage(value)) {
    throw new Error(ajv.errorsText(validateUsage.errors, { separator: "\n" }));
  }
  const ids = value.accounts.map(({ id }) => id);
  if (new Set(ids).size !== ids.length) {
    throw new Error("Account IDs must be unique");
  }
}
