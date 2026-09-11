import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  if (process.env.OPENAI_BASE_URL) {
    pi.registerProvider("openai", {
      baseUrl: process.env.OPENAI_BASE_URL,
    });
  }

  if (process.env.ANTHROPIC_BASE_URL) {
    pi.registerProvider("anthropic", {
      baseUrl: process.env.ANTHROPIC_BASE_URL,
    });
  }
}
