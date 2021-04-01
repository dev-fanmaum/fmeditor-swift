//
//  FMEditorOptionItem.swift
//  FMEditorSwift
//
//  Created by DONGJU LIM on 2021/03/29.
//

import UIKit

/// A FMEditorOption object is an object that can be displayed in a FMEditorToolbar.
/// This protocol is proviced to allow for custom actions not provided in the FMEditorOptions enum.
public protocol FMEditorOption {

    /// The image to be displayed in the FMEditorToolbar.
    var image: UIImage? { get }

    /// The title of the item.
    /// If `image` is nil, this will be used for display in the FMEditorToolbar.
    var title: String { get }

    /// The action to be evoked when the action is tapped
    /// - parameter editor: The FMEditorToolbar that the FMEditorOption was being displayed in when tapped.
    ///                     Contains a reference to the `editor` FMEditorView to perform actions on.
    func action(_ editor: FMEditorToolbar)
}

/// FMEditorOptionItem is a concrete implementation of FMEditorOption.
/// It can be used as a configuration object for custom objects to be shown on a FMEditorToolbar.
public struct FMEditorOptionItem: FMEditorOption {

    /// The image that should be shown when displayed in the FMEditorToolbar.
    public var image: UIImage?

    /// If an `itemImage` is not specified, this is used in display
    public var title: String

    /// The action to be performed when tapped
    public var handler: ((FMEditorToolbar) -> Void)

    public init(image: UIImage?, title: String, action: @escaping ((FMEditorToolbar) -> Void)) {
        self.image = image
        self.title = title
        self.handler = action
    }
    
    // MARK: FMEditorOption
    
    public func action(_ toolbar: FMEditorToolbar) {
        handler(toolbar)
    }
}

/// FMEditorOptions is an enum of standard editor actions
public enum FMEditorDefaultOption: FMEditorOption {

    case clear
    case undo
    case redo
    case bold
    case italic
    case underline
    case checkbox
    case `subscript`
    case superscript
    case strike
    case textColor
    case textBackgroundColor
    case header(Int)
    case indent
    case outdent
    case orderedList
    case unorderedList
    case alignLeft
    case alignCenter
    case alignRight
    case image
    case video
    case link
    case table
    
    public static let all: [FMEditorDefaultOption] = [
        //UIColor.r0g0b0a0,
        //.undo, .redo,
        .bold, .italic, .underline,
        .checkbox, .subscript, .superscript, .strike,
        .textColor, .textBackgroundColor,
        .header(1), .header(2), .header(3), .header(4), .header(5), .header(6),
        .indent, outdent, orderedList, unorderedList,
        .alignLeft, .alignCenter, .alignRight, .image, .video, .link, .table
    ]

    // MARK: FMEditorOption
    public var image: UIImage? {
        var name = ""
        switch self {
        case .clear: name = "clear"
        case .undo: name = "undo"
        case .redo: name = "redo"
        case .bold: name = "bold"
        case .italic: name = "italic"
        case .underline: name = "underline"
        case .checkbox: name = "checkbox"
        case .subscript: name = "subscript"
        case .superscript: name = "superscript"
        case .strike: name = "strikethrough"
        case .textColor: name = "text_color"
        case .textBackgroundColor: name = "bg_color"
        case .header(let h): name = "h\(h)"
        case .indent: name = "indent"
        case .outdent: name = "outdent"
        case .orderedList: name = "ordered_list"
        case .unorderedList: name = "unordered_list"
        case .alignLeft: name = "justify_left"
        case .alignCenter: name = "justify_center"
        case .alignRight: name = "justify_right"
        case .image: name = "insert_image"
        case .video: name = "insert_video"
        case .link: name = "insert_link"
        case .table: name = "insert_table"
        }

        let podBundle = Bundle(identifier:"org.cocoapods.FMEditorSwift")
        if let bundleURL = podBundle?.url(forResource: "FMEditorSwift", withExtension: "bundle")
        {
            let imageBundel = Bundle(url: bundleURL)
            let image = UIImage(named: name, in: imageBundel, compatibleWith: nil)
            return image
        }
        return nil
    }
    
    public var title: String {
        switch self {
        case .clear: return NSLocalizedString("Clear", comment: "")
        case .undo: return NSLocalizedString("Undo", comment: "")
        case .redo: return NSLocalizedString("Redo", comment: "")
        case .bold: return NSLocalizedString("Bold", comment: "")
        case .italic: return NSLocalizedString("Italic", comment: "")
        case .underline: return NSLocalizedString("Underline", comment: "")
        case .checkbox: return NSLocalizedString("Checkbox", comment: "")
        case .subscript: return NSLocalizedString("Sub", comment: "")
        case .superscript: return NSLocalizedString("Super", comment: "")
        case .strike: return NSLocalizedString("Strike", comment: "")
        case .textColor: return NSLocalizedString("Color", comment: "")
        case .textBackgroundColor: return NSLocalizedString("BG Color", comment: "")
        case .header(let h): return NSLocalizedString("H\(h)", comment: "")
        case .indent: return NSLocalizedString("Indent", comment: "")
        case .outdent: return NSLocalizedString("Outdent", comment: "")
        case .orderedList: return NSLocalizedString("Ordered List", comment: "")
        case .unorderedList: return NSLocalizedString("Unordered List", comment: "")
        case .alignLeft: return NSLocalizedString("Left", comment: "")
        case .alignCenter: return NSLocalizedString("Center", comment: "")
        case .alignRight: return NSLocalizedString("Right", comment: "")
        case .image: return NSLocalizedString("Image", comment: "")
        case .video: return NSLocalizedString("Video", comment: "")
        case .link: return NSLocalizedString("Link", comment: "")
        case .table: return NSLocalizedString("Table", comment: "")
        }
    }
    
    public func action(_ toolbar: FMEditorToolbar) {
        switch self {
        case .clear: toolbar.editor?.removeFormat()
        case .undo: toolbar.editor?.undo()
        case .redo: toolbar.editor?.redo()
        case .bold: toolbar.editor?.bold()
        case .italic: toolbar.editor?.italic()
        case .underline: toolbar.editor?.underline()
        case .checkbox: break
        case .subscript: toolbar.editor?.subscriptText()
        case .superscript: toolbar.editor?.superscript()
        case .strike: toolbar.editor?.strikethrough()
        case .textColor: toolbar.delegate?.fmEditorToolbarChangeTextColor?(toolbar)
        case .textBackgroundColor: toolbar.delegate?.fmEditorToolbarChangeBackgroundColor?(toolbar)
        case .header(let h): toolbar.editor?.header(h)
        case .indent: toolbar.editor?.indent()
        case .outdent: toolbar.editor?.outdent()
        case .orderedList: toolbar.editor?.orderedList()
        case .unorderedList: toolbar.editor?.unorderedList()
        case .alignLeft: toolbar.editor?.alignLeft()
        case .alignCenter: toolbar.editor?.alignCenter()
        case .alignRight: toolbar.editor?.alignRight()
        case .image: toolbar.delegate?.fmEditorToolbarInsertImage?(toolbar)
        case .video: toolbar.delegate?.fmEditorToolbarInsertVideo?(toolbar)
        case .link: toolbar.delegate?.fmEditorToolbarInsertLink?(toolbar)
        case .table: toolbar.delegate?.fmEditorToolbarInsertTable?(toolbar)
        }
    }
}
