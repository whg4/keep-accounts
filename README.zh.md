# Keep Accounts 记账

[English](README.md) | **中文**

一款使用 SwiftUI 构建的 iOS 个人记账应用，支持收支记录、预算管理、统计分析和 iCloud 云同步。

## 功能特性

### 💰 收支记录
- 支持收入与支出两种交易类型
- 金额输入带货币格式化
- 分类选择（支持父子层级分类）
- 标签管理，灵活标记交易
- 日期选择与备注记录
- 按月份、日期分组展示账单

### 📊 统计分析
- 月度 / 年度多维度统计
- 饼图展示各分类占比
- 折线图展示收支趋势
- 汇总卡片：总收入、总支出、结余、日均支出、最大单笔交易

### 📋 预算管理
- 设置月度总预算
- 按分类设置预算上限
- 环形进度条可视化预算使用情况
- 超支预警提示

### 🔍 搜索与筛选
- 全文搜索（备注、分类名、标签、金额）
- 按交易类型、分类、日期范围筛选

### 🏷️ 分类与标签
- 10 个预设支出分类（餐饮、交通、购物、住房等），含子分类
- 5 个预设收入分类（工资、奖金、投资、兼职等）
- 自定义分类：20+ 图标、15+ 颜色可选
- 自定义标签，支持多标签关联

### ⚙️ 设置与数据
- CSV 导出全部交易记录
- iCloud 自动云同步
- 多语言支持（简体中文 / English / 跟随系统）

## 技术栈

| 技术 | 说明 |
|------|------|
| SwiftUI | 声明式 UI 框架 |
| SwiftData | 数据持久化 |
| CloudKit | iCloud 云同步 |
| Swift Charts | 图表可视化 |

## 项目结构

```
keep-accounts/
├── Models/                  # 数据模型
│   ├── Transaction.swift    # 交易记录
│   ├── Category.swift       # 分类（支持父子层级）
│   ├── Budget.swift         # 预算
│   ├── Tag.swift            # 标签
│   └── TransactionType.swift # 交易类型枚举
├── Views/                   # 视图层
│   ├── MainTabView.swift    # 底部 Tab 导航
│   ├── Home/                # 首页（账单列表）
│   ├── Statistics/          # 统计（饼图、折线图、汇总卡片）
│   ├── Budget/              # 预算（总览与设置）
│   ├── Search/              # 搜索
│   ├── Settings/            # 设置
│   ├── Category/            # 分类管理
│   ├── Tag/                 # 标签管理
│   ├── Transaction/         # 添加交易
│   └── Components/          # 通用组件
├── Data/                    # 预设数据
│   └── PresetCategories.swift
├── Extensions/              # 扩展
│   ├── Color+Extensions.swift
│   ├── Date+Extensions.swift
│   └── Decimal+Extensions.swift
└── Localizable.xcstrings    # 国际化字符串
```

## 环境要求

- Xcode 16+
- iOS 17+
- Swift 5.9+

## 构建运行

```bash
git clone <repo-url>
cd keep-accounts
open keep-accounts.xcodeproj
```

在 Xcode 中选择目标设备，点击 **Run (⌘R)** 即可运行。

## License

MIT
