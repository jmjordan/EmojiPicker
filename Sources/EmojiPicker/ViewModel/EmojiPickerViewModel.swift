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

import Foundation
import Combine
import UIKit

/// Protocol for the ViewModel which using in EmojiPickerViewController
protocol EmojiPickerViewModelProtocol {
    /// The observed variable that is responsible for the choice of emoji
    var selectedEmoji: Observable<String> { get set }
    
    /// The observed variable that is responsible for the choice of emoji category
    var selectedEmojiCategoryIndex: Observable<Int> { get set }
    
    var snapshotPublisher: Published<NSDiffableDataSourceSnapshot<String, String>>.Publisher { get }
    
    var search: String? { get set }
}

/// ViewModel which using in EmojiPickerViewController
final class EmojiPickerViewModel: EmojiPickerViewModelProtocol {
    
    public var selectedEmoji = Observable<String>(value: "")
    public var selectedEmojiCategoryIndex = Observable<Int>(value: 0)
    
    @Published public var emojiSnapshot: NSDiffableDataSourceSnapshot<String, String>
    
    public var snapshotPublisher: Published<NSDiffableDataSourceSnapshot<String, String>>.Publisher { return $emojiSnapshot }
    
    var categories: [EmojiCategory]
    
    var search: String? = nil {
        didSet {
            guard let search = search, search != "" else { return
                self.emojiSnapshot  = categories.reduce(NSDiffableDataSourceSnapshot<String, String>(), { partialResult, category in
                    var result = partialResult
                    result.appendSections([category.name])
                    result.appendItems(category.emojis.map { $0.emoji})
                    return result
                })
            }
            
            var snapshot = NSDiffableDataSourceSnapshot<String, String>()
            let emojis = categories.flatMap({ category in
                return category.emojis.filter({ $0.name.lowercased().contains(search.lowercased()) })
            }).map({ $0.emoji })
            snapshot.appendSections([""])
            snapshot.appendItems(emojis)
            self.emojiSnapshot = snapshot
        }
    }
    
    init(emojiManager: EmojiManagerProtocol = UnicodeEmojiManager()) {
        self.categories = emojiManager.categories
        
        self.emojiSnapshot = emojiManager.categories.reduce(NSDiffableDataSourceSnapshot<String, String>(), { partialResult, category in
            var result = partialResult
            result.appendSections([category.name])
            result.appendItems(category.emojis.map { $0.emoji})
            return result
        })
    }

}
