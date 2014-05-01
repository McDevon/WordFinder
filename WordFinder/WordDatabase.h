//
//  WordDatabase.h
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PuzzleSolution.h"

@class Puzzle;

@interface WordLetter : NSObject

//@property char letter;
@property NSString *letter;
@property (retain) NSMutableDictionary *nextLetters;
@property BOOL endOfWord;

@property LetterPosition position;
@property int depth;
@property BOOL used;

- (WordLetter*) getWordLetterForLetter:(NSString*)letter create:(BOOL)create;

@end

@interface WordDatabase : NSObject

- (BOOL) addWord:(NSString*)word;
- (void) removeWord:(NSString*)word;

- (NSArray*) solutionsForPuzzle:(Puzzle*)puzzle;

- (void) logAllWords;

@end
