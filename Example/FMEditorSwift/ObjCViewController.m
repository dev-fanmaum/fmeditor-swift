//
//  ObjCViewController.m
//  FMEditorSwift
//
//  Created by appsstudioio on 03/29/2021.
//  Copyright (c) 2021 appsstudioio. All rights reserved.
//

#import "ObjCViewController.h"
#import <FMEditorSwift_Example-Swift.h>

@class KeyboardManager;

@interface ObjCViewController() <FMEditorDelegate>
{
    KeyboardManager *keyboard;
}
@end

@implementation ObjCViewController
@synthesize editorView;
@synthesize htmlTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    editorView.delegate = self;
    editorView.placeholder = @"Type some text...";

    keyboard = [[KeyboardManager alloc] initWithView:self.view];
    keyboard.toolbar.editor = self.editorView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [keyboard beginMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [keyboard stopMonitoring];
}

//------------------------------------------------------------------------------
#pragma mark - RichEditorViewDelegate
- (void)fmEditor:(FMEditorView * __nonnull)editor contentDidChange:(NSString * __nonnull)content {
    if (content.length == 0) {
        self.htmlTextView.text = @"HTML Preview";
    } else {
        self.htmlTextView.text = content;
    }
}

@end
