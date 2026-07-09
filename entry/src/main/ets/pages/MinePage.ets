import { router } from '@kit.ArkUI';

@Component
export struct MinePage {
  build() {
    Column() {
      Text('我的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 12 })

      // 功能列表
      Column() {
        this.MenuItem('分类管理', '管理收支分类与图标', 'pages/CategoryPage')
        Divider().margin({ left: 16 })
        this.MenuItem('月度预算', '设置每月预算上限')
        Divider().margin({ left: 16 })
        this.MenuItem('数据导出', '导出账单明细')
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
  MenuItem(title: string, desc: string, route?: string) {
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
      if (route) {
        router.pushUrl({ url: route });
      }
    })
  }
}
