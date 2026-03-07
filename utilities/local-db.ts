import * as SQLite from 'expo-sqlite';
import { MessageNode } from 'message-nodes';

let db: SQLite.SQLiteDatabase | null = null;

async function getDb(): Promise<SQLite.SQLiteDatabase> {
  if (!db) {
    db = await SQLite.openDatabaseAsync('messages.db');
    await db.execAsync(`
      PRAGMA journal_mode = WAL;
      CREATE TABLE IF NOT EXISTS messages (
        id TEXT PRIMARY KEY,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        root TEXT NOT NULL,
        parent TEXT,
        child TEXT,
        metadata TEXT
      );
      CREATE TABLE IF NOT EXISTS message_images (
        message_id TEXT NOT NULL,
        idx INTEGER NOT NULL,
        data TEXT NOT NULL,
        PRIMARY KEY (message_id, idx)
      );
    `);
  }
  return db;
}

export async function saveLocalMessages(mappings: Record<string, MessageNode<string, Record<string, any>>>): Promise<void> {
  const database = await getDb();
  const nodes = Object.values(mappings);

  await database.withTransactionAsync(async () => {
    // Remove nodes that no longer exist
    const ids = nodes.map(n => `'${n.id.replace(/'/g, "''")}'`).join(',');
    if (ids.length > 0) {
      await database.execAsync(`DELETE FROM messages WHERE id NOT IN (${ids})`);
      await database.execAsync(`DELETE FROM message_images WHERE message_id NOT IN (${ids})`);
    } else {
      await database.execAsync('DELETE FROM messages');
      await database.execAsync('DELETE FROM message_images');
    }

    for (const node of nodes) {
      const { images, ...metaWithoutImages } = node.metadata ?? {};
      const metadataJson = JSON.stringify(metaWithoutImages);

      await database.runAsync(
        `INSERT OR REPLACE INTO messages (id, role, content, root, parent, child, metadata)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [node.id, node.role, node.content, node.root, node.parent ?? null, node.child ?? null, metadataJson]
      );

      // Delete old images for this node then re-insert
      await database.runAsync('DELETE FROM message_images WHERE message_id = ?', [node.id]);
      if (Array.isArray(images)) {
        for (let i = 0; i < images.length; i++) {
          await database.runAsync(
            'INSERT INTO message_images (message_id, idx, data) VALUES (?, ?, ?)',
            [node.id, i, images[i]]
          );
        }
      }
    }
  });
}

export async function loadLocalMessages(): Promise<Record<string, MessageNode<string, Record<string, any>>>> {
  const database = await getDb();

  const rows = await database.getAllAsync<{
    id: string;
    role: string;
    content: string;
    root: string;
    parent: string | null;
    child: string | null;
    metadata: string | null;
  }>('SELECT * FROM messages');

  const imageRows = await database.getAllAsync<{
    message_id: string;
    idx: number;
    data: string;
  }>('SELECT message_id, idx, data FROM message_images ORDER BY message_id, idx');

  // Group images by message_id
  const imagesByMessage: Record<string, string[]> = {};
  for (const row of imageRows) {
    if (!imagesByMessage[row.message_id]) {
      imagesByMessage[row.message_id] = [];
    }
    imagesByMessage[row.message_id][row.idx] = row.data;
  }

  const mappings: Record<string, MessageNode<string, Record<string, any>>> = {};
  for (const row of rows) {
    const metadata = row.metadata ? JSON.parse(row.metadata) : {};
    if (imagesByMessage[row.id]?.length > 0) {
      metadata.images = imagesByMessage[row.id];
    }
    mappings[row.id] = {
      id: row.id,
      role: row.role,
      content: row.content,
      root: row.root,
      parent: row.parent ?? undefined,
      child: row.child ?? undefined,
      metadata,
    };
  }

  return mappings;
}
