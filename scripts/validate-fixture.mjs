import { assertValidUsage, usage } from "./usage-contract.mjs";

assertValidUsage(usage);
console.log("usage fixture valid against schema/usage.schema.json");
