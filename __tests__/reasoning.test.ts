import type { MessageNode } from "message-nodes";
import splitReasoning from "../utilities/reasoning";

function message(content: string): MessageNode {
  return { content } as MessageNode;
}

describe("splitReasoning", () => {
  it("keeps the answer when a close tag appears before the think block", () => {
    const [content, reasoning] = splitReasoning(
      message("see </think> then <think>secret</think> done"),
    );

    expect(reasoning).toBe("secret");
    expect(content).toBe("see </think> then done");
  });

  it("keeps the answer when a close tag appears before the reasoning block", () => {
    const [content, reasoning] = splitReasoning(
      message("see </reasoning> then <reasoning>secret</reasoning> done"),
    );

    expect(reasoning).toBe("secret");
    expect(content).toBe("see </reasoning> then done");
  });

  it("splits a think block that starts the message", () => {
    const [content, reasoning] = splitReasoning(message("<think>secret</think> done"));

    expect(reasoning).toBe("secret");
    expect(content).toBe("done");
  });

  it("leaves an unclosed think block as reasoning", () => {
    const [content, reasoning] = splitReasoning(message("<think>secret"));

    expect(reasoning).toBe("secret");
    expect(content).toBeUndefined();
  });
});
