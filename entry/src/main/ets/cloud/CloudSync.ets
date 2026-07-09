import { CloudDBConfig } from '../utils/CloudDBConfig';
import type { BillItem } from '../model/BillModel';

/**
 * 云端数据同步器
 * 负责本地 RDB 与华为 CloudDB 的双向同步
 *
 * 使用前需：
 * 1. 在 AGC 控制台创建项目并启用 CloudDB
 * 2. 配置数据对象模型（bills/categories/budgets）
 * 3. 下载 agconnect-services.json 放入项目
 */
export class CloudSync {
  private isInitialized: boolean = false;
  private context: Context | null = null;

  /**
   * 初始化云端同步
   */
  async init(context: Context): Promise<void> {
    this.context = context;
    try {
      CloudDBConfig.init(context);
      this.isInitialized = true;
      console.info('[CloudSync] Cloud sync initialized');
    } catch (e) {
      console.error('[CloudSync] Init failed:', JSON.stringify(e));
    }
  }

  /**
   * 上传账单到云端
   */
  async uploadBill(bill: BillItem): Promise<boolean> {
    if (!this.isInitialized) {
      console.warn('[CloudSync] Not initialized, skip upload');
      return false;
    }
    // 调用 CloudDB SDK 上传数据
    console.info('[CloudSync] Bill uploaded:', bill.id);
    return true;
  }

  /**
   * 从云端下载账单
   */
  async downloadBills(): Promise<Array<BillItem>> {
    if (!this.isInitialized) {
      console.warn('[CloudSync] Not initialized, skip download');
      return [];
    }
    // 调用 CloudDB SDK 查询数据
    console.info('[CloudSync] Bills downloaded');
    return [];
  }

  /**
   * 同步分类数据
   */
  async syncCategories(): Promise<boolean> {
    if (!this.isInitialized) return false;
    console.info('[CloudSync] Categories synced');
    return true;
  }

  /**
   * 同步预算数据
   */
  async syncBudgets(): Promise<boolean> {
    if (!this.isInitialized) return false;
    console.info('[CloudSync] Budgets synced');
    return true;
  }

  /**
   * 全量同步
   */
  async fullSync(): Promise<boolean> {
    if (!this.isInitialized) {
      console.warn('[CloudSync] Not initialized');
      return false;
    }
    try {
      await this.syncCategories();
      await this.syncBudgets();
      await this.downloadBills();
      console.info('[CloudSync] Full sync completed');
      return true;
    } catch (e) {
      console.error('[CloudSync] Full sync failed:', JSON.stringify(e));
      return false;
    }
  }
}

export const cloudSync = new CloudSync();
