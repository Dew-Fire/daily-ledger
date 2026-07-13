import { relationalStore } from '@kit.ArkData';
import { getRdbStore } from './DatabaseHelper';

/**
 * 自定义分类项
 */
export interface CustomCategory {
  id: number;
  categoryKey: string;
  name: string;
  icon: string;
  type: number;
  parentId: string;
  isCustom: number;
  sortOrder: number;
}

/**
 * 分类数据访问对象
 */
export class CategoryDao {
  private getStore(): relationalStore.RdbStore {
    return getRdbStore();
  }

  /**
   * 插入自定义分类
   */
  async insert(cat: CustomCategory): Promise<number> {
    const store = this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      category_key: cat.categoryKey,
      name: cat.name,
      icon: cat.icon,
      type: cat.type,
      parent_id: cat.parentId,
      is_custom: 1,
      sort_order: cat.sortOrder,
      created_at: Date.now(),
    };
    return await store.insert('categories', valueBucket);
  }

  /**
   * 更新分类
   */
  async update(cat: CustomCategory): Promise<number> {
    const store = this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      name: cat.name,
      icon: cat.icon,
      sort_order: cat.sortOrder,
    };
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('id', cat.id);
    return await store.update(valueBucket, predicates);
  }

  /**
   * 删除分类
   */
  async delete(categoryId: number): Promise<number> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('id', categoryId);
    return await store.delete(predicates);
  }

  /**
   * 查询所有自定义分类
   */
  async queryAll(): Promise<Array<CustomCategory>> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.orderByAsc('sort_order');

    const resultSet = await store.query(predicates);
    const categories: Array<CustomCategory> = [];

    try {
      while (resultSet.goToNextRow()) {
        categories.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          categoryKey: resultSet.getString(resultSet.getColumnIndex('category_key')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          icon: resultSet.getString(resultSet.getColumnIndex('icon')),
          type: resultSet.getLong(resultSet.getColumnIndex('type')),
          parentId: resultSet.getString(resultSet.getColumnIndex('parent_id')),
          isCustom: resultSet.getLong(resultSet.getColumnIndex('is_custom')),
          sortOrder: resultSet.getLong(resultSet.getColumnIndex('sort_order')),
        });
      }
    } finally {
      resultSet.close();
    }
    return categories;
  }

  /**
   * 按类型查询自定义分类
   */
  async queryByType(type: number): Promise<Array<CustomCategory>> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('categories');
    predicates.equalTo('type', type).orderByAsc('sort_order');

    const resultSet = await store.query(predicates);
    const categories: Array<CustomCategory> = [];

    try {
      while (resultSet.goToNextRow()) {
        categories.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          categoryKey: resultSet.getString(resultSet.getColumnIndex('category_key')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          icon: resultSet.getString(resultSet.getColumnIndex('icon')),
          type: resultSet.getLong(resultSet.getColumnIndex('type')),
          parentId: resultSet.getString(resultSet.getColumnIndex('parent_id')),
          isCustom: resultSet.getLong(resultSet.getColumnIndex('is_custom')),
          sortOrder: resultSet.getLong(resultSet.getColumnIndex('sort_order')),
        });
      }
    } finally {
      resultSet.close();
    }
    return categories;
  }
}
