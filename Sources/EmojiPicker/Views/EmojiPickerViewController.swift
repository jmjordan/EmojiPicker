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
import Combine

public protocol EmojiPickerDelegate: AnyObject {
    func didGetEmoji(emoji: String)
}

final class EmojiPickerViewController: UIViewController {
    /// Delegate for selecting an emoji object
    public weak var delegate: EmojiPickerDelegate?
    
    /**
     The direction of the arrow for EmojiPicker.
     
     The default value of this property is `.up`.
     */
    public var arrowDirection: PickerArrowDirectionMode = .up
    
    /**
     Custom height for EmojiPicker.
     But it will be limited by the distance from `sourceView.origin.y` to the upper or lower bound(depends on `permittedArrowDirections`).
     
     The default value of this property is `nil`.
     */
    public var customHeight: CGFloat? = nil
    
    /**
     Inset from the sourceView border.
     
     The default value of this property is `0`.
     */
    public var horizontalInset: CGFloat = 0
    
    /**
     A boolean value that determines whether the screen will be hidden after the emoji is selected.
     
     If this property’s value is true, the EmojiPicker will be dismissed after the emoji is selected.
     
     If you want EmojiPicker not to dismissed after emoji selection, you must set this property to false.
     
     The default value of this property is `true`.
     */
    public var isDismissAfterChoosing: Bool = true
    
    /**
     Color for the selected emoji category.
     
     The default value of this property is `.systemBlue`.
     */
    public var selectedEmojiCategoryTintColor: UIColor? {
        didSet {
            guard let selectedEmojiCategoryTintColor = selectedEmojiCategoryTintColor else { return }
            emojiPickerView.selectedEmojiCategoryTintColor = selectedEmojiCategoryTintColor
        }
    }
    
    /// The view containing the anchor rectangle for the popover
    public var sourceView: UIView? {
        didSet {
            popoverPresentationController?.sourceView = sourceView
        }
    }
    
    /**
     Feedback generator style. To turn off, set `nil` to this parameter.
     
     The default value of this property is `.light`.
     */
    public var feedBackGeneratorStyle: UIImpactFeedbackGenerator.FeedbackStyle? = .light {
        didSet {
            guard let feedBackGeneratorStyle = feedBackGeneratorStyle else {
                generator = nil
                return
            }
            generator = UIImpactFeedbackGenerator(style: feedBackGeneratorStyle)
        }
    }
    
    private let emojiPickerView = EmojiPickerView()
    private var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
    private var viewModel: EmojiPickerViewModelProtocol
    private var dataSource: UICollectionViewDiffableDataSource<String, String>!
    
    var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: EmojiPickerViewModelProtocol = EmojiPickerViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupPopoverPresentationStyle()
        setupDelegates()
        setupDataSource()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func loadView() {
        view = emojiPickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreferredContentSize()
        setupArrowDirections()
        setupHorizontalInset()
        
        view.backgroundColor = .systemGroupedBackground
        
    }
    
    // MARK: - Private methods
    private func bindViewModel() {
        
        viewModel.snapshotPublisher.sink { snapshot in
            self.dataSource.apply(snapshot)
        }.store(in: &subscriptions)
        
        viewModel.selectedEmoji.bind { [unowned self] emoji in
            generator?.impactOccurred()
            delegate?.didGetEmoji(emoji: emoji)
            if isDismissAfterChoosing {
                dismiss(animated: true, completion: nil)
            }
        }
        
        viewModel.selectedEmojiCategoryIndex.bind { [unowned self] categoryIndex in
            self.emojiPickerView.updateSelectedCategoryIcon(with: categoryIndex)
        }
    }
    
    private func setupDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<EmojiCollectionViewCell, String> { cell, indexPath, item in
            cell.emoji = item
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<EmojiCollectionViewHeader>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
            
            guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else { return }
            
            supplementaryView.categoryName = section.uppercased()
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: emojiPickerView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func setupDelegates() {
        emojiPickerView.delegate = self
        emojiPickerView.collectionView.delegate = self
        emojiPickerView.searchField.delegate = self
        presentationController?.delegate = self
    }
    
    private func setupPopoverPresentationStyle() {
        modalPresentationStyle = .popover
    }
    
    private func setupPreferredContentSize() {
        let sideInset: CGFloat = 10
        let screenWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
        let popoverWidth: CGFloat = min(screenWidth - (sideInset * 2), 400)
        // The number 0.16 was taken based on the proportion of height to the width of the EmojiPicker on MacOS.
        let heightProportionToWidth: CGFloat = 1.16
        preferredContentSize = CGSize(
            width: popoverWidth,
            height: customHeight ?? popoverWidth * heightProportionToWidth
        )
    }
    
    private func setupArrowDirections() {
        popoverPresentationController?.permittedArrowDirections = [.any]
    }
    
    private func setupHorizontalInset() {
        guard let sourceView = sourceView else { return }
        popoverPresentationController?.sourceRect = CGRect(
            x: 0,
            y: 0,
            width: sourceView.frame.width,
            height: sourceView.frame.height
        )
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension EmojiPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.selectedEmoji.value = dataSource.itemIdentifier(for: indexPath) ?? ""
    }
}

// MARK: - UIScrollViewDelegate
extension EmojiPickerViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // Updating the selected category during scrolling
//        let indexPathsForVisibleHeaders = emojiPickerView.collectionView.indexPathsForVisibleSupplementaryElements(
//            ofKind: UICollectionView.elementKindSectionHeader
//        ).sorted(by: { $0.section < $1.section })
//
//        DispatchQueue.main.sync {
//            if let selectedEmojiCategoryIndex = indexPathsForVisibleHeaders.first?.section,
//               viewModel.selectedEmojiCategoryIndex.value != selectedEmojiCategoryIndex {
//                viewModel.selectedEmojiCategoryIndex.value = selectedEmojiCategoryIndex
//            }
//        }
//    }
}

// MARK: - EmojiPickerViewDelegate
extension EmojiPickerViewController: EmojiPickerViewDelegate {
    func didChoiceEmojiCategory(at index: Int) {
        generator?.impactOccurred()
        viewModel.selectedEmojiCategoryIndex.value = index
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension EmojiPickerViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension EmojiPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search = searchText
    }
}
