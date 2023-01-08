// The MIT License (MIT)
// Copyright © 2022 Ivan Izyumkin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/// The protocol is necessary to hide unnecessary methods with Unicode categories in UnicodeManager
protocol UnicodeManagerProtocol {
    /// Returns relevant emojis for the current iOS version

    var categories: [String] { get }
    var emojis: [Emoji] { get }
    func getEmojisForCurrentIOSVersion() -> [Emoji]
}

final class EmojiJSONManager: UnicodeManagerProtocol {
    
    let categories: [String]
    let emojis: [Emoji]
    
    init() {
        guard let fileUrl = Bundle.module.url(forResource: "emoji", withExtension: "json"),
              let data = try? Data(contentsOf: fileUrl) else {
            self.categories = []
            self.emojis = []
            return
        }
        
        self.emojis = (try? JSONDecoder().decode([Emoji].self, from: data)) ?? []
        self.categories = Array(self.emojis.reduce([String](), { partialResult, emoji in
            let category = emoji.group
            var categories = partialResult
            guard !categories.contains(category) else {
                return categories
            }
            categories.append(category)
            return categories
        }))
    }
    
    func getEmojisForCurrentIOSVersion() -> [Emoji] {
        return emojis
    }
}

/// The class is responsible for getting a relevant set of emojis for iOS version
final class UnicodeManager: UnicodeManagerProtocol {
    var emojis: [Emoji] {
        return getEmojisForCurrentIOSVersion()
    }
    
    var categories: [String] {
        return EmojiCategoryType.allCases.map({ getEmojiCategoryTitle(for: $0) })
    }
    
    private var currentVersion: Float {
        return (UIDevice.current.systemVersion as NSString).floatValue
    }
    
    /// Gets version of iOS for current device
    /// - Returns: Array of emoji categories (and array of emojis inside them)
    public func getEmojisForCurrentIOSVersion() -> [Emoji] {
        switch currentVersion {
        case 12.1...13.1:
            return unicode11.flatMap { category in
                category.emojis.map { ints in
                    return Emoji(codes: "", char: ints.emoji(), name: "", category: "", group: category.categoryName, subgroup: "")
                }
            }
        case 13.2...14.1:
            return unicode12.flatMap { category in
                category.emojis.map { ints in
                    return Emoji(codes: "", char: ints.emoji(), name: "", category: "", group: category.categoryName, subgroup: "")
                }
            }
        case 14.2...14.4:
            return unicode13.flatMap { category in
                category.emojis.map { ints in
                    return Emoji(codes: "", char: ints.emoji(), name: "", category: "", group: category.categoryName, subgroup: "")
                }
            }
        case 14.5...15.3:
            return unicode13v1.flatMap { category in
                category.emojis.map { ints in
                    return Emoji(codes: "", char: ints.emoji(), name: "", category: "", group: category.categoryName, subgroup: "")
                }
            }
        case 15.4...:
            return unicode14.flatMap { category in
                category.emojis.map { ints in
                    return Emoji(codes: "", char: ints.emoji(), name: "", category: "", group: category.categoryName, subgroup: "")
                }
            }
        default:
            return unicode5.flatMap { category in
                category.emojis.map { ints in
                    return Emoji(codes: "", char: ints.emoji(), name: "", category: "", group: category.categoryName, subgroup: "")
                }
            }
        }
    }
    
    /// Returns a localized name for the emoji category.
    /// - Parameter type: Emoji category type
    /// - Returns: Name of the category
    public func getEmojiCategoryTitle(for type: EmojiCategoryType) -> String {
        switch type {
        case .people:
            return NSLocalizedString("emotionsAndPeople", bundle: .module, comment: "")
        case .nature:
            return NSLocalizedString("animalsAndNature", bundle: .module, comment: "")
        case .foodAndDrink:
            return NSLocalizedString("foodAndDrinks", bundle: .module, comment: "")
        case .activity:
            return NSLocalizedString("activities", bundle: .module, comment: "")
        case .travelAndPlaces:
            return NSLocalizedString("travellingAndPlaces", bundle: .module, comment: "")
        case .objects:
            return NSLocalizedString("objects", bundle: .module, comment: "")
        case .symbols:
            return NSLocalizedString("symbols", bundle: .module, comment: "")
        case .flags:
            return NSLocalizedString("flags", bundle: .module, comment: "")
        }
    }
}
