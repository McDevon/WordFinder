//
//  Display.h
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetterView.h"


@interface Display : NSViewController <NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet LetterView *firstLetterView;

@property (assign) IBOutlet NSTableView *wordTable;

@property (assign) IBOutlet NSTextField *wordField;


// Button methods
- (IBAction)findWordsSelected:(id)sender;

- (IBAction)addWordSelected:(id)sender;
- (IBAction)removeWordSelected:(id)sender;

@end
