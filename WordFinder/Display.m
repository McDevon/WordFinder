//
//  Display.m
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Jussi Enroos
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "Display.h"
#import "AppDelegate.h"

#import "Puzzle.h"
#import "WordDatabase.h"
#import "PuzzleSolution.h"

@interface Display ()

@end

@implementation Display
{
    WordDatabase *_dataBase;
    NSMutableArray *_resultSolutions;
    NSMutableArray *_letterViews;
    
    NSString *_fileToBeSaved;
}

#pragma mark - Initialization -

-(void)awakeFromNib
{
    _dataBase = [[WordDatabase alloc] init];
    _resultSolutions = [[NSMutableArray alloc] init];
    _letterViews = [[NSMutableArray alloc] init];
    
    // Populate letter view array
    LetterView *view = _firstLetterView;
    
    do {
        [_letterViews addObject:view];
        view = view.targetView;
    } while (view != _firstLetterView);
    
    // Autoload save file from bundle
    NSBundle* mainBundle = [NSBundle mainBundle];
    
    NSString *defaultFile = [[mainBundle resourcePath] stringByAppendingPathComponent:@"database.txt"];
    
    //NSLog(@"Default file path: %@", defaultFile);
    
    // Load words from default file
    [self loadWordsFromFilePath:defaultFile];
}

#pragma mark - Callbacks and button selectors -

- (void)windowWillClose:(NSNotification *)notification
{
    // Save words before exiting
    NSBundle* mainBundle = [NSBundle mainBundle];
    
    NSString *defaultFile = [[mainBundle resourcePath] stringByAppendingPathComponent:@"database.txt"];
    
    //NSLog(@"Default file path: %@", defaultFile);
    
    // Save to default file in a separate thread
    [self threadFileSavingToPath:defaultFile];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    
    // Clear all letter view bg colors
    for (LetterView *view in _letterViews) {
        view.backgroundColor = [NSColor whiteColor];
    }
    
    LetterView *textField = [notification object];
    
    NSInteger caretPosition = [[_window fieldEditor:YES forObject:textField] selectedRange].location;
    
    //NSLog(@"Caret position: %ld", caretPosition);
    
    NSString *currentString = [textField stringValue];
    NSString *finalString;
    
    // Always take the latest given character, no matter where the caret is
    if (currentString.length <= 0) {
        textField.stringValue = @"";
        
        // Do not move to the next text field when one was erased
        return;
    }
    else if (caretPosition > 1) {
        finalString = [[currentString substringFromIndex:currentString.length - 1] uppercaseString];
    }
    else {
        finalString = [[currentString substringToIndex:1] uppercaseString];
    }
    
    textField.stringValue = finalString;
    
    [_window makeFirstResponder:textField.targetView];
}

-(IBAction)findWordsSelected:(id)sender
{
    // Clear view stuff
    for (LetterView *view in _letterViews) {
        view.backgroundColor = [NSColor whiteColor];
    }
    
    // Create base
    NSMutableString *letterString = [NSMutableString string];
    
    LetterView *view = _firstLetterView;
    
    do {
        [letterString appendFormat:@"%@",[view stringValue]];
        view = view.targetView;
        
    } while (view != _firstLetterView);
    
    //NSLog(@"%@", letterString);
    
    Puzzle *puzzle = [Puzzle puzzleWithString:letterString width:4 height:4];
    
    NSArray *words = [_dataBase solutionsForPuzzle:puzzle];
    
    _resultSolutions = [NSMutableArray arrayWithArray:words];
    
    [_resultSolutions sortUsingSelector:@selector(compareWordLengths:)];
    
    [_wordTable reloadData];
    [_window makeFirstResponder:_wordTable];
    
    _infoField.stringValue = [NSString stringWithFormat:@"Found %lu words", (unsigned long)_resultSolutions.count];
}

- (IBAction)addWordSelected:(id)sender
{
    int retVal = [_dataBase addWord:[_wordField stringValue]];
    if (retVal == 0) {
        _infoField.stringValue = [NSString stringWithFormat:@"Added word '%@'", _wordField.stringValue];
    } else if (retVal == -1){
        _infoField.stringValue = [NSString stringWithFormat:@"Could not add word '%@', word cannot start with a dash", _wordField.stringValue];
    } else if (retVal == -2){
        _infoField.stringValue = [NSString stringWithFormat:@"Could not add word '%@'", _wordField.stringValue];
    } else if (retVal == -3){
        _infoField.stringValue = [NSString stringWithFormat:@"Could not add word '%@', word already added", _wordField.stringValue];
    } else if (retVal == -4){
        _infoField.stringValue = [NSString stringWithFormat:@"Could not add word '%@', word too short", _wordField.stringValue];
    } else if (retVal == -5){
        _infoField.stringValue = [NSString stringWithFormat:@"Could not add word '%@', word too long", _wordField.stringValue];
    }
}

- (IBAction)removeWordSelected:(id)sender
{
    if ([_dataBase removeWord:[_wordField stringValue]]) {
        _infoField.stringValue = [NSString stringWithFormat:@"Removed word '%@'", _wordField.stringValue];
    } else {
        _infoField.stringValue = [NSString stringWithFormat:@"Could not remove word '%@', not in database", _wordField.stringValue];
    }
}

- (IBAction)openFileSelected:(id)sender
{
    // Create file query panel
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            // load words from text files
            NSString *path = [url path];
            
            // Simple check for file extension
            // TODO: proper check of file type
            if (!!![[path pathExtension] isCaseInsensitiveLike:@"txt"]) {
                _infoField.stringValue = [NSString stringWithFormat:@"Cannot load %@, not a txt file.", [path lastPathComponent]];
                continue;
            }
            
            // Load words from file
            [self loadWordsFromFilePath:path];
        }
    }
}

- (IBAction)clearWordListSelected:(id)sender
{
    // Clear the list
    uint32 removed = [_dataBase removeAllWords];
    
    _infoField.stringValue = [NSString stringWithFormat:@"Removed %u words", removed];
}

- (IBAction)saveToFileSelected:(id)sender
{
    NSSavePanel *save = [NSSavePanel savePanel];
    
    NSInteger result = [save runModal];
    
    if (result == NSOKButton){
        NSURL *selectedFile = save.URL;
        
        _fileToBeSaved = [selectedFile lastPathComponent];
        
        // Create a thread for file saving
        [self threadFileSavingToPath:[selectedFile path]];
    }

}

#pragma mark - Table handling -

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (NSInteger)[_resultSolutions count];
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    PuzzleSolution *solution = [_resultSolutions objectAtIndex:rowIndex];
    return solution.word;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = [notification object];
    
    if (tableView.selectedRow < 0) {
        // More than one row selected, do nothing
        return;
    }
    
    PuzzleSolution *solution = [_resultSolutions objectAtIndex:tableView.selectedRow];
    
    //NSLog(@"Selected: %@", solution.word);
    
    // Clear all letter view bg colors
    for (LetterView *view in _letterViews) {
        view.backgroundColor = [NSColor whiteColor];
    }
    
    NSUInteger length = solution.word.length;
    
    NSColor *firstColor = [NSColor colorWithRed:226.f/255.f green:128.f/255.f blue:122.f/255.f alpha:1.f];
    NSColor *lastColor = [NSColor colorWithRed:138.f/255.f green:226.f/255.f blue:136.f/255.f alpha:1.f];
    
    // Gradient from one color to another (does not really look good or clear)
    /*float redChange = (lastColor.redComponent - firstColor.redComponent) / (float)length;
    float greenChange = (lastColor.greenComponent - firstColor.greenComponent) / (float)length;
    float blueChange = (lastColor.blueComponent - firstColor.blueComponent) / (float)length;
    
    float red = firstColor.redComponent;
    float green = firstColor.greenComponent;
    float blue = firstColor.blueComponent;*/
    
    // Set colors for all positions
    for (int i = 0; i < length; i++) {
        //int index = 4 * y + x;
        
        LetterPosition position = [solution positionOfLetterIndex:i];
        int index = 4 * position.y + position.x;
        
        NSColor *bgColor; //[NSColor colorWithRed:red green:green blue:blue alpha:1.0f];
        
        if (i == 0) {
            bgColor = firstColor;
        } else {
            bgColor = lastColor;
        }
        
        LetterView *view = [_letterViews objectAtIndex:index];
        view.backgroundColor = bgColor;
        
        /*red += redChange;
        green += greenChange;
        blue += blueChange;*/
    }
}

#pragma mark - File handling -

- (BOOL) loadWordsFromFilePath:(NSString*)path
{
    // Read file to nsdata
    NSError *error;
    NSData *fileData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
    
    if (error != nil) {
        NSLog(@"#Error loading file at %@, %@", path, error.localizedDescription);
        return NO;
    }
    
    // Copy bytes
    uint32 length = (uint32)[fileData length];
    uint32 loadedWords = 0;
    uint32 rejectedWords = 0;
    
    const char *bytes = [fileData bytes];
    
    // Go through data
    unsigned int wordStart = 0;
    for (unsigned int i = 0; i < length; i++) {
        
        // Wait for end of line
        if (bytes[i] == '\n') {
            // Create NSString for word list
            char *word = malloc(sizeof(char) * i - wordStart + 1);
            strncpy(word, bytes + wordStart, i - wordStart);
            word[i - wordStart] = '\0';
            
            NSString *string = [NSString stringWithUTF8String:word];
            if ([_dataBase addWord:string] == 0) {
                loadedWords++;
            } else {
                rejectedWords++;
            }
            wordStart = i+1;
        }
        
    }
    
    _infoField.stringValue = [NSString stringWithFormat:@"Loaded %u words, rejected %u words.", loadedWords, rejectedWords];

    return YES;
}

- (void) threadFileSavingToPath:(NSString*) path
{
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fileSavingThreadForPath:) object:path];
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate threadOperation:op];
}

- (void) fileSavingThreadForPath:(NSString*) path
{
    NSNumber *savingDone = [NSNumber numberWithBool:[self saveWordsToFilePath:path]];
    // Notify main thread that saving is complete
    
    [self performSelectorOnMainThread:@selector(savingDone:) withObject:savingDone waitUntilDone:NO];
    
    // Thread end
}

- (void) savingDone:(id) success
{
    NSNumber *savingDone = (NSNumber*) success;
    
    if (savingDone) {
        _infoField.stringValue = [NSString stringWithFormat:@"Saved %@", _fileToBeSaved];
    } else {
        _infoField.stringValue = [NSString stringWithFormat:@"Failed to save %@", _fileToBeSaved];
    }
    
}

- (BOOL) saveWordsToFilePath:(NSString*) path
{
    NSArray *words = [_dataBase wordList];
    
    NSMutableString *string = [NSMutableString stringWithFormat:@""];
    
    for (NSString* word in words) {
        [string appendFormat:@"%@\n", word];
    }
    
    NSError *error = nil;
    BOOL success = [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    /*if (error != nil) {
        _infoField.stringValue = [NSString stringWithFormat:@"Error writing file: %@", error.localizedDescription];
    }*/
    
    return success;
}

@end
