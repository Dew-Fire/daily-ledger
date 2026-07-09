import { relationalStore } from '@kit.ArkData';
import { getRdbStore } from './DatabaseHelper';

/**
 * 预算数据访问对象
 */
export class BudgetDao {
  private getStore(): relationalStore.RdbStore {
    return getRdbStore();
  }

  /**
   * 设置月度预算（插入或更新）
   */
  async setBudget(month: string, amount: number): Promise<void> {
    const store = this.getStore();
    const existing = await this.getBudget(month);

    if (existing !== null) {
      const valueBucket: relationalStore.ValuesBucket = { amount };
      const predicates = new relationalStore.RdbPredicates('budgets');
      predicates.equalTo('month', month);
      await store.update(valueBucket, predicates);
    } else {
      const valueBucket: relationalStore.ValuesBucket = {
        month,
        amount,
        created_at: Date.now(),
      };
      await store.insert('budgets', valueBucket);
    }
  }

  /**
   * 获取月度预算
   */
  async getBudget(month: string): Promise<number | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('budgets');
    predicates.equalTo('month', month);

    const resultSet = await store.query(predicates);
    let amount: number | null = null;

    if (resultSet.goToFirstRow()) {
      amount = resultSet.getDouble(resultSet.getColumnIndex('amount'));
    }
    resultSet.close();
    return amount;
  }

  /**
   * 获取当月预算使用情况
   */
  async getBudgetStatus(month: string): Promise<{ budget: number; expense: number; percent: number }> {
    const budget = await this.getBudget(month);
    if (budget === null || budget <= 0) {
      return { budget: 0, expense: 0, percent: 0 };
    }

    // 获取当月支出
    const BillDao = (await import('./BillDao')).BillDao;
    const billDao = new BillDao();
    const summary = await billDao.getMonthSummary(month);

    return {
      budget: budget,
      expense: summary.expense,
      percent: (summary.expense / budget) * 100,
    };
  }
}
