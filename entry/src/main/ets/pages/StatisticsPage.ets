@Component
export struct StatisticsPage {
  @State selectedMonth: string = '2026-07';

  build() {
    Column() {
      Text('月度统计')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 12 })

      // 月度选择
      Row() {
        Text(this.selectedMonth)
          .fontSize(16)
          .fontColor('#333333')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })

      // 图表占位区域
      Column() {
        Text('📊')
          .fontSize(48)
          .margin({ bottom: 12 })
        Text('图表功能即将上线')
          .fontSize(16)
          .fontColor('#CCCCCC')
        Text('收支分类占比与月度趋势分析')
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
