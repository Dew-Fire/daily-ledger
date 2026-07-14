import { billViewModel, type CategoryStatItem } from '../viewmodel/BillViewModel';

interface CategoryStat {
  name: string;
  amount: number;
  percent: number;
  color: string;
}

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

@Entry
@Component
export struct StatisticsPage {
  @State expenseStats: Array<CategoryStat> = [];
  @State incomeStats: Array<CategoryStat> = [];
  @State monthlyTrend: Array<MonthTrend> = [];
  @State monthExpense: number = 0;
  @State monthIncome: number = 0;
  @State isLoading: boolean = true;
  @State showType: number = 0;
  @State hasData: boolean = false;

  aboutToAppear(): void {
    const now = new Date();
    const month = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    this.loadData(month);
  }

  async loadData(month: string): Promise<void> {
    this.isLoading = true;
    try {
      const stats = await billViewModel.getCategoryStats(month);

      const expenseItems: Array<CategoryStatItem> = [];
      const incomeItems: Array<CategoryStatItem> = [];

      stats.forEach((s: CategoryStatItem) => {
        if (s.type === 0) expenseItems.push(s);
        else incomeItems.push(s);
      });

      const totalExpense: number = expenseItems.reduce((sum: number, s: CategoryStatItem) => sum + s.amount, 0);
      this.monthExpense = totalExpense;

      const expenseList: Array<CategoryStat> = [];
      expenseItems.forEach((s: CategoryStatItem, i: number) => {
        const stat: CategoryStat = {
          name: s.name,
          amount: s.amount,
          percent: totalExpense > 0 ? (s.amount / totalExpense) * 100 : 0,
          color: COLORS[i % COLORS.length],
        };
        expenseList.push(stat);
      });
      this.expenseStats = expenseList;

      const totalIncome: number = incomeItems.reduce((sum: number, s: CategoryStatItem) => sum + s.amount, 0);
      this.monthIncome = totalIncome;

      const incomeList: Array<CategoryStat> = [];
      incomeItems.forEach((s: CategoryStatItem, i: number) => {
        const stat: CategoryStat = {
          name: s.name,
          amount: s.amount,
          percent: totalIncome > 0 ? (s.amount / totalIncome) * 100 : 0,
          color: COLORS[i % COLORS.length],
        };
        incomeList.push(stat);
      });
      this.incomeStats = incomeList;

      // 月度趋势
      const trendResult: Array<MonthTrend> = await billViewModel.getMonthlyTrend(6);
      this.monthlyTrend = trendResult;

      this.hasData = expenseList.length > 0 || incomeList.length > 0;
    } catch (e) {
      console.error('Failed to load statistics:', JSON.stringify(e));
      this.hasData = false;
    } finally {
      this.isLoading = false;
    }
  }

  getDisplayStats(): Array<CategoryStat> {
    if (this.showType === 0) {
      return this.expenseStats;
    } else {
      return this.incomeStats;
    }
  }

  build() {
    Column() {
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
            .width(36).height(36).color('#1296db')
          Text('加载中...')
            .fontSize(14).fontColor('#CCCCCC').margin({ top: 12 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        // 月度汇总卡片
        Row() {
          Column() {
            Text('本月支出').fontSize(12).fontColor('#999999')
            Text(`¥ ${this.monthExpense.toFixed(2)}`)
              .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FF5722').margin({ top: 4 })
          }
          .width('50%')

          Column() {
            Text('本月收入').fontSize(12).fontColor('#999999')
            Text(`¥ ${this.monthIncome.toFixed(2)}`)
              .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#4CAF50').margin({ top: 4 })
          }
          .width('50%')
        }
        .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(12)
        .margin({ left: 16, right: 16, top: 8 })

        // 分类占比
        Column() {
          Row() {
            Text('分类占比')
              .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')

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
              .height(28).margin({ left: 8 })
              .onClick(() => { this.showType = 1; })
          }
          .width('100%').padding({ left: 16, right: 16, top: 16, bottom: 8 })

          // 分类项列表
          if (this.getDisplayStats().length === 0) {
            Text(this.showType === 0 ? '本月暂无支出记录' : '本月暂无收入记录')
              .fontSize(14).fontColor('#CCCCCC').width('100%').textAlign(TextAlign.Center)
              .padding(24)
          } else {
            ForEach(this.getDisplayStats(), (stat: CategoryStat, index: number) => {
              Column() {
                Row() {
                  Row().width(10).height(10).borderRadius(2).backgroundColor(stat.color)
                  Text(stat.name).fontSize(14).fontColor('#333333').margin({ left: 8 }).layoutWeight(1)
                  Text(`¥ ${stat.amount.toFixed(2)}`).fontSize(14).fontColor('#666666').margin({ right: 8 })
                  Text(`${stat.percent.toFixed(1)}%`).fontSize(13).fontColor('#999999').width(48).textAlign(TextAlign.End)
                }
                .width('100%')

                Row() {
                  Row()
                    .width(`${stat.percent}%`)
                    .height(4).borderRadius(2).backgroundColor(stat.color)
                }
                .width('100%').height(4).borderRadius(2).backgroundColor('#F0F0F0')
                .margin({ top: 6 })
              }
              .width('100%').padding({ left: 16, right: 16, top: 10, bottom: 10 })
            }, (stat: CategoryStat) => stat.name)
          }
        }
        .width('100%').padding({ top: 8, bottom: 8 }).backgroundColor('#FFFFFF').borderRadius(12)
        .margin({ left: 16, right: 16, top: 12 })

        // 月度趋势
        Column() {
          Text('近6个月趋势')
            .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
            .padding({ left: 16, top: 16, bottom: 8 })

          if (this.monthlyTrend.length > 0) {
            Row() {
              ForEach(this.monthlyTrend, (item: MonthTrend) => {
                Column() {
                  Row().width(20).height(this.barHeight(item.income))
                    .backgroundColor('#4CAF50').borderRadius({ topLeft: 3, topRight: 3 })
                  Row().width(20).height(this.barHeight(item.expense))
                    .backgroundColor('#FF5722').borderRadius({ topLeft: 3, topRight: 3 }).margin({ top: 2 })
                  Text(item.month.substring(5)).fontSize(10).fontColor('#999999').margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center).layoutWeight(1)
              }, (item: MonthTrend) => item.month)
            }
            .width('100%').alignItems(VerticalAlign.Bottom).constraintSize({ minHeight: 120 })

            Row() {
              Row() {
                Row().width(10).height(10).borderRadius(2).backgroundColor('#4CAF50')
                Text('收入').fontSize(11).fontColor('#999999').margin({ left: 4 })
              }
              .margin({ right: 16 })
              Row() {
                Row().width(10).height(10).borderRadius(2).backgroundColor('#FF5722')
                Text('支出').fontSize(11).fontColor('#999999').margin({ left: 4 })
              }
            }
            .margin({ top: 8 })
          } else {
            Text('暂无趋势数据').fontSize(14).fontColor('#CCCCCC').width('100%').textAlign(TextAlign.Center).padding(24)
          }
        }
        .width('100%').padding({ top: 8, bottom: 16 }).backgroundColor('#FFFFFF').borderRadius(12)
        .margin({ left: 16, right: 16, top: 12, bottom: 16 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  barHeight(amount: number): number {
    if (this.monthlyTrend.length === 0) {
      return 2;
    }
    let maxAmount: number = 1;
    this.monthlyTrend.forEach((m: MonthTrend) => {
      const max: number = Math.max(m.income, m.expense);
      if (max > maxAmount) {
        maxAmount = max;
      }
    });
    return Math.max((amount / maxAmount) * 80, 2);
  }
}
