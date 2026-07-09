import { BillListPage } from './BillListPage';
import { StatisticsPage } from './StatisticsPage';
import { MinePage } from './MinePage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private controller: TabsController = new TabsController();

  @Builder
  TabBarBuilder(title: string, icon: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(22)
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#1296db' : '#999999')
        .margin({ top: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .onClick(() => {
      this.currentIndex = index;
      this.controller.changeIndex(index);
    })
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.controller
    }) {
      TabContent() {
        BillListPage()
      }
      .tabBar(this.TabBarBuilder('账单', '📋', 0))

      TabContent() {
        StatisticsPage()
      }
      .tabBar(this.TabBarBuilder('统计', '📊', 1))

      TabContent() {
        MinePage()
      }
      .tabBar(this.TabBarBuilder('我的', '👤', 2))
    }
    .barHeight(56)
    .barBackgroundColor('#FFFFFF')
    .width('100%')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
