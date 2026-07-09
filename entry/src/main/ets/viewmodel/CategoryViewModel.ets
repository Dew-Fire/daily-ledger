import { CategoryDao, type CustomCategory } from '../database/CategoryDao';
import { EXPENSE_CATEGORIES, INCOME_CATEGORIES, type FlatCategoryItem, type CategoryGroup, type SubCategory } from '../model/CategoryModel';

export interface FlatCategory {
  id: string;
  name: string;
  icon: string;
  isCustom: boolean;
  dbId?: number;
}

/**
 * 分类业务逻辑层
 */
class CategoryViewModel {
  private dao: CategoryDao = new CategoryDao();

  async loadCategories(): Promise<Array<CustomCategory>> {
    return await this.dao.queryAll();
  }

  async loadCategoriesByType(type: number): Promise<Array<CustomCategory>> {
    return await this.dao.queryByType(type);
  }

  async addCategory(cat: CustomCategory): Promise<void> {
    await this.dao.insert(cat);
  }

  async updateCategory(cat: CustomCategory): Promise<void> {
    await this.dao.update(cat);
  }

  async deleteCategory(categoryId: number): Promise<void> {
    await this.dao.delete(categoryId);
  }

  /**
   * 获取所有分类（预设 + 自定义），用于选择器
   */
  async getAllCategories(type: number): Promise<Array<FlatCategory>> {
    const groups = type === 0 ? EXPENSE_CATEGORIES : INCOME_CATEGORIES;
    const customCats = await this.dao.queryByType(type);
    const result: Array<FlatCategory> = [];

    // 预设二级分类
    groups.forEach((group: CategoryGroup) => {
      group.children.forEach((child: SubCategory) => {
        result.push({
          id: child.id,
          name: `${group.name}·${child.name}`,
          icon: child.icon,
          isCustom: false,
        });
      });
    });

    // 自定义分类
    customCats.forEach((cat: CustomCategory) => {
      result.push({
        id: cat.categoryKey,
        name: cat.name,
        icon: cat.icon,
        isCustom: true,
        dbId: cat.id,
      });
    });

    return result;
  }
}

export const categoryViewModel = new CategoryViewModel();
