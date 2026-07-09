import { router } from '@kit.ArkUI';
import { billViewModel } from '../viewmodel/BillViewModel';
import type { BillItem } from '../model/BillModel';

@Entry
@Component
export struct SearchPage {
  @State searchKeyword: string = '';
  @State searchResults: Array<BillItem> = [];
  @State hasSearched: boolean = false;
  @State totalExpense: number = 0;
  @State totalIncome: number = 0;
  private allBills: Array<BillItem> = [];

  aboutToAppear(): void {
    this.loadAllBills();
  }

  async loadAllBills(): Promise<void> {
    try {
      this.allBills = await billViewModel.loadBills();
    } catch (e) {
      console.error('Failed to load bills for search:', JSON.stringify(e));
    }
  }

  // 执行搜索
  async doSearch(): Promise<void> {
    const keyword = this.searchKeyword.trim().toLowerCase();
    if (keyword === '') {
      this.hasSearched = false;
      this.searchResults = [];
      return;
    }

    this.hasSearched = true;

    // 多维度匹配：金额、备注、分类名称
    const results: Array<BillItem> = [];
    let expense = 0;
    let income = 0;

    this.allBills.forEach((b: BillItem) => {
      const matchAmount = String(b.amount).includes(keyword);
      const matchNote = b.note.toLowerCase().includes(keyword);
      const matchCategory = b.categoryName.toLowerCase().includes(keyword);
      const matchDate = b.date.includes(keyword);

      if (matchAmount || matchNote || matchCategory || matchDate) {
        results.push(b);
        if (b.type === 0) expense += b.amount;
        else income += b.amount;
      }
    });

    // 按日期降序
    results.sort((a: BillItem, b: BillItem) => b.date.localeCompare(a.date));

    this.searchResults = results;
    this.totalExpense = expense;
    this.totalIncome = income;
  }

  // 跳转编辑
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
    router.pushUrl({ url: 'pages/AddBillPage', params: params });
  }

  build() {
    Column() {
      // 搜索栏
      Row() {
        Text('←')
          .fontSize(24).fontColor('#333333')
          .onClick(() => { router.back(); })

        Search({ value: this.searchKeyword, placeholder: '搜索金额、备注、分类...' })
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin({ left: 8, right: 8 })
          .onChange((value: string) => {
            this.searchKeyword = value;
            this.doSearch();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      if (this.hasSearched) {
        // 搜索结果汇总
        Row() {
          Text(`共 ${this.searchResults.length} 条记录`)
            .fontSize(13).fontColor('#999999')

          Blank()

          Text(`收入 ¥${this.totalIncome.toFixed(2)}`)
            .fontSize(13).fontColor('#4CAF50')
            .margin({ right: 12 })

          Text(`支出 ¥${this.totalExpense.toFixed(2)}`)
            .fontSize(13).fontColor('#FF5722')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 8 })

        if (this.searchResults.length === 0) {
          Column() {
            Text('🔍')
              .fontSize(48).margin({ bottom: 12 })
            Text('没有找到相关账单')
              .fontSize(16).fontColor('#CCCCCC')
          }
          .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.searchResults, (bill: BillItem) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(bill.categoryName)
                      .fontSize(15).fontColor('#333333')
                    if (bill.note) {
                      Text(bill.note)
                        .fontSize(12).fontColor('#CCCCCC').margin({ top: 2 })
                        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                  }
                  .alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)

                  Column() {
                    Text(`${bill.type === 1 ? '+' : '-'}${bill.amount.toFixed(2)}`)
                      .fontSize(17).fontWeight(FontWeight.Medium)
                      .fontColor(bill.type === 1 ? '#4CAF50' : '#333333')

                    Text(bill.date)
                      .fontSize(11).fontColor('#CCCCCC').margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor('#FFFFFF').borderRadius(10).margin({ bottom: 6 })
                .onClick(() => { this.editBill(bill); })
              }
            }, (bill: BillItem) => bill.id)
          }
          .width('100%').layoutWeight(1).padding({ left: 16, right: 16 })
        }
      } else {
        // 未搜索时的提示
        Column() {
          Text('🔍')
            .fontSize(48).margin({ bottom: 12 })
          Text('输入关键词搜索账单')
            .fontSize(16).fontColor('#CCCCCC')
          Text('支持按金额、备注、分类、日期查询')
            .fontSize(13).fontColor('#E0E0E0').margin({ top: 4 })
        }
        .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
