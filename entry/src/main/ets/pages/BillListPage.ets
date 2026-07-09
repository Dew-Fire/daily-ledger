import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import type { BillItem } from '../model/BillModel';
import { billViewModel } from '../viewmodel/BillViewModel';

// 按日期分组的账单组
class BillGroup {
  dateLabel: string = '';
  date: string = '';
  bills: Array<BillItem> = [];
  totalExpense: number = 0;
  totalIncome: number = 0;
}

// 将账单按日期分组
function groupBillsByDate(bills: Array<BillItem>): Array<BillGroup> {
  const today = new Date();
  const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
  const yesterday = new Date(today.getTime() - 86400000);
  const yesterdayStr = `${yesterday.getFullYear()}-${String(yesterday.getMonth() + 1).padStart(2, '0')}-${String(yesterday.getDate()).padStart(2, '0')}`;

  const groupMap = new Map<string, BillGroup>();

  bills.forEach((bill) => {
    let group = groupMap.get(bill.date);
    if (!group) {
      group = new BillGroup();
      group.date = bill.date;

      if (bill.date === todayStr) {
        group.dateLabel = '今天';
      } else if (bill.date === yesterdayStr) {
        group.dateLabel = '昨天';
      } else {
        const parts = bill.date.split('-');
        group.dateLabel = `${parts[1]}-${parts[2]}`;
      }

      groupMap.set(bill.date, group);
    }

    group.bills.push(bill);
    if (bill.type === 0) {
      group.totalExpense += bill.amount;
    } else {
      group.totalIncome += bill.amount;
    }
  });

  return Array.from(groupMap.values()).sort((a, b) => b.date.localeCompare(a.date));
}

@Entry
@Component
export struct BillListPage {
  @State billGroups: Array<BillGroup> = [];
  @State monthIncome: number = 0;
  @State monthExpense: number = 0;
  @State isEmpty: boolean = true;
  @State showDeleteDialog: boolean = false;
  @State isLoading: boolean = true;
  private deleteTargetId: string = '';
  private allBills: Array<BillItem> = [];

  aboutToAppear(): void {
    this.refreshList();
  }

  onPageShow(): void {
    this.refreshList();
  }

  async refreshList(): Promise<void> {
    try {
      this.isLoading = true;
      this.allBills = await billViewModel.loadBills();

      if (this.allBills.length > 0) {
        this.billGroups = groupBillsByDate(this.allBills);
        this.isEmpty = false;

        let income = 0;
        let expense = 0;
        this.allBills.forEach((b) => {
          if (b.type === 1) income += b.amount;
          else expense += b.amount;
        });
        this.monthIncome = income;
        this.monthExpense = expense;
      } else {
        this.isEmpty = true;
        this.monthIncome = 0;
        this.monthExpense = 0;
      }
    } catch (e) {
      console.error('Failed to load bills:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  editBill(bill: BillItem): void {
    const params: Record<string, Object> = {
      'editMode': true,
      'billId': bill.id,
      'amount': bill.amount,
      'type': bill.type,
      'categoryId': bill.categoryId,
      'categoryName': bill.categoryName,
      'note': bill.note,
      'date': bill.date,
    };
    router.pushUrl({
      url: 'pages/AddBillPage',
      params: params,
    });
  }

  confirmDelete(billId: string): void {
    this.deleteTargetId = billId;
    this.showDeleteDialog = true;
  }

  async doDelete(): Promise<void> {
    try {
      await billViewModel.deleteBill(this.deleteTargetId);
      this.showDeleteDialog = false;
      promptAction.showToast({ message: '已删除', duration: 2000 });
      await this.refreshList();
    } catch (e) {
      console.error('Failed to delete bill:', JSON.stringify(e));
    }
  }

  cancelDelete(): void {
    this.showDeleteDialog = false;
    this.deleteTargetId = '';
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        Row() {
          Text('个人记账本')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Text('+')
            .fontSize(28)
            .fontColor('#1296db')
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddBillPage' });
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        // 月度收支概要
        Row() {
          Column() {
            Text('本月收入')
              .fontSize(12)
              .fontColor('#999999')
            Text(`¥ ${this.monthIncome.toFixed(2)}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
              .margin({ top: 4 })
          }
          .width('50%')

          Column() {
            Text('本月支出')
              .fontSize(12)
              .fontColor('#999999')
            Text(`¥ ${this.monthExpense.toFixed(2)}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF5722')
              .margin({ top: 4 })
          }
          .width('50%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 8 })

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(36)
              .height(36)
              .color('#1296db')
            Text('加载中...')
              .fontSize(14)
              .fontColor('#CCCCCC')
              .margin({ top: 12 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.isEmpty) {
          Column() {
            Text('还没有账单记录')
              .fontSize(16)
              .fontColor('#CCCCCC')
              .margin({ top: 8 })
            Text('点击右上角 + 开始记账')
              .fontSize(14)
              .fontColor('#E0E0E0')
              .margin({ top: 4 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.billGroups, (group: BillGroup) => {
              ListItem() {
                this.GroupHeader(group)
              }

              ForEach(group.bills, (bill: BillItem) => {
                ListItem() {
                  this.BillItemRow(bill)
                }
                .swipeAction({
                  end: {
                    builder: () => {
                      this.DeleteButton()
                    },
                    onAction: () => {
                      this.confirmDelete(bill.id);
                    }
                  }
                } as SwipeActionOptions)
                .onClick(() => {
                  this.editBill(bill);
                })
              }, (bill: BillItem) => bill.id)
            }, (group: BillGroup) => group.date)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 8 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 删除确认弹窗
      if (this.showDeleteDialog) {
        Column() {
          Column() {
            Text('确认删除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 12 })

            Text('删除后无法恢复，确定要删除这笔账单吗？')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 20 })

            Row() {
              Button('取消')
                .backgroundColor('#F0F0F0')
                .fontColor('#666666')
                .layoutWeight(1)
                .onClick(() => { this.cancelDelete(); })

              Button('删除')
                .backgroundColor('#FF5722')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .margin({ left: 12 })
                .onClick(() => { this.doDelete(); })
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }
        .width('80%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DeleteButton() {
    Row() {
      Text('删除')
        .fontSize(14)
        .fontColor('#FFFFFF')
    }
    .width(64)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FF5722')
  }

  @Builder
  GroupHeader(group: BillGroup) {
    Row() {
      Text(group.dateLabel)
        .fontSize(14)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Blank()

      if (group.totalExpense > 0) {
        Text(`支出 ¥${group.totalExpense.toFixed(2)}`)
          .fontSize(12)
          .fontColor('#FF5722')
      }

      if (group.totalIncome > 0) {
        Text(`${group.totalExpense > 0 ? '  ' : ''}收入 ¥${group.totalIncome.toFixed(2)}`)
          .fontSize(12)
          .fontColor('#4CAF50')
      }
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 12, bottom: 6 })
  }

  @Builder
  BillItemRow(bill: BillItem) {
    Row() {
      Text('💳')
        .fontSize(24)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)

      Column() {
        Text(bill.categoryName)
          .fontSize(15)
          .fontColor('#333333')
        if (bill.note) {
          Text(bill.note)
            .fontSize(12)
            .fontColor('#CCCCCC')
            .margin({ top: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      Text(`${bill.type === 1 ? '+' : '-'}${bill.amount.toFixed(2)}`)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(bill.type === 1 ? '#4CAF50' : '#333333')
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .margin({ bottom: 8 })
  }
}
