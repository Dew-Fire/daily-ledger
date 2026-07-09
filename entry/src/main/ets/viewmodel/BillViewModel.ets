import { BillDao } from '../database/BillDao';
import type { BillItem } from '../model/BillModel';

// 月度汇总结果
interface MonthSummaryResult {
  income: number;
  expense: number;
}

// 分类统计项
export interface CategoryStatItem {
  categoryId: string;
  name: string;
  amount: number;
  type: number;
}

// 月度趋势项
export interface MonthTrendItem {
  month: string;
  income: number;
  expense: number;
}

/**
 * 账单业务逻辑层 — 连接数据库与页面
 */
class BillViewModel {
  private dao: BillDao = new BillDao();

  async loadBills(): Promise<Array<BillItem>> {
    return await this.dao.queryAll();
  }

  async loadBillsByMonth(month: string): Promise<Array<BillItem>> {
    return await this.dao.queryByMonth(month);
  }

  async addBill(bill: BillItem): Promise<void> {
    await this.dao.insert(bill);
  }

  async updateBill(bill: BillItem): Promise<void> {
    await this.dao.update(bill);
  }

  async deleteBill(billId: string): Promise<void> {
    await this.dao.delete(billId);
  }

  async getMonthSummary(month: string): Promise<MonthSummaryResult> {
    return await this.dao.getMonthSummary(month);
  }

  async getCategoryStats(month: string): Promise<Array<CategoryStatItem>> {
    const bills = await this.dao.queryByMonth(month);
    const statsMap = new Map<string, CategoryStatItem>();

    bills.forEach((b: BillItem) => {
      const key = b.categoryId;
      const existing = statsMap.get(key);
      if (existing) {
        existing.amount += b.amount;
      } else {
        const item: CategoryStatItem = {
          categoryId: b.categoryId,
          name: b.categoryName,
          amount: b.amount,
          type: b.type,
        };
        statsMap.set(key, item);
      }
    });

    return Array.from(statsMap.values()).sort((a: CategoryStatItem, b: CategoryStatItem) => b.amount - a.amount);
  }

  async getMonthlyTrend(months: number = 6): Promise<Array<MonthTrendItem>> {
    const allBills = await this.dao.queryAll();
    const now = new Date();
    const result: Array<MonthTrendItem> = [];

    for (let i = months - 1; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const month = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      let income = 0;
      let expense = 0;

      allBills.forEach((b: BillItem) => {
        if (b.date.startsWith(month)) {
          if (b.type === 1) income += b.amount;
          else expense += b.amount;
        }
      });

      const item: MonthTrendItem = { month, income, expense };
      result.push(item);
    }

    return result;
  }
}

export const billViewModel = new BillViewModel();
