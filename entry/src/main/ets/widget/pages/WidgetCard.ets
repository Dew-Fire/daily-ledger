/**
 * 桌面服务卡片 — 当月收支概况 + 快速记账入口
 * 注意：服务卡片仅支持部分 ArkTS 组件，需避免状态装饰器
 */
@Entry
@Component
struct WidgetCard {
  // 服务卡片数据通过 formBindingData 注入，使用普通属性
  readonly monthIncome: string = '¥ 0.00';
  readonly monthExpense: string = '¥ 0.00';
  readonly budgetStatus: string = '加载中...';

  build() {
    Stack() {
      Column() {
        Text('个人记账本')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

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
    .backgroundColor('#1a73e8')
    .borderRadius(16)
  }
}
