import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 通知工具类 — 超支提醒
 */
export class NotificationHelper {
  /**
   * 发送预算相关通知
   */
  static async sendBudgetAlert(budget: number, expense: number, month: string): Promise<void> {
    const percent = (expense / budget) * 100;
    let title: string;
    let text: string;

    if (percent >= 100) {
      title = '⚠️ 预算已超支';
      text = `${month}月已支出 ¥${expense.toFixed(2)}，超出预算 ¥${(expense - budget).toFixed(2)}`;
    } else if (percent >= 80) {
      title = '⚡ 预算使用预警';
      text = `${month}月已使用预算的 ${percent.toFixed(0)}%，剩余 ¥${(budget - expense).toFixed(2)}`;
    } else {
      return; // 无需通知
    }

    const request: notificationManager.NotificationRequest = {
      id: 1001,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: title,
          text: text,
        }
      },
    };

    try {
      await notificationManager.publish(request);
      console.info(`Budget notification published: ${title}`);
    } catch (err) {
      const e = err as BusinessError;
      console.error(`Failed to publish notification: code=${e.code}, msg=${e.message}`);
    }
  }

  /**
   * 发送记账提醒（每日）
   */
  static async sendReminder(): Promise<void> {
    const request: notificationManager.NotificationRequest = {
      id: 1002,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '📝 记账提醒',
          text: '今天还没有记账哦，记得记录今天的收支！',
        }
      },
    };

    try {
      await notificationManager.publish(request);
    } catch (err) {
      const e = err as BusinessError;
      console.error(`Failed to publish reminder: code=${e.code}, msg=${e.message}`);
    }
  }
}
