import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { ExportHelper } from '../utils/ExportHelper';
import { common } from '@kit.AbilityKit';

@Entry
@Component
export struct MinePage {
  @State isExporting: boolean = false;

  async doExport(): Promise<void> {
    if (this.isExporting) return;
    this.isExporting = true;

    try {
      const context = getContext(this) as common.UIAbilityContext;

      // 先检查是否有数据
      const summary = await ExportHelper.getExportSummary();
      if (summary.totalBills === 0) {
        promptAction.showToast({ message: '没有账单数据可导出', duration: 2000 });
        return;
      }

      // 导出 CSV
      const filePath = await ExportHelper.exportToCsv(context);

      promptAction.showDialog({
        title: '导出成功',
        message: `共导出 ${summary.totalBills} 条账单\n收入 ¥${summary.totalIncome.toFixed(2)}\n支出 ¥${summary.totalExpense.toFixed(2)}\n\n文件路径:\n${filePath}`,
        buttons: [
          { text: '确定', color: '#1296db' }
        ]
      });
    } catch (e) {
      promptAction.showToast({ message: '导出失败，请重试', duration: 2000 });
    } finally {
      this.isExporting = false;
    }
  }

  build() {
    Column() {
      Text('我的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 12 })

      Column() {
        this.MenuItem('分类管理', '管理收支分类与图标', 'pages/CategoryPage')
        Divider().margin({ left: 16 })
        this.MenuItem('月度预算', '设置每月预算上限', 'pages/BudgetPage')
        Divider().margin({ left: 16 })
        this.MenuItem('数据导出', this.isExporting ? '正在导出...' : '导出账单明细为 CSV', undefined, () => { this.doExport(); })
        Divider().margin({ left: 16 })
        this.MenuItem('关于', '个人记账本 v1.0.0')
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  MenuItem(title: string, desc: string, route?: string, action?: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
        Text(desc)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('>')
        .fontSize(16)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(() => {
      if (action) {
        action();
      } else if (route) {
        router.pushUrl({ url: route });
      }
    })
  }
}
