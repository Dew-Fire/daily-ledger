import { fileIo } from '@ohos.file.fs';
import { billViewModel } from '../viewmodel/BillViewModel';
import type { BillItem } from '../model/BillModel';

/**
 * 账单导出工具 — 生成 CSV 并写入文件
 */
export class ExportHelper {

  /**
   * 导出所有账单为 CSV 文件
   * @returns 导出文件路径
   */
  static async exportToCsv(context: Context): Promise<string> {
    const bills = await billViewModel.loadBills();

    // CSV 表头
    const header = '日期,类型,分类,金额,备注';
    const rows: Array<string> = [header];

    // 数据行（按日期升序）
    bills.sort((a: BillItem, b: BillItem) => a.date.localeCompare(b.date));
    bills.forEach((b: BillItem) => {
      const typeStr = b.type === 1 ? '收入' : '支出';
      // CSV 转义：金额不加引号，备注中的逗号需要处理
      const noteEscaped = b.note.replace(/"/g, '""');
      const noteQuoted = b.note ? `"${noteEscaped}"` : '';
      rows.push(`${b.date},${typeStr},${b.categoryName},${b.amount.toFixed(2)},${noteQuoted}`);
    });

    const csvContent = rows.join('\n');

    // 写入缓存目录
    const contextDir = context.cacheDir;
    const now = new Date();
    const fileName = `记账数据_${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}.csv`;
    const filePath = `${contextDir}/${fileName}`;

    const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
    fileIo.writeSync(file.fd, csvContent);
    fileIo.closeSync(file);

    return filePath;
  }

  /**
   * 生成预览摘要
   */
  static async getExportSummary(): Promise<{ totalBills: number; totalExpense: number; totalIncome: number }> {
    const bills = await billViewModel.loadBills();
    let totalExpense = 0;
    let totalIncome = 0;

    bills.forEach((b: BillItem) => {
      if (b.type === 1) totalIncome += b.amount;
      else totalExpense += b.amount;
    });

    return {
      totalBills: bills.length,
      totalExpense,
      totalIncome,
    };
  }
}
