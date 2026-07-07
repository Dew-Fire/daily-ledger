/**
 * 分类数据模型 — 二级分类体系
 * 一级分类为大类（餐饮、交通等），二级分类为细分项
 */

// 二级分类项
export interface SubCategory {
  id: string;
  name: string;
  icon: string;
}

// 一级分类组（含二级子分类）
export interface CategoryGroup {
  id: string;
  name: string;
  icon: string;
  type: number;                       // 0: 支出, 1: 收入
  children: Array<SubCategory>;       // 二级分类列表
}

// ==== 支出分类（一级 + 二级）====
export const EXPENSE_CATEGORIES: Array<CategoryGroup> = [
  {
    id: 'food', name: '餐饮', icon: '🍽️', type: 0,
    children: [
      { id: 'food_breakfast', name: '早餐', icon: '🥛' },
      { id: 'food_lunch', name: '午餐', icon: '🍱' },
      { id: 'food_dinner', name: '晚餐', icon: '🍲' },
      { id: 'food_snack', name: '零食', icon: '🍿' },
    ]
  },
  {
    id: 'transport', name: '交通', icon: '🚌', type: 0,
    children: [
      { id: 'transport_bus', name: '公交', icon: '🚌' },
      { id: 'transport_metro', name: '地铁', icon: '🚇' },
      { id: 'transport_taxi', name: '打车', icon: '🚕' },
      { id: 'transport_fuel', name: '加油', icon: '⛽' },
    ]
  },
  {
    id: 'shopping', name: '购物', icon: '🛒', type: 0,
    children: [
      { id: 'shopping_clothes', name: '服饰', icon: '👗' },
      { id: 'shopping_daily', name: '日用品', icon: '🧴' },
      { id: 'shopping_digital', name: '数码', icon: '📱' },
      { id: 'shopping_home', name: '家居', icon: '🛋️' },
    ]
  },
  {
    id: 'entertainment', name: '娱乐', icon: '🎮', type: 0,
    children: [
      { id: 'entertainment_movie', name: '电影', icon: '🎬' },
      { id: 'entertainment_game', name: '游戏', icon: '🎮' },
      { id: 'entertainment_travel', name: '旅游', icon: '✈️' },
      { id: 'entertainment_sport', name: '运动', icon: '⚽' },
    ]
  },
  {
    id: 'housing', name: '居家', icon: '🏠', type: 0,
    children: [
      { id: 'housing_rent', name: '房租', icon: '🏠' },
      { id: 'housing_utility', name: '水电', icon: '💡' },
      { id: 'housing_decorate', name: '装修', icon: '🔨' },
      { id: 'housing_property', name: '物业', icon: '📋' },
    ]
  },
  {
    id: 'medical', name: '医疗', icon: '💊', type: 0,
    children: [
      { id: 'medical_doctor', name: '门诊', icon: '🏥' },
      { id: 'medical_medicine', name: '药品', icon: '💊' },
      { id: 'medical_checkup', name: '体检', icon: '🩺' },
    ]
  },
  {
    id: 'education', name: '教育', icon: '📚', type: 0,
    children: [
      { id: 'education_book', name: '书籍', icon: '📖' },
      { id: 'education_course', name: '课程', icon: '💻' },
      { id: 'education_exam', name: '考试', icon: '📝' },
    ]
  },
  {
    id: 'other_expense', name: '其他支出', icon: '📌', type: 0,
    children: [
      { id: 'other_expense_general', name: '其他', icon: '📌' },
    ]
  },
];

// ==== 收入分类（一级 + 二级）====
export const INCOME_CATEGORIES: Array<CategoryGroup> = [
  {
    id: 'salary', name: '工资', icon: '💰', type: 1,
    children: [
      { id: 'salary_base', name: '基本工资', icon: '💰' },
      { id: 'salary_overtime', name: '加班费', icon: '⏰' },
      { id: 'salary_subsidy', name: '补贴', icon: '📋' },
    ]
  },
  {
    id: 'bonus', name: '奖金', icon: '🎁', type: 1,
    children: [
      { id: 'bonus_year', name: '年终奖', icon: '🎉' },
      { id: 'bonus_project', name: '项目奖', icon: '🏆' },
    ]
  },
  {
    id: 'investment', name: '投资', icon: '📈', type: 1,
    children: [
      { id: 'investment_stock', name: '股票', icon: '📊' },
      { id: 'investment_fund', name: '基金', icon: '💹' },
      { id: 'investment_interest', name: '利息', icon: '🏦' },
    ]
  },
  {
    id: 'parttime', name: '兼职', icon: '💼', type: 1,
    children: [
      { id: 'parttime_freelance', name: '自由职业', icon: '✍️' },
      { id: 'parttime_tutor', name: '家教', icon: '👨‍🏫' },
    ]
  },
  {
    id: 'other_income', name: '其他收入', icon: '📌', type: 1,
    children: [
      { id: 'other_income_redpacket', name: '红包', icon: '🧧' },
      { id: 'other_income_refund', name: '退款', icon: '↩️' },
      { id: 'other_income_general', name: '其他', icon: '📌' },
    ]
  },
];

/**
 * 根据类型获取分类列表
 */
export function getCategoriesByType(type: number): Array<CategoryGroup> {
  return type === 0 ? EXPENSE_CATEGORIES : INCOME_CATEGORIES;
}

/**
 * 获取所有一级分类（扁平化用于快速展示）
 */
export function getFlatCategoryList(type: number): Array<{ id: string; name: string; icon: string }> {
  const groups = getCategoriesByType(type);
  const result: Array<{ id: string; name: string; icon: string }> = [];
  groups.forEach((group) => {
    group.children.forEach((child) => {
      result.push({ id: child.id, name: `${group.name}·${child.name}`, icon: child.icon });
    });
  });
  return result;
}
