import { router } from '@kit.ArkUI';

@Component
export struct BillListPage {
  @State bills: Array<BillItem> = [];
  @State selectedMonth: string = '2026-07';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('个人记账本')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('+')
          .fontSize(28)
          .fontColor('#1296db')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddBillPage' });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 月度收支概要
      Row() {
        Column() {
          Text('本月收入')
            .fontSize(12)
            .fontColor('#999999')
          Text('¥ 0.00')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
            .margin({ top: 4 })
        }
        .width('50%')

        Column() {
          Text('本月支出')
            .fontSize(12)
            .fontColor('#999999')
          Text('¥ 0.00')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF5722')
            .margin({ top: 4 })
        }
        .width('50%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 8 })

      // 账单列表为空
      Column() {
        Text('还没有账单记录')
          .fontSize(16)
          .fontColor('#CCCCCC')
          .margin({ top: 8 })
        Text('点击右上角 + 开始记账')
          .fontSize(14)
          .fontColor('#E0E0E0')
          .margin({ top: 4 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

// 账单数据模型
export interface BillItem {
  id: string;
  amount: number;
  type: number;       // 0: 支出, 1: 收入
  categoryId: string;
  categoryName: string;
  note: string;
  date: string;
}
