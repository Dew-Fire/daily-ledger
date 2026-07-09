import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import {
  EXPENSE_CATEGORIES,
  INCOME_CATEGORIES,
  type CategoryGroup,
  type SubCategory,
} from '../model/CategoryModel';
import { categoryViewModel } from '../viewmodel/CategoryViewModel';
import type { CustomCategory } from '../database/CategoryDao';

// 混合分类项（预设 + 自定义）
interface MixedCategory {
  key: string;
  name: string;
  icon: string;
  isCustom: boolean;
  dbId?: number;        // 数据库 ID（仅自定义）
}

const ICON_OPTIONS: Array<string> = [
  '🍽️', '🍱', '🍿', '🥤', '☕', '🍰', '🍜', '🥩',
  '🚌', '🚇', '🚕', '⛽', '🚗', '🛵', '🏃', '🚴',
  '🛒', '👗', '🧴', '📱', '🛋️', '💻', '⌚', '📦',
  '🎮', '🎬', '✈️', '⚽', '🎵', '📖', '🎨', '🎯',
  '🏠', '💡', '🔨', '📋', '🏥', '💊', '🩺', '📚',
  '💰', '🎁', '📈', '💼', '🧧', '↩️', '📌',
];

@Entry
@Component
export struct CategoryPage {
  @State currentTab: number = 0;           // 0: 支出, 1: 收入
  @State categories: Array<MixedCategory> = [];
  @State showAddDialog: boolean = false;
  @State editCatKey: string = '';
  @State editCatName: string = '';
  @State editCatIcon: string = '📌';
  @State isEditing: boolean = false;
  @State editingDbId: number = 0;

  aboutToAppear(): void {
    this.loadCategories();
  }

  async loadCategories(): Promise<void> {
    const groups = this.currentTab === 0 ? EXPENSE_CATEGORIES : INCOME_CATEGORIES;
    const customCats = await categoryViewModel.loadCategoriesByType(this.currentTab);

    const result: Array<MixedCategory> = [];

    // 添加预设分类
    groups.forEach((group) => {
      group.children.forEach((child) => {
        result.push({
          key: child.id,
          name: `${group.name}·${child.name}`,
          icon: child.icon,
          isCustom: false,
        });
      });
    });

    // 添加自定义分类
    customCats.forEach((cat) => {
      result.push({
        key: cat.categoryKey,
        name: cat.name,
        icon: cat.icon,
        isCustom: true,
        dbId: cat.id,
      });
    });

    this.categories = result;
  }

  onTabChange(index: number): void {
    this.currentTab = index;
    this.loadCategories();
  }

  openAddDialog(): void {
    this.isEditing = false;
    this.editingDbId = 0;
    this.editCatName = '';
    this.editCatIcon = '📌';
    this.showAddDialog = true;
  }

  openEditDialog(cat: MixedCategory): void {
    if (!cat.isCustom) return;
    this.isEditing = true;
    this.editingDbId = cat.dbId || 0;
    this.editCatName = cat.name;
    this.editCatIcon = cat.icon;
    this.showAddDialog = true;
  }

  async saveCategory(): Promise<void> {
    if (this.editCatName.trim() === '') {
      promptAction.showToast({ message: '请输入分类名称', duration: 2000 });
      return;
    }

    const cat: CustomCategory = {
      id: this.editingDbId,
      categoryKey: `custom_${Date.now()}`,
      name: this.editCatName.trim(),
      icon: this.editCatIcon,
      type: this.currentTab,
      parentId: 'custom',
      isCustom: 1,
      sortOrder: 99,
    };

    try {
      if (this.isEditing) {
        await categoryViewModel.updateCategory(cat);
        promptAction.showToast({ message: '修改成功', duration: 2000 });
      } else {
        await categoryViewModel.addCategory(cat);
        promptAction.showToast({ message: '添加成功', duration: 2000 });
      }
      this.showAddDialog = false;
      await this.loadCategories();
    } catch (e) {
      promptAction.showToast({ message: '操作失败', duration: 2000 });
    }
  }

  async deleteCategory(cat: MixedCategory): Promise<void> {
    if (!cat.isCustom || !cat.dbId) return;
    try {
      await categoryViewModel.deleteCategory(cat.dbId);
      promptAction.showToast({ message: '已删除', duration: 2000 });
      await this.loadCategories();
    } catch (e) {
      promptAction.showToast({ message: '删除失败', duration: 2000 });
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor('#333333')
            .onClick(() => { router.back(); })

          Text('分类管理')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Text('+')
            .fontSize(24)
            .fontColor('#1296db')
            .onClick(() => { this.openAddDialog(); })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        // 收支 Tab
        Row() {
          Button('支出')
            .type(this.currentTab === 0 ? ButtonType.Normal : ButtonType.Capsule)
            .backgroundColor(this.currentTab === 0 ? '#FF5722' : '#F0F0F0')
            .fontColor(this.currentTab === 0 ? '#FFFFFF' : '#999999')
            .layoutWeight(1)
            .onClick(() => { this.onTabChange(0); })

          Button('收入')
            .type(this.currentTab === 1 ? ButtonType.Normal : ButtonType.Capsule)
            .backgroundColor(this.currentTab === 1 ? '#4CAF50' : '#F0F0F0')
            .fontColor(this.currentTab === 1 ? '#FFFFFF' : '#999999')
            .layoutWeight(1)
            .margin({ left: 12 })
            .onClick(() => { this.onTabChange(1); })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })

        // 分类列表
        List() {
          ForEach(this.categories, (cat: MixedCategory) => {
            ListItem() {
              Row() {
                Text(cat.icon)
                  .fontSize(24)
                  .width(40)
                  .height(40)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(20)

                Text(cat.name)
                  .fontSize(15)
                  .fontColor('#333333')
                  .margin({ left: 12 })
                  .layoutWeight(1)

                if (cat.isCustom) {
                  Text('编辑')
                    .fontSize(13)
                    .fontColor('#1296db')
                    .margin({ right: 8 })
                    .onClick(() => { this.openEditDialog(cat); })

                  Text('删除')
                    .fontSize(13)
                    .fontColor('#FF5722')
                    .onClick(() => { this.deleteCategory(cat); })
                } else {
                  Text('预设')
                    .fontSize(12)
                    .fontColor('#CCCCCC')
                }
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            }
          }, (cat: MixedCategory) => cat.key)
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 新增/编辑弹窗
      if (this.showAddDialog) {
        Column() {
          Column() {
            Text(this.isEditing ? '编辑分类' : '新增分类')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            TextInput({ text: this.editCatName, placeholder: '分类名称' })
              .fontSize(15)
              .width('100%')
              .padding(12)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .margin({ bottom: 12 })
              .onChange((value: string) => { this.editCatName = value; })

            // 图标选择
            Text('选择图标')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 8 })

            Grid() {
              ForEach(ICON_OPTIONS, (icon: string) => {
                GridItem() {
                  Text(icon)
                    .fontSize(24)
                    .width('100%')
                    .textAlign(TextAlign.Center)
                    .padding(8)
                    .borderRadius(6)
                    .backgroundColor(this.editCatIcon === icon ? '#E3F2FD' : '#F5F5F5')
                    .border({
                      width: this.editCatIcon === icon ? 1.5 : 0,
                      color: '#1296db'
                    })
                    .onClick(() => { this.editCatIcon = icon; })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(6)
            .columnsGap(6)
            .width('100%')
            .margin({ bottom: 16 })

            Row() {
              Button('取消')
                .backgroundColor('#F0F0F0')
                .fontColor('#666666')
                .layoutWeight(1)
                .onClick(() => { this.showAddDialog = false; })

              Button('保存')
                .backgroundColor('#1296db')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .margin({ left: 12 })
                .onClick(() => { this.saveCategory(); })
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }
        .width('85%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
