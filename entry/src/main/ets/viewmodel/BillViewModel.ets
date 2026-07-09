import { BillDao } from '../database/BillDao';
import type { BillItem } from '../model/BillModel';
import type { MonthSummary } from '../model/BillModel';

/**
 * 账单业务逻辑层 — 连接数据库与页面
 */
class BillViewModel {
  private dao: BillDao = new BillDao();

  /**
   * 加载所有账单
   */
  async loadBills(): Promise<Array<BillItem>> {
    return await this.dao.queryAll();
  }

  /**
   * 按月份加载账单
   */
  async loadBillsByMonth(month: string): Promise<Array<BillItem>> {
    return await this.dao.queryByMonth(month);
  }

  /**
   * 新增账单
   */
  async addBill(bill: BillItem): Promise<void> {
    await this.dao.insert(bill);
  }

  /**
   * 更新账单
   */
  async updateBill(bill: BillItem): Promise<void> {
    await this.dao.update(bill);
  }

  /**
   * 删除账单
   */
  async deleteBill(billId: string): Promise<void> {
    await this.dao.delete(billId);
  }

  /**
   * 获取月度汇总
   */
  async getMonthSummary(month: string): Promise<{ income: number; expense: number }> {
    return await this.dao.getMonthSummary(month);
  }

  /**
   * 获取月度分类统计数据
   */
  async getCategoryStats(month: string): Promise<Array<{ categoryId: string; name: string; amount: number; type: number }>> {
    const bills = await this.dao.queryByMonth(month);
    const statsMap = new Map<string, { categoryId: string; name: string; amount: number; type: number }>();

    bills.forEach((b) => {
      const key = b.categoryId;
      const existing = statsMap.get(key);
      if (existing) {
        existing.amount += b.amount;
      } else {
        statsMap.set(key, {
          categoryId: b.categoryId,
          name: b.categoryName,
          amount: b.amount,
          type: b.type,
        });
      }
    });

    return Array.from(statsMap.values()).sort((a, b) => b.amount - a.amount);
  }

  /**
   * 获取近几个月收支趋势
   */
  async getMonthlyTrend(months: number = 6): Promise<Array<{ month: string; income: number; expense: number }>> {
    const allBills = await this.dao.queryAll();
    const now = new Date();
    const result: Array<{ month: string; income: number; expense: number }> = [];

    for (let i = months - 1; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const month = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      let income = 0;
      let expense = 0;

      allBills.forEach((b) => {
        if (b.date.startsWith(month)) {
          if (b.type === 1) income += b.amount;
          else expense += b.amount;
        }
      });

      result.push({ month, income, expense });
    }

    return result;
  }
}

// 单例导出
export const billViewModel = new BillViewModel();
