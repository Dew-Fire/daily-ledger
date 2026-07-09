import { BudgetDao } from '../database/BudgetDao';
import { NotificationHelper } from './NotificationHelper';

/**
 * 预算检查器 — 启动时检测预算使用率并推送通知
 */
export class BudgetChecker {
  private budgetDao: BudgetDao = new BudgetDao();

  /**
   * 检查当月预算并发送通知
   */
  async checkAndNotify(): Promise<void> {
    const now = new Date();
    const month = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;

    try {
      const status = await this.budgetDao.getBudgetStatus(month);
      if (status.budget > 0 && (status.expense / status.budget) >= 0.8) {
        await NotificationHelper.sendBudgetAlert(status.budget, status.expense, month);
      }
    } catch (e) {
      console.error('Budget check failed:', JSON.stringify(e));
    }
  }
}
