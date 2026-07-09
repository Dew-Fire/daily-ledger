import { BillListPage } from './BillListPage';
import { StatisticsPage } from './StatisticsPage';
import { MinePage } from './MinePage';
import { breakpointSystem, BreakpointType } from '../utils/BreakpointSystem';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State contentType: string = 'phone';
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointType = BreakpointType.SM;
  private controller: TabsController = new TabsController();

  @Builder
  TabBarBuilder(title: string, icon: Resource, index: number) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? '#1296db' : '#999999')
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
      .tabBar(this.TabBarBuilder('账单', $r('sys.media.ohos_ic_public_add'), 0))

      TabContent() {
        StatisticsPage()
      }
      .tabBar(this.TabBarBuilder('统计', $r('sys.media.ohos_ic_public_add'), 1))

      TabContent() {
        MinePage()
      }
      .tabBar(this.TabBarBuilder('我的', $r('sys.media.ohos_ic_public_add'), 2))
    }
    .barHeight(56)
    .barBackgroundColor('#FFFFFF')
    .barMode(breakpointSystem.isTablet() ? BarMode.Fixed : BarMode.Free)
    .width(breakpointSystem.isTablet() ? '600vp' : '100%')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
