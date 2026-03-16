import Foundation
import SwiftData

struct PresetCategories {

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.isPreset == true }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        // MARK: - 支出分类
        let expenseData: [(String, String, String, [(String, String)])] = [
            ("餐饮", "fork.knife", "FF6B6B", [
                ("早餐", "sunrise"), ("午餐", "sun.max"), ("晚餐", "moon"),
                ("零食", "cup.and.saucer"), ("饮料", "mug")
            ]),
            ("交通", "car", "4ECDC4", [
                ("公交地铁", "tram"), ("打车", "car.side"), ("加油", "fuelpump"),
                ("停车", "parkingsign"), ("机票火车", "airplane")
            ]),
            ("购物", "cart", "45B7D1", [
                ("日用品", "bag"), ("数码", "desktopcomputer"), ("家居", "sofa"),
                ("美妆", "sparkles"), ("其他", "ellipsis.circle")
            ]),
            ("住房", "house", "96CEB4", [
                ("房租", "key"), ("水电", "bolt"), ("物业", "building.2"),
                ("维修", "wrench.and.screwdriver"), ("家具", "bed.double")
            ]),
            ("娱乐", "gamecontroller", "DDA0DD", [
                ("电影", "film"), ("游戏", "gamecontroller"), ("运动", "figure.run"),
                ("旅行", "airplane.departure"), ("其他", "ellipsis.circle")
            ]),
            ("医疗", "cross.case", "FFB347", [
                ("挂号", "stethoscope"), ("药品", "pills"), ("体检", "heart.text.clipboard"),
                ("保险", "shield.checkered"), ("其他", "ellipsis.circle")
            ]),
            ("教育", "book", "87CEEB", [
                ("书籍", "books.vertical"), ("课程", "graduationcap"), ("培训", "person.and.background.dotted"),
                ("文具", "pencil.and.ruler"), ("其他", "ellipsis.circle")
            ]),
            ("通讯", "phone", "98D8C8", [
                ("话费", "phone.arrow.up.right"), ("网费", "wifi"), ("会员", "crown"),
                ("其他", "ellipsis.circle")
            ]),
            ("服饰", "tshirt", "F7DC6F", [
                ("衣服", "tshirt"), ("鞋子", "shoe"), ("配饰", "eyeglasses"),
                ("其他", "ellipsis.circle")
            ]),
            ("其他", "ellipsis.circle", "BDC3C7", [])
        ]

        for (index, item) in expenseData.enumerated() {
            let parent = Category(
                name: item.0, icon: item.1, colorHex: item.2,
                type: .expense, isPreset: true, sortOrder: index
            )
            context.insert(parent)
            for (subIndex, sub) in item.3.enumerated() {
                let child = Category(
                    name: sub.0, icon: sub.1, colorHex: item.2,
                    type: .expense, isPreset: true, sortOrder: subIndex, parent: parent
                )
                context.insert(child)
            }
        }

        // MARK: - 收入分类
        let incomeData: [(String, String, String)] = [
            ("工资", "yensign.circle", "2ECC71"),
            ("奖金", "gift", "F39C12"),
            ("投资", "chart.line.uptrend.xyaxis", "3498DB"),
            ("兼职", "briefcase", "9B59B6"),
            ("其他", "ellipsis.circle", "BDC3C7"),
        ]

        for (index, item) in incomeData.enumerated() {
            let cat = Category(
                name: item.0, icon: item.1, colorHex: item.2,
                type: .income, isPreset: true, sortOrder: index
            )
            context.insert(cat)
        }

        try? context.save()
    }
}
