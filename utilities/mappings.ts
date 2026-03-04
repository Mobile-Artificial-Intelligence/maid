import { randomUUID } from 'expo-crypto';
import { getRoots, MessageNode } from 'message-nodes';

export interface TextPart {
  type: "text";
  text: string;
};

export interface ImagePart {
  type: 'image_url';
  image_url: string;
};

export type StandardMessageContent = string | Array<TextPart | ImagePart>;

export type StandardMessageNode = MessageNode<StandardMessageContent, Record<string, any>>;

function messageEmpty(node: StandardMessageNode): boolean {
  if (typeof node.content === "string") {
    return node.content.trim().length === 0;
  } 
  else if (Array.isArray(node.content)) {
    return node.content.every(part => {
      if (part.type === "text") {
        return part.text.trim().length === 0;
      } else if (part.type === "image_url") {
        return part.image_url.trim().length === 0;
      }
      return true;
    });
  }
  return true;
};

export function simplifyMessages(messages: Array<StandardMessageNode>): Array<MessageNode<string, Record<string, any>>> {
  return messages.map(node => {
    if (Array.isArray(node.content)) {
      const textContent = node.content
        .filter(part => part.type === "text")
        .map(part => part.text.trim())
        .join('\n\n');

      return {
        ...node,
        content: textContent,
      };
    }
    return node;
  }) as Array<MessageNode<string, Record<string, any>>>;
};

export function validateMappings(mappings: Record<string, StandardMessageNode>): Record<string, StandardMessageNode> {
  const validMappings: Record<string, StandardMessageNode> = mappings;

  const invalidMessages = Object.values(mappings).filter(node => (!node.role || !node.content || node.role.trim().length === 0 || messageEmpty(node)) && node.id !== node.root);
  invalidMessages.forEach(node => {
    delete validMappings[node.id];

    if (node.child && validMappings[node.child]) {
      validMappings[node.child].parent = node.parent;
    }

    if (node.parent && validMappings[node.parent]) {
      validMappings[node.parent].child = node.child;
    }
  });

  const invalidRoots = getRoots<StandardMessageContent>(validMappings).filter(root => validMappings[root.id].role !== "system");
  invalidRoots.forEach(root => {

    const newRoot: StandardMessageNode = {
      id: root.id,
      role: "system",
      content: "You are a helpful assistant.",
      root: root.id,
      child: root.child,
      metadata: {
        title: "New Chat",
        createTime: new Date().toISOString(),
        updateTime: new Date().toISOString(),
      }
    };

    root.id = randomUUID();
    root.parent = newRoot.id;

    validMappings[newRoot.id] = newRoot;
    validMappings[root.id] = root;
  });

  const emptyRoots = getRoots<StandardMessageContent>(validMappings).filter(root => !root.content || messageEmpty(root));
  emptyRoots.forEach(root => {
    validMappings[root.id].content = "You are a helpful assistant.";
  });

  const childlessRoots = getRoots<StandardMessageContent>(validMappings).filter(root => !root.child);
  childlessRoots.forEach(root => {
    delete validMappings[root.id];
  });

  return validMappings;
}