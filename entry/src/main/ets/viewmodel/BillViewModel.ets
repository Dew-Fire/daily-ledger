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
}

// 单例导出
export const billViewModel = new BillViewModel();
