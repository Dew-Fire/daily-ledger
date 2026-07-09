import { billViewModel } from '../viewmodel/BillViewModel';

// 分类统计项
interface CategoryStat {
  name: string;
  amount: number;
  percent: number;
  color: string;
}

// 月度趋势项
interface MonthTrend {
  month: string;
  income: number;
  expense: number;
}

const COLORS: Array<string> = [
  '#FF5722', '#4CAF50', '#2196F3', '#FF9800', '#9C27B0',
  '#00BCD4', '#E91E63', '#607D8B', '#FFEB3B', '#795548',
  '#8BC34A', '#FF4081', '#536DFE', '#FF6E40', '#64B5F6',
];

@Component
export struct StatisticsPage {
  @State currentMonth: string = '';
  @State expenseStats: Array<CategoryStat> = [];
  @State incomeStats: Array<CategoryStat> = [];
  @State monthlyTrend: Array<MonthTrend> = [];
  @State monthExpense: number = 0;
  @State monthIncome: number = 0;
  @State isLoading: boolean = true;
  @State showType: number = 0;      // 0: 支出, 1: 收入

  aboutToAppear(): void {
    const now = new Date();
    this.currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 加载分类统计
      const stats = await billViewModel.getCategoryStats(this.currentMonth);

      // 支出分类
      const expenseItems = stats.filter((s) => s.type === 0);
      const totalExpense = expenseItems.reduce((sum, s) => sum + s.amount, 0);
      this.monthExpense = totalExpense;
      this.expenseStats = expenseItems.map((s, i) => ({
        name: s.name,
        amount: s.amount,
        percent: totalExpense > 0 ? (s.amount / totalExpense) * 100 : 0,
        color: COLORS[i % COLORS.length],
      }));

      // 收入分类
      const incomeItems = stats.filter((s) => s.type === 1);
      const totalIncome = incomeItems.reduce((sum, s) => sum + s.amount, 0);
      this.monthIncome = totalIncome;
      this.incomeStats = incomeItems.map((s, i) => ({
        name: s.name,
        amount: s.amount,
        percent: totalIncome > 0 ? (s.amount / totalIncome) * 100 : 0,
        color: COLORS[i % COLORS.length],
      }));

      // 加载月度趋势
      this.monthlyTrend = await billViewModel.getMonthlyTrend(6);
    } catch (e) {
      console.error('Failed to load stats:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  get currentStats(): Array<CategoryStat> {
    return this.showType === 0 ? this.expenseStats : this.incomeStats;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('月度统计')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ left: 16, top: 12, bottom: 4 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#1296db')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          // 月度汇总卡片
          ListItem() {
            Row() {
              Column() {
                Text('本月支出')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥ ${this.monthExpense.toFixed(2)}`)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF5722')
                  .margin({ top: 4 })
              }
              .width('50%')

              Column() {
                Text('本月收入')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥ ${this.monthIncome.toFixed(2)}`)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#4CAF50')
                  .margin({ top: 4 })
              }
              .width('50%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .margin({ left: 16, right: 16, top: 8, bottom: 4 })

          // 分类占比标题
          ListItem() {
            Row() {
              Text('分类占比')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')

              Blank()

              Button('支出')
                .fontSize(13)
                .type(this.showType === 0 ? ButtonType.Normal : ButtonType.Capsule)
                .backgroundColor(this.showType === 0 ? '#FF5722' : '#F0F0F0')
                .fontColor(this.showType === 0 ? '#FFFFFF' : '#999999')
                .height(28)
                .onClick(() => { this.showType = 0; })

              Button('收入')
                .fontSize(13)
                .type(this.showType === 1 ? ButtonType.Normal : ButtonType.Capsule)
                .backgroundColor(this.showType === 1 ? '#4CAF50' : '#F0F0F0')
                .fontColor(this.showType === 1 ? '#FFFFFF' : '#999999')
                .height(28)
                .margin({ left: 8 })
                .onClick(() => { this.showType = 1; })
            }
            .width('100%')
            .padding({ left: 20, right: 16, top: 12, bottom: 4 })
          }

          // 分类列表
          if (this.currentStats.length === 0) {
            ListItem() {
              Text(this.showType === 0 ? '本月暂无支出记录' : '本月暂无收入记录')
                .fontSize(14)
                .fontColor('#CCCCCC')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(24)
            }
          }

          ForEach(this.currentStats, (stat: CategoryStat, index: number) => {
            ListItem() {
              Column() {
                Row() {
                  // 色块
                  Row()
                    .width(10)
                    .height(10)
                    .borderRadius(2)
                    .backgroundColor(stat.color)

                  Text(stat.name)
                    .fontSize(14)
                    .fontColor('#333333')
                    .margin({ left: 8 })
                    .layoutWeight(1)

                  Text(`¥ ${stat.amount.toFixed(2)}`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ right: 8 })

                  Text(`${stat.percent.toFixed(1)}%`)
                    .fontSize(13)
                    .fontColor('#999999')
                    .width(48)
                    .textAlign(TextAlign.End)
                }
                .width('100%')

                // 进度条
                Row() {
                  Row()
                    .width(`${stat.percent}%`)
                    .height(4)
                    .borderRadius(2)
                    .backgroundColor(stat.color)
                }
                .width('100%')
                .height(4)
                .borderRadius(2)
                .backgroundColor('#F0F0F0')
                .margin({ top: 6 })
              }
              .width('100%')
              .padding({ left: 20, right: 16, top: 10, bottom: 10 })
            }
          }, (stat: CategoryStat) => stat.name)

          // 月度趋势标题
          ListItem() {
            Text('近6个月趋势')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .padding({ left: 20, top: 16, bottom: 8 })
          }

          // 月度趋势图
          ListItem() {
            Column() {
              // 柱状图区域
              Row() {
                ForEach(this.monthlyTrend, (item: MonthTrend) => {
                  Column() {
                    // 收入柱（绿色）
                    Row()
                      .width(20)
                      .height(`${this.barHeight(item.income)}`)
                      .backgroundColor('#4CAF50')
                      .borderRadius({ topLeft: 3, topRight: 3 })

                    // 支出柱（红色）
                    Row()
                      .width(20)
                      .height(`${this.barHeight(item.expense)}`)
                      .backgroundColor('#FF5722')
                      .borderRadius({ topLeft: 3, topRight: 3 })
                      .margin({ top: 2 })

                    // 月份标签
                    Text(item.month.substring(5))
                      .fontSize(10)
                      .fontColor('#999999')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Center)
                  .layoutWeight(1)
                })
              }
              .width('100%')
              .alignItems(VerticalAlign.Bottom)
              .constraintSize({ minHeight: 120 })

              // 图例
              Row() {
                Row() {
                  Row()
                    .width(10).height(10).borderRadius(2).backgroundColor('#4CAF50')
                  Text('收入')
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ left: 4 })
                }
                .margin({ right: 16 })

                Row() {
                  Row()
                    .width(10).height(10).borderRadius(2).backgroundColor('#FF5722')
                  Text('支出')
                    .fontSize(11)
                    .fontColor('#999999')
                    .margin({ left: 4 })
                }
              }
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
          .margin({ left: 16, right: 16, top: 4, bottom: 16 })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 计算柱状图高度（最大 80vp）
  barHeight(amount: number): number {
    const maxAmount = Math.max(
      ...this.monthlyTrend.map((m) => Math.max(m.income, m.expense)),
      1
    );
    return Math.max((amount / maxAmount) * 80, 2);
  }
}
