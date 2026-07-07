/**
 * 账单数据模型
 */

// 账单记录
export interface BillItem {
  id: string;
  amount: number;
  type: number;         // 0: 支出, 1: 收入
  categoryId: string;   // 二级分类 ID
  categoryName: string; // 分类显示名（如 "餐饮·午餐"）
  note: string;
  date: string;         // yyyy-MM-dd
}

// 月度收支统计
export interface MonthSummary {
  month: string;         // yyyy-MM
  totalIncome: number;
  totalExpense: number;
  balance: number;
}

// 分类统计项
export interface CategoryStat {
  categoryId: string;
  categoryName: string;
  amount: number;
  percentage: number;
}
