//
//  ViewController.swift
//  FMEditorSwift
//
//  Created by appsstudioio on 03/29/2021.
//  Copyright (c) 2021 appsstudioio. All rights reserved.
//

import UIKit
import FMEditorSwift

class ViewController: UIViewController {

    @IBOutlet var editorView: FMEditorView!
    @IBOutlet var htmlTextView: UITextView!

    lazy var toolbar: FMEditorToolbar = {
        let toolbar = FMEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = FMEditorDefaultOption.all
        return toolbar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        editorView.html = "dsabfkdbsaklfblksdaldflskafbkldsabfkladsbklfbdsaklfbklsal<img src=\"https://cdnetphoto.appphotocard.com/boards/18/1230927/60588/e8c7f4d31139111985b98caa2e217bb3.jpg\" alt=\"photo\"><img src=\"https://cdnetphoto.appphotocard.com/boards/18/1230927/60588/12ff23e280088e2695d21272cc6d8e6c.jpg\" alt=\"photo\">"

        toolbar.delegate = self
        toolbar.editor = editorView

        // We will create a custom action that clears all the input text when it is pressed
        let item = FMEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }

        var options = toolbar.options
        options.append(item)
        toolbar.options = options
    }

}

extension ViewController: FMEditorDelegate {

    func fmEditor(_ editor: FMEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }
    
    func fmEditor(_ editor: FMEditorView, heightDidChange height: Int) {
        print("heigggggghttt \(height)")
    }
}

extension ViewController: FMEditorToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func fmEditorToolbarChangeTextColor(_ toolbar: FMEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func fmEditorToolbarChangeBackgroundColor(_ toolbar: FMEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func fmEditorToolbarInsertImage(_ toolbar: FMEditorToolbar) {
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func fmEditorToolbarInsertLink(_ toolbar: FMEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        toolbar.editor?.hasRangeSelection(handler: { (isSucess) in
            if isSucess {
                toolbar.editor?.insertLink(href: "http://github.com/cjwirth/RichEditorView", text: "Github Link")
            }
        })
       
    }
}
