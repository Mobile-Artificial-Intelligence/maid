import { randomUUID } from 'expo-crypto';
import { getRoots, MessageNode } from 'message-nodes';

function validateMappings(mappings: Record<string, MessageNode<string>>): Record<string, MessageNode<string>> {
  const validMappings: Record<string, MessageNode<string>> = mappings;

  const invalidMessages = Object.values(mappings).filter(node => (!node.role || !node.content || node.role.trim().length === 0 || node.content.trim().length === 0) && node.id !== node.root);
  invalidMessages.forEach(node => {
    delete validMappings[node.id];

    if (node.child && validMappings[node.child]) {
      validMappings[node.child].parent = node.parent;
    }

    if (node.parent && validMappings[node.parent]) {
      validMappings[node.parent].child = node.child;
    }
  });

  const invalidRoots = getRoots<string>(validMappings).filter(root => validMappings[root.id].role !== "system");
  invalidRoots.forEach(root => {

    const newRoot: MessageNode<string> = {
      id: root.id,
      role: "system",
      content: "New Chat",
      root: root.id,
      child: root.child,
      metadata: {
        createTime: new Date().toISOString(),
        updateTime: new Date().toISOString(),
      }
    };

    root.id = randomUUID();
    root.parent = newRoot.id;

    validMappings[newRoot.id] = newRoot;
    validMappings[root.id] = root;
  });

  const emptyRoots = getRoots<string>(validMappings).filter(root => !root.content || root.content.trim().length === 0);
  emptyRoots.forEach(root => {
    validMappings[root.id].content = "New Chat";
  });

  const childlessRoots = getRoots<string>(validMappings).filter(root => !root.child);
  childlessRoots.forEach(root => {
    delete validMappings[root.id];
  });

  return validMappings;
}

export default validateMappings;