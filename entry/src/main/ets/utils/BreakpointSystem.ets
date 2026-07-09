/**
 * 断点系统 — 一多适配
 * 根据屏幕宽度自动切换布局模式
 */
export enum BreakpointType {
  SM = 'sm',     // 手机竖屏 < 600vp
  MD = 'md',     // 手机横屏 / 小平板 600-840vp
  LG = 'lg',     // 平板 > 840vp
}

export class BreakpointSystem {
  current: BreakpointType = BreakpointType.SM;

  private widthBp: number = 0;
  private heightBp: number = 0;

  /**
   * 根据窗口尺寸更新断点
   */
  update(widthVp: number, heightVp: number): void {
    this.widthBp = widthVp;
    this.heightBp = heightVp;

    if (widthVp >= 840) {
      this.current = BreakpointType.LG;
    } else if (widthVp >= 600) {
      this.current = BreakpointType.MD;
    } else {
      this.current = BreakpointType.SM;
    }
  }

  isPhone(): boolean {
    return this.current === BreakpointType.SM;
  }

  isTablet(): boolean {
    return this.current === BreakpointType.MD || this.current === BreakpointType.LG;
  }

  /**
   * 获取响应式列数
   */
  getGridColumns(): number {
    if (this.current === BreakpointType.LG) return 3;
    if (this.current === BreakpointType.MD) return 2;
    return 1;
  }

  /**
   * 获取内容最大宽度
   */
  getMaxWidth(): number {
    if (this.current === BreakpointType.LG) return 800;
    return this.widthBp;
  }

  /**
   * 获取分类网格列数
   */
  getCategoryColumns(): number {
    if (this.current === BreakpointType.LG) return 8;
    if (this.current === BreakpointType.MD) return 6;
    return 4;
  }
}

// 全局限定器实例
export const breakpointSystem = new BreakpointSystem();
