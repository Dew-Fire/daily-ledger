import { relationalStore } from '@kit.ArkData';

const DB_NAME = 'daily_ledger.db';
const DB_VERSION = 1;

// 账单表
const CREATE_BILLS_TABLE = `
  CREATE TABLE IF NOT EXISTS bills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    type INTEGER NOT NULL,
    category_id TEXT NOT NULL,
    category_name TEXT NOT NULL,
    note TEXT DEFAULT '',
    date TEXT NOT NULL,
    created_at INTEGER NOT NULL
  )
`;

// 自定义分类表
const CREATE_CATEGORIES_TABLE = `
  CREATE TABLE IF NOT EXISTS categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_key TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    type INTEGER NOT NULL,
    parent_id TEXT NOT NULL,
    is_custom INTEGER DEFAULT 1,
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL
  )
`;

// 预算表
const CREATE_BUDGET_TABLE = `
  CREATE TABLE IF NOT EXISTS budgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    month TEXT NOT NULL UNIQUE,
    amount REAL NOT NULL,
    created_at INTEGER NOT NULL
  )
`;

let rdbStore: relationalStore.RdbStore | null = null;

/**
 * 初始化数据库
 */
export async function initDatabase(context: Context): Promise<relationalStore.RdbStore> {
  if (rdbStore) {
    return rdbStore;
  }

  const config: relationalStore.StoreConfig = {
    name: DB_NAME,
    securityLevel: relationalStore.SecurityLevel.S1,
  };

  rdbStore = await relationalStore.getRdbStore(context, config);

  // 建表
  await rdbStore.executeSql(CREATE_BILLS_TABLE);
  await rdbStore.executeSql(CREATE_CATEGORIES_TABLE);
  await rdbStore.executeSql(CREATE_BUDGET_TABLE);

  return rdbStore;
}

/**
 * 获取数据库实例（使用前确保已初始化）
 */
export function getRdbStore(): relationalStore.RdbStore {
  if (!rdbStore) {
    throw new Error('Database not initialized. Call initDatabase() first.');
  }
  return rdbStore;
}

/**
 * 关闭数据库
 */
export async function closeDatabase(): Promise<void> {
  if (rdbStore) {
    await rdbStore.close();
    rdbStore = null;
  }
}
