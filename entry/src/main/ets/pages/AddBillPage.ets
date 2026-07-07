import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

// 预设分类
const EXPENSE_CATEGORIES: Array<Category> = [
  { id: 'food', name: '餐饮', icon: '🍽️' },
  { id: 'transport', name: '交通', icon: '🚌' },
  { id: 'shopping', name: '购物', icon: '🛒' },
  { id: 'entertainment', name: '娱乐', icon: '🎮' },
  { id: 'housing', name: '居家', icon: '🏠' },
  { id: 'medical', name: '医疗', icon: '💊' },
  { id: 'education', name: '教育', icon: '📚' },
  { id: 'other_expense', name: '其他', icon: '📌' },
];

const INCOME_CATEGORIES: Array<Category> = [
  { id: 'salary', name: '工资', icon: '💰' },
  { id: 'bonus', name: '奖金', icon: '🎁' },
  { id: 'investment', name: '投资', icon: '📈' },
  { id: 'parttime', name: '兼职', icon: '💼' },
  { id: 'other_income', name: '其他', icon: '📌' },
];

interface Category {
  id: string;
  name: string;
  icon: string;
}

@Entry
@Component
export struct AddBillPage {
  @State billType: number = 0;           // 0: 支出, 1: 收入
  @State amount: string = '';
  @State selectedCategoryId: string = '';
  @State selectedCategoryName: string = '';
  @State note: string = '';
  @State selectedDate: string = '';

  // 从路由参数获取编辑数据
  private isEditMode: boolean = false;
  private editBillId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['billType'] !== undefined) {
      this.billType = params['billType'] as number;
    }
    // 设置默认日期为今天
    const now = new Date();
    this.selectedDate = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
  }

  get categories(): Array<Category> {
    return this.billType === 0 ? EXPENSE_CATEGORIES : INCOME_CATEGORIES;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })

        Text(this.isEditMode ? '编辑账单' : '记一笔')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(this.isEditMode ? '保存' : '完成')
          .fontSize(16)
          .fontColor('#1296db')
          .onClick(() => {
            this.saveBill();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 收支类型切换
      Row() {
        Button('支出')
          .type(this.billType === 0 ? ButtonType.Normal : ButtonType.Capsule)
          .backgroundColor(this.billType === 0 ? '#FF5722' : '#F0F0F0')
          .fontColor(this.billType === 0 ? '#FFFFFF' : '#999999')
          .onClick(() => { this.billType = 0; })

        Button('收入')
          .type(this.billType === 1 ? ButtonType.Normal : ButtonType.Capsule)
          .backgroundColor(this.billType === 1 ? '#4CAF50' : '#F0F0F0')
          .fontColor(this.billType === 1 ? '#FFFFFF' : '#999999')
          .margin({ left: 12 })
          .onClick(() => { this.billType = 1; })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)

      // 金额输入
      Column() {
        Text('金额')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 8 })

        Row() {
          Text('¥')
            .fontSize(24)
            .fontColor('#333333')
            .margin({ right: 4 })
          TextInput({ text: this.amount, placeholder: '0.00' })
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .type(InputType.Number)
            .width('100%')
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.amount = value;
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 8 })

      // 分类选择
      Column() {
        Text('选择分类')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 12 })

        Grid() {
          ForEach(this.categories, (item: Category) => {
            GridItem() {
              Column() {
                Text(item.icon)
                  .fontSize(28)
                Text(item.name)
                  .fontSize(12)
                  .fontColor(this.selectedCategoryId === item.id ? '#1296db' : '#666666')
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .borderRadius(8)
              .backgroundColor(this.selectedCategoryId === item.id ? '#E3F2FD' : '#F5F5F5')
              .border({
                width: this.selectedCategoryId === item.id ? 1.5 : 0,
                color: '#1296db'
              })
              .onClick(() => {
                this.selectedCategoryId = item.id;
                this.selectedCategoryName = item.name;
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 8 })

      // 日期选择
      Row() {
        Text('日期')
          .fontSize(15)
          .fontColor('#333333')

        Blank()

        Text(this.selectedDate)
          .fontSize(15)
          .fontColor('#1296db')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 8 })

      // 备注输入
      TextInput({ text: this.note, placeholder: '添加备注...' })
        .fontSize(15)
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 8 })
        .onChange((value: string) => {
          this.note = value;
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  saveBill(): void {
    const amountNum = parseFloat(this.amount);
    if (isNaN(amountNum) || amountNum <= 0) {
      promptAction.showToast({ message: '请输入有效金额', duration: 2000 });
      return;
    }
    if (this.selectedCategoryId === '') {
      promptAction.showToast({ message: '请选择分类', duration: 2000 });
      return;
    }

    // 构造账单数据并通过路由返回
    const billData: Record<string, Object> = {
      'amount': amountNum,
      'type': this.billType,
      'categoryId': this.selectedCategoryId,
      'categoryName': this.selectedCategoryName,
      'note': this.note,
      'date': this.selectedDate,
    };

    if (this.isEditMode) {
      billData['id'] = this.editBillId;
    }

    promptAction.showToast({ message: '记录成功', duration: 2000 });
    router.back();
  }
}
