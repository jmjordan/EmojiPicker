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

/// Describes types of emoji categories
public enum EmojiCategoryType: Int, CaseIterable {
    case people
    case nature
    case foodAndDrink
    case activity
    case travelAndPlaces
    case objects
    case symbols
    case flags
}

//{
//    "codes": "1F3F4 E0067 E0062 E0077 E006C E0073 E007F",
//    "char": "🏴󠁧󠁢󠁷󠁬󠁳󠁿",
//    "name": "flag: Wales",
//    "category": "Flags (subdivision-flag)",
//    "group": "Flags",
//    "subgroup": "subdivision-flag"
//  }

public struct Emoji: Codable {
    let emoji: String
    let name: String
    let unicodeVersion: String
    
    enum CodingKeys: String, CodingKey {
        case emoji
        case name
        case unicodeVersion = "unicode_version"
    }
}

/// Describes emoji categories
public struct EmojiCategory: Codable {
    var name: String
    var emojis: [Emoji]
}
