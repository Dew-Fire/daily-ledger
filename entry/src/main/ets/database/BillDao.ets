import { relationalStore } from '@kit.ArkData';
import { getRdbStore } from './DatabaseHelper';
import type { BillItem } from '../model/BillModel';

/**
 * 账单数据访问对象 — CRUD
 */
export class BillDao {
  private getStore(): relationalStore.RdbStore {
    return getRdbStore();
  }

  /**
   * 新增账单
   */
  async insert(bill: BillItem): Promise<number> {
    const store = this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      amount: bill.amount,
      type: bill.type,
      category_id: bill.categoryId,
      category_name: bill.categoryName,
      note: bill.note || '',
      date: bill.date,
      created_at: Date.now(),
    };
    return await store.insert('bills', valueBucket);
  }

  /**
   * 更新账单
   */
  async update(bill: BillItem): Promise<number> {
    const store = this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      amount: bill.amount,
      type: bill.type,
      category_id: bill.categoryId,
      category_name: bill.categoryName,
      note: bill.note || '',
      date: bill.date,
    };
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.equalTo('id', Number(bill.id));
    return await store.update(valueBucket, predicates);
  }

  /**
   * 删除账单
   */
  async delete(billId: string): Promise<number> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.equalTo('id', Number(billId));
    return await store.delete(predicates);
  }

  /**
   * 查询所有账单，按日期降序
   */
  async queryAll(): Promise<Array<BillItem>> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.orderByDesc('date').orderByDesc('created_at');

    const resultSet = await store.query(predicates);
    const bills: Array<BillItem> = [];

    try {
      while (resultSet.goToNextRow()) {
        bills.push({
          id: String(resultSet.getLong(resultSet.getColumnIndex('id'))),
          amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
          type: resultSet.getLong(resultSet.getColumnIndex('type')),
          categoryId: resultSet.getString(resultSet.getColumnIndex('category_id')),
          categoryName: resultSet.getString(resultSet.getColumnIndex('category_name')),
          note: resultSet.getString(resultSet.getColumnIndex('note')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
        });
      }
    } finally {
      resultSet.close();
    }
    return bills;
  }

  /**
   * 按月份查询账单
   */
  async queryByMonth(month: string): Promise<Array<BillItem>> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('bills');
    predicates.like('date', `${month}%`).orderByDesc('date').orderByDesc('created_at');

    const resultSet = await store.query(predicates);
    const bills: Array<BillItem> = [];

    try {
      while (resultSet.goToNextRow()) {
        bills.push({
          id: String(resultSet.getLong(resultSet.getColumnIndex('id'))),
          amount: resultSet.getDouble(resultSet.getColumnIndex('amount')),
          type: resultSet.getLong(resultSet.getColumnIndex('type')),
          categoryId: resultSet.getString(resultSet.getColumnIndex('category_id')),
          categoryName: resultSet.getString(resultSet.getColumnIndex('category_name')),
          note: resultSet.getString(resultSet.getColumnIndex('note')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
        });
      }
    } finally {
      resultSet.close();
    }
    return bills;
  }

  /**
   * 按月汇总收支
   */
  async getMonthSummary(month: string): Promise<MonthSummaryResult> {
    const bills = await this.queryByMonth(month);
    let income = 0;
    let expense = 0;
    bills.forEach((b) => {
      if (b.type === 1) income += b.amount;
      else expense += b.amount;
    });
    const result: MonthSummaryResult = { income, expense };
    return result;
  }
}

interface MonthSummaryResult {
  income: number;
  expense: number;
}
