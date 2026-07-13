import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { initDatabase } from '../database/DatabaseHelper';
import { BudgetChecker } from '../utils/BudgetChecker';

const budgetChecker = new BudgetChecker();

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'DailyLedger', '%{public}s', 'Ability onCreate');
    await initDatabase(this.context);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'DailyLedger', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'DailyLedger', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'DailyLedger', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'DailyLedger', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'DailyLedger', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'DailyLedger', '%{public}s', 'Ability onForeground');
    // 每次回到前台检查预算
    budgetChecker.checkAndNotify();
  }

  onBackground(): void {
    hilog.info(0x0000, 'DailyLedger', '%{public}s', 'Ability onBackground');
  }
}
