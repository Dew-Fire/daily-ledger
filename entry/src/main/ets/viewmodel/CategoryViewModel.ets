import { CategoryDao } from '../database/CategoryDao';
import type { CustomCategory } from '../database/CategoryDao';

/**
 * 分类业务逻辑层
 */
class CategoryViewModel {
  private dao: CategoryDao = new CategoryDao();

  /**
   * 加载所有自定义分类
   */
  async loadCategories(): Promise<Array<CustomCategory>> {
    return await this.dao.queryAll();
  }

  /**
   * 按类型加载自定义分类
   */
  async loadCategoriesByType(type: number): Promise<Array<CustomCategory>> {
    return await this.dao.queryByType(type);
  }

  /**
   * 新增自定义分类
   */
  async addCategory(cat: CustomCategory): Promise<void> {
    await this.dao.insert(cat);
  }

  /**
   * 更新分类
   */
  async updateCategory(cat: CustomCategory): Promise<void> {
    await this.dao.update(cat);
  }

  /**
   * 删除分类
   */
  async deleteCategory(categoryId: number): Promise<void> {
    await this.dao.delete(categoryId);
  }
}

export const categoryViewModel = new CategoryViewModel();
