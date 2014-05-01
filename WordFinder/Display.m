//
//  Display.m
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

#import "Display.h"

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
}


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
    
    /*[_dataBase addWord:@"Kissa"];
    [_dataBase addWord:@"Kala"];
    [_dataBase addWord:@"Kaali"];
    [_dataBase addWord:@"Ruoka"];
    [_dataBase addWord:@"Ruokala"];
    [_dataBase addWord:@"Teräs"];
    [_dataBase addWord:@"Teräsmies"];*/
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Should find something
    if (paths.count > 0) {
        
        NSString *path = [paths objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"sanalista.txt"];
        /*NSURL *url = [NSURL URLWithString:(NSString*)[paths objectAtIndex:0]];
        url = [url URLByAppendingPathComponent:@"file.tst"];
        NSError *error = nil;*/
        
        [self loadWordsFromFilePath:path];
    }
    
    //[_dataBase logAllWords];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    
    // Clear all letter view bg colors
    for (LetterView *view in _letterViews) {
        view.backgroundColor = [NSColor whiteColor];
    }
    
    LetterView *textField = [notification object];
    
    NSString *currentString = [textField stringValue];
    NSString *finalString = [[currentString substringFromIndex:currentString.length - 1] uppercaseString];
    
    textField.stringValue = finalString;
    
    [_window makeFirstResponder:textField.targetView];
    //[self.view.window makeFirstResponder:textField.targetView];
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
    
    NSLog(@"%@", letterString);
    
    Puzzle *puzzle = [Puzzle puzzleWithString:letterString width:4 height:4];
    
    NSArray *words = [_dataBase solutionsForPuzzle:puzzle];
    
    _resultSolutions = [NSMutableArray arrayWithArray:words];
    
    [_resultSolutions sortUsingSelector:@selector(compareWordLengths:)];
    
    [_wordTable reloadData];
}

- (IBAction)addWordSelected:(id)sender
{
    [_dataBase addWord:[_wordField stringValue]];
}

- (IBAction)removeWordSelected:(id)sender
{
    [_dataBase removeWord:[_wordField stringValue]];
}

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
    PuzzleSolution *solution = [_resultSolutions objectAtIndex:tableView.selectedRow];
    //NSString *string = [_resultSolutions objectAtIndex:tableView.selectedRow];
    
    NSLog(@"Selected: %@", solution.word);
    
    // Clear all letter view bg colors
    for (LetterView *view in _letterViews) {
        view.backgroundColor = [NSColor whiteColor];
    }
    
    // Set colors for all positions
    for (int i = 0; i < solution.word.length; i++) {
        //int index = 4 * y + x;
        
        LetterPosition position = [solution positionOfLetterIndex:i];
        int index = 4 * position.y + position.x;
        
        NSColor *bgColor;
        if (i == 0) {
            // First letter color
            bgColor = [NSColor colorWithRed:226.f/255.f green:128.f/255.f blue:122.f/255.f alpha:1.f];
        } else {
            bgColor = [NSColor colorWithRed:138.f/255.f green:226.f/255.f blue:136.f/255.f alpha:1.f];
        }
        
        LetterView *view = [_letterViews objectAtIndex:index];
        view.backgroundColor = bgColor;
    }
}

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
            [_dataBase addWord:string];
            wordStart = i+1;
        }
        
    }

    return YES;
}
@end
