/**
 * 桌面服务卡片 — 当月收支概况 + 快速记账入口
 */
@Entry
@Component
struct WidgetCard {
  @LocalStorageProp('monthIncome') monthIncome: string = '¥ 0.00';
  @LocalStorageProp('monthExpense') monthExpense: string = '¥ 0.00';
  @LocalStorageProp('budgetStatus') budgetStatus: string = '加载中...';
  @LocalStorageLink('detail') detail: string = '{}';

  build() {
    Stack() {
      Column() {
        // 标题
        Text('个人记账本')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        // 当月收支
        Row() {
          Column() {
            Text('收入')
              .fontSize(11)
              .fontColor('#B2DFDB')
            Text(this.monthIncome)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ top: 2 })
          }
          .width('50%')

          Column() {
            Text('支出')
              .fontSize(11)
              .fontColor('#FFCCBC')
            Text(this.monthExpense)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ top: 2 })
          }
          .width('50%')
        }
        .width('100%')
        .margin({ top: 12 })

        // 提示
        Text(this.budgetStatus)
          .fontSize(11)
          .fontColor('#B0BEC5')
          .margin({ top: 12 })
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%)')
    .borderRadius(16)
  }
}
