//
//  FMEditorToolbar.swift
//  FMEditorSwift
//
//  Created by DONGJU LIM on 2021/03/29.
//

import UIKit

/// FMEditorToolbarDelegate is a protocol for the FMEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol FMEditorToolbarDelegate: class {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func fmEditorToolbarChangeTextColor(_ toolbar: FMEditorToolbar)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func fmEditorToolbarChangeBackgroundColor(_ toolbar: FMEditorToolbar)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func fmEditorToolbarInsertImage(_ toolbar: FMEditorToolbar)

    /// Called when the Insert Video toolbar item is pressed
    @objc optional func fmEditorToolbarInsertVideo(_ toolbar: FMEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func fmEditorToolbarInsertLink(_ toolbar: FMEditorToolbar)
    
    /// Called when the Insert Table toolbar item is pressed
    @objc optional func fmEditorToolbarInsertTable(_ toolbar: FMEditorToolbar)
}

/// RichBarButtonItem is a subclass of UIBarButtonItem that takes a callback as opposed to the target-action pattern
@objcMembers public class FMEditorToolbarButtonItem: UIBarButtonItem {
    open var actionHandler: (() -> Void)?
    
    public convenience init(image: UIImage? = nil, handler: (() -> Void)? = nil) {
        self.init(image: image, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(FMEditorToolbarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    public convenience init(title: String = "", handler: (() -> Void)? = nil) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        target = self
        action = #selector(FMEditorToolbarButtonItem.buttonWasTapped)
        actionHandler = handler
    }
    
    @objc func buttonWasTapped() {
        actionHandler?()
    }
}

/// FMEditorToolbar is UIView that contains the toolbar for actions that can be performed on a FMEditorView
@objcMembers public class FMEditorToolbar: UIView {

    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: FMEditorToolbarDelegate?

    /// A reference to the FMEditorView that it should be performing actions on
    open weak var editor: FMEditorView?

    /// The list of options to be displayed on the toolbar
    open var options: [FMEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    /// The tint color to apply to the toolbar background.
    open var barTintColor: UIColor? {
        get { return backgroundToolbar.barTintColor }
        set { backgroundToolbar.barTintColor = newValue }
    }

    private var toolbarScroll: UIScrollView
    private var toolbar: UIToolbar
    private var backgroundToolbar: UIToolbar
    
    public override init(frame: CGRect) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        toolbarScroll = UIScrollView()
        toolbar = UIToolbar()
        backgroundToolbar = UIToolbar()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear

        backgroundToolbar.frame = bounds
        backgroundToolbar.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        toolbar.autoresizingMask = .flexibleWidth
        toolbar.backgroundColor = .clear
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)

        toolbarScroll.frame = bounds
        toolbarScroll.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        toolbarScroll.showsHorizontalScrollIndicator = false
        toolbarScroll.showsVerticalScrollIndicator = false
        toolbarScroll.backgroundColor = .clear

        toolbarScroll.addSubview(toolbar)

        addSubview(backgroundToolbar)
        addSubview(toolbarScroll)
        updateToolbar()
    }
    
    private func updateToolbar() {
        var buttons = [UIBarButtonItem]()
        for option in options {
            let handler = { [weak self] in
                if let strongSelf = self {
                    option.action(strongSelf)
                }
            }

            if let image = option.image {
                let button = FMEditorToolbarButtonItem(image: image, handler: handler)
                buttons.append(button)
            } else {
                let title = option.title
                let button = FMEditorToolbarButtonItem(title: title, handler: handler)
                buttons.append(button)
            }
        }
        toolbar.items = buttons

        let defaultIconWidth: CGFloat = 28
        let barButtonItemMargin: CGFloat = 12
        let width: CGFloat = buttons.reduce(0) {sofar, new in
            if let view = new.value(forKey: "view") as? UIView {
                return sofar + view.frame.size.width + barButtonItemMargin
            } else {
                return sofar + (defaultIconWidth + barButtonItemMargin)
            }
        }
        
        if width < frame.size.width {
            toolbar.frame.size.width = frame.size.width + barButtonItemMargin
        } else {
            toolbar.frame.size.width = width + barButtonItemMargin
        }
        toolbar.frame.size.height = 44
        toolbarScroll.contentSize.width = width
    }
    
}
