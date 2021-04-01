//
//  ObjCViewController.h
//  FMEditorSwift
//
//  Created by appsstudioio on 03/29/2021.
//  Copyright (c) 2021 appsstudioio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FMEditorSwift/FMEditorSwift-Swift.h>

@interface ObjCViewController : UIViewController
@property (nonatomic, strong) IBOutlet FMEditorView *editorView;
@property (nonatomic, strong) IBOutlet UITextView *htmlTextView;

@end
