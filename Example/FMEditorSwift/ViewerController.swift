//
//  ViewerController.swift
//  FMEditorSwift
//
//  Created by appsstudioio on 03/29/2021.
//  Copyright (c) 2021 appsstudioio. All rights reserved.
//

import UIKit
import FMEditorSwift

class ViewerController: UIViewController {
    
    @IBOutlet weak var richViewer: FMEditorViewer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        richViewer.html = "dsabfkdbsaklfblksdaldflskafbkldsabfkladsbklfbdsaklfbklsal<img src=\"https://cdnetphoto.appphotocard.com/boards/18/1230927/60588/e8c7f4d31139111985b98caa2e217bb3.jpg\" alt=\"photo\"><img src=\"https://cdnetphoto.appphotocard.com/boards/18/1230927/60588/12ff23e280088e2695d21272cc6d8e6c.jpg\" alt=\"photo\">"
        
    }
}

