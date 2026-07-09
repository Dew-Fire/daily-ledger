import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { BudgetDao } from '../database/BudgetDao';
import { billViewModel } from '../viewmodel/BillViewModel';

@Entry
@Component
export struct BudgetPage {
  @State budgetAmount: string = '';
  @State currentBudget: number = 0;
  @State monthExpense: number = 0;
  @State budgetPercent: number = 0;
  @State currentMonth: string = '';
  @State isLoading: boolean = true;
  private budgetDao: BudgetDao = new BudgetDao();

  aboutToAppear(): void {
    const now = new Date();
    this.currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    this.loadBudget();
  }

  async loadBudget(): Promise<void> {
    this.isLoading = true;
    try {
      const status = await this.budgetDao.getBudgetStatus(this.currentMonth);
      this.currentBudget = status.budget;
      this.monthExpense = status.expense;
      this.budgetPercent = status.percent;

      if (status.budget > 0) {
        this.budgetAmount = String(status.budget);
      }
    } catch (e) {
      console.error('Failed to load budget:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async saveBudget(): Promise<void> {
    const amount = parseFloat(this.budgetAmount);
    if (isNaN(amount) || amount <= 0) {
      promptAction.showToast({ message: '请输入有效的预算金额', duration: 2000 });
      return;
    }

    try {
      await this.budgetDao.setBudget(this.currentMonth, amount);
      promptAction.showToast({ message: '预算设置成功', duration: 2000 });
      await this.loadBudget();
      router.back();
    } catch (e) {
      promptAction.showToast({ message: '保存失败', duration: 2000 });
    }
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => { router.back(); })

        Text('月度预算')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('保存')
          .fontSize(16)
          .fontColor('#1296db')
          .onClick(() => { this.saveBudget(); })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color('#1296db')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          // 预算进度卡片
          Column() {
            Text('本月预算')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 12 })

            Row() {
              Column() {
                Text('预算金额')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥ ${this.currentBudget > 0 ? this.currentBudget.toFixed(2) : '未设置'}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .width('33%')

              Column() {
                Text('已支出')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥ ${this.monthExpense.toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF5722')
                  .margin({ top: 4 })
              }
              .width('33%')
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text('剩余')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥ ${Math.max(0, this.currentBudget - this.monthExpense).toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.budgetPercent > 100 ? '#FF5722' : '#4CAF50')
                  .margin({ top: 4 })
              }
              .width('33%')
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')

            // 进度条
            Column() {
              Row() {
                Row()
                  .width(`${Math.min(this.budgetPercent, 100)}%`)
                  .height(8)
                  .borderRadius(4)
                  .backgroundColor(this.budgetPercent > 80
                    ? (this.budgetPercent > 100 ? '#FF5722' : '#FF9800')
                    : '#4CAF50')
              }
              .width('100%')
              .height(8)
              .borderRadius(4)
              .backgroundColor('#F0F0F0')
              .margin({ top: 16 })

              Text(this.currentBudget > 0
                ? `${this.budgetPercent.toFixed(1)}%`
                : '0%')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.budgetPercent > 100 ? '#FF5722' : '#333333')
                .margin({ top: 8 })

              if (this.budgetPercent > 100) {
                Text('⚠️ 已超出预算！')
                  .fontSize(13)
                  .fontColor('#FF5722')
                  .margin({ top: 4 })
              } else if (this.budgetPercent > 80) {
                Text('⚠️ 预算即将用完')
                  .fontSize(13)
                  .fontColor('#FF9800')
                  .margin({ top: 4 })
              } else if (this.currentBudget > 0) {
                Text('✅ 预算控制良好')
                  .fontSize(13)
                  .fontColor('#4CAF50')
                  .margin({ top: 4 })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 16, right: 16, top: 8 })

          // 预算设置
          Column() {
            Text('设置预算')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 12 })

            Row() {
              Text('¥')
                .fontSize(24)
                .fontColor('#333333')
                .margin({ right: 8 })

              TextInput({ text: this.budgetAmount, placeholder: '请输入月度预算金额' })
                .fontSize(20)
                .type(InputType.Number)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((value: string) => { this.budgetAmount = value; })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .padding(12)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 16, right: 16, top: 12 })
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
