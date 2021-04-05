//
//  FMEditorViewer.swift
//  FMEditorSwift
//
//  Created by DONGJU LIM on 2021/03/29.
//

import UIKit
import WebKit

@objc public protocol FMEditorViewerDelegate: class {
    
    /// Called when the inner height of the text being displayed changes
    /// Can be used to update the UI
    @objc optional func fmEditorViewer(_ viewer: FMEditorViewer, heightDidChange height: Int)
}

/// FMEditorView is a UIView that displays richly styled text, and allows it to be edited in a WYSIWYG fashion.
@objcMembers open class FMEditorViewer: UIView, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Public Properties
    
    /// Input accessory view to display over they keyboard.
    open weak var delegate: FMEditorViewerDelegate?
    /// Defaults to nil
    open override var inputAccessoryView: UIView? {
        get { return webView.cjw_inputAccessoryView }
        set { webView.cjw_inputAccessoryView = newValue }
    }
    
    /// The internal UIWebView that is used to display the text.
    open private(set) var webView: WKWebView
    
    /// Whether or not scroll is enabled on the view.
    open var isScrollEnabled: Bool = true {
        didSet {
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    /// Whether or not to allow user input in the view.
    open func isEditingEnabled(handler: @escaping (Bool) -> Void) {
        isContentEditable(handler: handler)
    }
    
    /// The content HTML of the text being displayed.
    /// Is continually updated as the text is being edited.
    open private(set) var contentHTML: String = ""
    
    /// The internal height of the text being displayed.
    /// Is continually being updated as the text is edited.
    open private(set) var editorHeight: Int = 0 {
        didSet {
            delegate?.fmEditorViewer?(self, heightDidChange: editorHeight)
        }
    }
    
    /// The value we hold in order to be able to set the line height before the JS completely loads.
    private let innerLineHeight: Int = 28
    
    /// The line height of the editor. Defaults to 28.
    open private(set) var lineHeight: Int = 28 {
        didSet {
            runJS("RE.setLineHeight('\(lineHeight)px')")
        }
    }
    
    // MARK: Private Properties
    
    /// Whether or not the editor has finished loading or not yet.
    private var isEditorLoaded = false
    
    /// Value that stores whether or not the content should be editable when the editor is loaded.
    /// Is basically `isEditingEnabled` before the editor is loaded.
    private var editingEnabledVar = true
    
    /// The private internal tap gesture recognizer used to detect taps and focus the editor
    private let tapRecognizer = UITapGestureRecognizer()
    
    /// The inner height of the editor div.
    /// Fetches it from JS every time, so might be slow!
    private var clientHeight: Int = 0 {
//        let heightString = runJS("document.getElementById('viewer').clientHeight;")
//        return Int(heightString) ?? 0
        didSet {
            runJS("document.getElementById('viewer').clientHeight;") { (value) in
                self.clientHeight = Int(value) ?? 0
            }
        }
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        webView = WKWebView()
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        webView = WKWebView()
        super.init(coder: aDecoder)
        setup()
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    deinit {
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
    }
    
    private func setup() {
        backgroundColor = .white
        
        webView.frame = bounds
//        webView.delegate = self
//        webView.keyboardDisplayRequiresUserAction = false
//        webView.scalesPageToFit = false
//        webView.dataDetectorTypes = UIDataDetectorTypes()
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.configuration.dataDetectorTypes = WKDataDetectorTypes()
        
        webView.scrollView.isScrollEnabled = isScrollEnabled
//        webView.scrollView.bounces = false
//        webView.scrollView.delegate = self
//        webView.scrollView.clipsToBounds = false
        
        webView.scrollView.bounces = true
        webView.scrollView.delegate = self
        webView.scrollView.clipsToBounds = true
        
        webView.cjw_inputAccessoryView = nil
        
        self.addSubview(webView)
        
        DispatchQueue.main.async {
            if let filePath = Bundle(for: FMEditorViewer.self).path(forResource: "viewer", ofType: "html", inDirectory: "FMEditorSwift.bundle"){
                let url = URL(fileURLWithPath: filePath, isDirectory: false)
                self.webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            }
        }
    }
    
    // MARK: - Rich Text Editing
    
    // MARK: Properties
    
    /// The HTML that is currently loaded in the editor view, if it is loaded. If it has not been loaded yet, it is the
    /// HTML that will be loaded into the editor view once it finishes initializing.
    
    public var html: String = "" {
        didSet {
            setHTML(html)
        }
    }
    
    private func setHTML(_ value: String) {
        if isEditorLoaded {
            runJS("RE.setHtml('\(value.escaped)')") { _ in
                self.updateHeight()
            }
        }
    }
    
    public func getHtml(handler: @escaping (String) -> Void) {
        runJS("RE.getHtml()") { r in
            handler(r)
        }
    }
    
    /// Text representation of the data that has been input into the editor view, if it has been loaded.
    public func getText(handler: @escaping (String) -> Void) {
        runJS("RE.getText()") { r in
            handler(r)
        }
    }
    
    /// Private variable that holds the placeholder text, so you can set the placeholder before the editor loads.
    private var placeholderText: String = ""
    /// The placeholder text that should be shown when there is no user input.
    open var placeholder: String {
        get { return placeholderText }
        set {
            placeholderText = newValue
            runJS("RE.setPlaceholderText('\(newValue.escaped)');")
        }
    }
    
    
    /// The href of the current selection, if the current selection's parent is an anchor tag.
    /// Will be nil if there is no href, or it is an empty string.
    public func getSelectedHref(handler: @escaping (String?) -> Void) {
        hasRangeSelection(handler: { r in
            if !r {
                handler("")
            } else {
                self.runJS("RE.getSelectedHref()") { a in
                    handler(a)
                }
            }
        })
    }
    
    /// Whether or not the selection has a type specifically of "Range".
    public func hasRangeSelection(handler: @escaping (Bool) -> Void) {
        runJS("RE.rangeSelectionExists()") { r in
            handler(r == "true" ? true : false)
        }
    }
    
    /// Whether or not the selection has a type specifically of "Range" or "Caret".
    public func hasRangeOrCaretSelection(handler: @escaping (Bool) -> Void) {
        runJS("RE.rangeOrCaretSelectionExists()") { r in
            handler(r == "true" ? true : false)
        }
    }
    
    /// Runs some JavaScript on the UIWebView and returns the result
    /// If there is no result, returns an empty string
    /// - parameter js: The JavaScript string to be run
    /// - returns: The result of the JavaScript that was run
    public func runJS(_ js: String, handler: ((String) -> Void)? = nil) {
        webView.evaluateJavaScript(js) {(result, error) in
            if let error = error {
                print("WKWebViewJavascriptBridge Error: \(String(describing: error)) - JS: \(js)")
                handler?("")
                return
            }
            
            guard let handler = handler else { return }
            if let resultBool = result as? Bool {
                handler(resultBool ? "true" : "false")
                return
            }
            if let resultInt = result as? Int {
                handler("\(resultInt)")
                return
            }
            if let resultStr = result as? String {
                handler(resultStr)
                return
            }
            handler("") // no result
        }
    }
    
    
    // MARK: - Delegate Methods
    
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        if !isScrollEnabled {
            scrollView.bounds = webView.bounds
        }
    }
    
    
    // MARK: UIWebViewDelegate
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle pre-defined editor actions
        let callbackPrefix = "re-callback://"
        if navigationAction.request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
            // When we get a callback, we need to fetch the command queue to run the commands
            // It comes in as a JSON array of commands that we need to parse
            runJS("RE.getCommandQueue()") { commands in
                if let data = commands.data(using: .utf8) {
                    let jsonCommands: [String]
                    do {
                        jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                    } catch {
                        jsonCommands = []
                        NSLog("FMEditorView: Failed to parse JSON Commands")
                    }
                    jsonCommands.forEach(self.performCommand)
                }
            }
            return decisionHandler(WKNavigationActionPolicy.cancel);
        }
        
        // User is tapping on a link, so we should react accordingly
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                let application = UIApplication.shared
                if application.canOpenURL(URL(string: url.absoluteString)!) {
                    application.open(URL(string: url.absoluteString)!, options: [:], completionHandler: nil)
                    return decisionHandler(WKNavigationActionPolicy.allow);
                }
            }
        }
        return decisionHandler(WKNavigationActionPolicy.allow);
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    /// Delegate method for our UITapGestureDelegate.
    /// Since the internal web view also has gesture recognizers, we have to make sure that we actually receive our taps.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: - Private Implementation Details
    
    private func isContentEditable(handler: @escaping (Bool) -> Void) {
        if isEditorLoaded {
            // to get the "editable" value is a different property, than to disable it
            // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/contentEditable
            runJS("RE.editor.isContentEditable") { value in
                self.editingEnabledVar = Bool(value) ?? false
            }
        }
    }
    
    /// The position of the caret relative to the currently shown content.
    /// For example, if the cursor is directly at the top of what is visible, it will return 0.
    /// This also means that it will be negative if it is above what is currently visible.
    /// Can also return 0 if some sort of error occurs between JS and here.
    private func relativeCaretYPosition(handler: @escaping (Int) -> Void) {
        runJS("RE.getRelativeCaretYPosition()") { r in
            handler(Int(r) ?? 0)
        }
    }
    
    private func updateHeight() {
        DispatchQueue.main.async {
            self.runJS("document.getElementById('viewer').clientHeight;") { [weak self] (value) in
                let height = Int(value) ?? 0
                if self?.editorHeight != height {
                    self?.editorHeight = height
                }
            }
        }
    }
    
    private func getClientHeight(handler: @escaping (Int) -> Void) {
        runJS("document.getElementById('editor').clientHeight") { r in
            if let r = Int(r) {
                handler(r)
            } else {
                handler(0)
            }
        }
    }
    
    private func getLineHeight(handler: @escaping (Int) -> Void) {
        if isEditorLoaded {
            runJS("RE.getLineHeight()") { r in
                if let r = Int(r) {
                    handler(r)
                } else {
                    handler(self.innerLineHeight)
                }
            }
        } else {
            handler(self.innerLineHeight)
        }
    }
    
    /// Scrolls the editor to a position where the caret is visible.
    /// Called repeatedly to make sure the caret is always visible when inputting text.
    /// Works only if the `lineHeight` of the editor is available.
    private func scrollCaretToVisible() {
        let scrollView = self.webView.scrollView
        
        getClientHeight(handler: { clientHeight in
            let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
            
            // XXX: Maybe find a better way to get the cursor height
            self.getLineHeight(handler: { lh in
                let lineHeight = CGFloat(lh)
                let cursorHeight = lineHeight - 4
                self.relativeCaretYPosition(handler: { r in
                    let visiblePosition = CGFloat(r)
                    var offset: CGPoint?
                    
                    if visiblePosition + cursorHeight > scrollView.bounds.size.height {
                        // Visible caret position goes further than our bounds
                        offset = CGPoint(x: 0, y: (visiblePosition + lineHeight) - scrollView.bounds.height + scrollView.contentOffset.y)
                    } else if visiblePosition < 0 {
                        // Visible caret position is above what is currently visible
                        var amount = scrollView.contentOffset.y + visiblePosition
                        amount = amount < 0 ? 0 : amount
                        offset = CGPoint(x: scrollView.contentOffset.x, y: amount)
                    }
                    
                    if let offset = offset {
                        scrollView.setContentOffset(offset, animated: true)
                    }
                })
            })
        })
    }
    
    /// Called when actions are received from JavaScript
    /// - parameter method: String with the name of the method and optional parameters that were passed in
    private func performCommand(_ method: String) {
        if method.hasPrefix("ready") {
            // If loading for the first time, we have to set the content HTML to be displayed
            if !isEditorLoaded {
                isEditorLoaded = true
                setHTML(html)
                contentHTML = html
                html = contentHTML
                placeholder = placeholderText
                lineHeight = innerLineHeight
            }
            updateHeight()
        }
        else if method.hasPrefix("input") {
            scrollCaretToVisible()
            runJS("RE.getHtml()") { [weak self] (value) in
                self?.contentHTML = value
                self?.updateHeight()
            }
        }
        else if method.hasPrefix("updateHeight") {
            updateHeight()
        }
        else if method.hasPrefix("focus") {
        }
        else if method.hasPrefix("blur") {
        }
        else if method.hasPrefix("action/") {
            runJS("RE.getHtml()") { [weak self] (value) in
                self?.contentHTML = value
            }
            
            // If there are any custom actions being called
            // We need to tell the delegate about it
            let actionPrefix = "action/"
            let range = method.range(of: actionPrefix)!
            _ = method.replacingCharacters(in: range, with: "")
        }
    }
    
}

