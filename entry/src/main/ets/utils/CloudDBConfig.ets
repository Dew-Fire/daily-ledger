/**
 * CloudDB 云数据库配置
 * 华为 AGC 云端数据同步
 */
export class CloudDBConfig {
  // CloudDB zone name
  static readonly ZONE_NAME: string = 'daily_ledger';

  // 对象类型名称（对应 AGC 平台上定义的对象存储模型）
  static readonly BILL_OBJECT: string = 'bill';
  static readonly CATEGORY_OBJECT: string = 'category';
  static readonly BUDGET_OBJECT: string = 'budget';

  /**
   * 初始化 CloudDB（登录 AGC 后调用）
   */
  static init(context: Context): void {
    // CloudDB 初始化代码框架
    // 正式环境需在 AGC 控制台配置 CloudDB zone
    // 并下载 agconnect-services.json 配置文件
    console.info('[CloudDB] Cloud database config initialized');
    console.info('[CloudDB] Zone: ' + this.ZONE_NAME);
    console.info('[CloudDB] Objects: ' + [this.BILL_OBJECT, this.CATEGORY_OBJECT, this.BUDGET_OBJECT].join(', '));
  }
}

/**
 * CloudDB 数据模型定义
 */

// 账单对象（映射到 CloudDB bill 表）
export interface CloudBill {
  id?: number;
  amount: number;
  type: number;
  categoryId: string;
  categoryName: string;
  note: string;
  date: string;
  createdAt: number;
  userId?: string;
}

// 分类对象（映射到 CloudDB category 表）
export interface CloudCategory {
  id?: number;
  categoryKey: string;
  name: string;
  icon: string;
  type: number;
  parentId: string;
  isCustom: number;
  sortOrder: number;
  createdAt: number;
}

// 预算对象（映射到 CloudDB budget 表）
export interface CloudBudget {
  id?: number;
  month: string;
  amount: number;
  createdAt: number;
}

// 云函数名称
export const CLOUD_FUNCTIONS = {
  GET_MONTH_STATS: 'getMonthStats',
  SYNC_BILLS: 'syncBills',
  CALCULATE_BUDGET: 'calculateBudget',
};
