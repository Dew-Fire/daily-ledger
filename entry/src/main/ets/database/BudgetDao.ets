import { relationalStore } from '@kit.ArkData';
import { getRdbStore } from './DatabaseHelper';

// 预算状态结果
interface BudgetStatusResult {
  budget: number;
  expense: number;
  percent: number;
}

/**
 * 预算数据访问对象
 */
export class BudgetDao {
  private getStore(): relationalStore.RdbStore {
    return getRdbStore();
  }

  async setBudget(month: string, amount: number): Promise<void> {
    const store = this.getStore();
    const existing = await this.getBudget(month);

    if (existing !== null) {
      const valueBucket: relationalStore.ValuesBucket = { amount };
      const predicates = new relationalStore.RdbPredicates('budgets');
      predicates.equalTo('month', month);
      await store.update(valueBucket, predicates);
    } else {
      const now = Date.now();
      const valueBucket: relationalStore.ValuesBucket = {
        month,
        amount,
        created_at: now,
      };
      await store.insert('budgets', valueBucket);
    }
  }

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
   * 获取当月预算使用情况（通过直接查询账单表计算支出）
   */
  async getBudgetStatus(month: string): Promise<BudgetStatusResult> {
    const budget = await this.getBudget(month);
    if (budget === null || budget <= 0) {
      const empty: BudgetStatusResult = { budget: 0, expense: 0, percent: 0 };
      return empty;
    }

    // 直接查询当月支出
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.like('date', `${month}%`).equalTo('type', 0);
    const resultSet = await store.query(predicates);

    let expense = 0;
    try {
      while (resultSet.goToNextRow()) {
        expense += resultSet.getDouble(resultSet.getColumnIndex('amount'));
      }
    } finally {
      resultSet.close();
    }

    const percent = (expense / budget) * 100;
    const status: BudgetStatusResult = { budget, expense, percent };
    return status;
  }
}
