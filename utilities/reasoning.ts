import { MessageNode } from "message-nodes";

function splitReasoningHelper(message: MessageNode, openTag: string, closeTag: string): [string | undefined, string | undefined] {
  let content: string | undefined = message.content.trim();
  let reasoning: string | undefined;

  const openIndex = content.indexOf(openTag);
  const closeIndex = content.indexOf(closeTag);

  if (openIndex === -1) {
    return [content, undefined];
  }

  if (closeIndex !== -1 && closeIndex > openIndex) {
    const start = openIndex + openTag.length;

    reasoning = content.slice(start, closeIndex).trim();

    // Remove the reasoning block from content
    const before = content.slice(0, openIndex).trim();
    const after = content.slice(closeIndex + closeTag.length).trim();

    content = [before, after].filter(Boolean).join(" ").trim();

    if (content.length === 0) content = undefined;

    return [content, reasoning];
  }

  reasoning = content.slice(openIndex + openTag.length).trim();
  content = undefined;

  return [content, reasoning];
}

function splitReasoning(message: MessageNode): [string | undefined, string | undefined] {
  if (message.content.includes("<think>")) {
    return splitReasoningHelper(message, "<think>", "</think>");
  }
  else if (message.content.includes("<reasoning>")) {
    return splitReasoningHelper(message, "<reasoning>", "</reasoning>");
  }
  return [message.content, undefined];
}

export default splitReasoning;