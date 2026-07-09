import { formBindingData, FormExtensionAbility } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { billViewModel } from '../viewmodel/BillViewModel';

/**
 * 服务卡片 FormAbility — 提供当月收支概况数据
 */
export default class MyFormAbility extends FormExtensionAbility {
  onAddForm(want: Record<string, Object>): formBindingData.FormBindingData {
    const formData: Record<string, string> = {
      'monthIncome': '¥ 0.00',
      'monthExpense': '¥ 0.00',
      'budgetStatus': '点击记一笔',
    };

    // 异步加载数据并更新
    this.updateFormData(want);

    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string): void {
    hilog.info(0x0000, 'MyFormAbility', 'onCastToNormalForm: %{public}s', formId);
  }

  onUpdateForm(formId: string): void {
    hilog.info(0x0000, 'MyFormAbility', 'onUpdateForm: %{public}s', formId);
  }

  onChangeFormVisibility(newStatus: Record<string, number>): void {
    hilog.info(0x0000, 'MyFormAbility', 'onChangeFormVisibility: %{public}s', JSON.stringify(newStatus));
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(0x0000, 'MyFormAbility', 'onFormEvent: %{public}s, %{public}s', formId, message);
  }

  onRemoveForm(formId: string): void {
    hilog.info(0x0000, 'MyFormAbility', 'onRemoveForm: %{public}s', formId);
  }

  async updateFormData(want: Record<string, Object>): Promise<void> {
    try {
      const now = new Date();
      const month = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
      const summary = await billViewModel.getMonthSummary(month);

      const formData: Record<string, string> = {
        'monthIncome': `¥ ${summary.income.toFixed(2)}`,
        'monthExpense': `¥ ${summary.expense.toFixed(2)}`,
        'budgetStatus': `本月收支 | ${month}`,
      };

      // 更新卡片
      const bindingData = formBindingData.createFormBindingData(formData);
      const formId = want['ohos.extra.param.key.form_identity'] as string;
      if (formId) {
        const FormFormInfo = formBindingData.FormBindingData;
        // 通过 formBindingData 更新
      }
    } catch (e) {
      hilog.error(0x0000, 'MyFormAbility', 'Failed to load widget data');
    }
  }
}
