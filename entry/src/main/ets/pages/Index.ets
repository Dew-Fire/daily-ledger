@Entry
@Component
struct Index {
  @State message: string = '个人记账本';

  build() {
    Column() {
      Text(this.message)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Text('每日记账，轻松理财')
        .fontSize(16)
        .fontColor('#999999')
        .margin({ top: 12 })

      Text('HarmonyOS NEXT')
        .fontSize(12)
        .fontColor('#CCCCCC')
        .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}
