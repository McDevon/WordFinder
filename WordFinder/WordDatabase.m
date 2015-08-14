//
//  WordDatabase.m
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

#import "WordDatabase.h"
#import "Puzzle.h"

#define MIN_WORD_LENGTH 3
#define MAX_WORD_LENGTH 16

@implementation WordLetter

- (WordLetter*) getWordLetterForLetter:(NSString*)letter create:(BOOL)create
{
    if (letter == nil || letter.length != 1) {
        return nil;
    }
    
    WordLetter *result = [_nextLetters objectForKey:letter];
    
    if (create && result == nil) {
        result = [[WordLetter alloc] init];
        result.letter = letter;
        
        //const char *data = [letter cStringUsingEncoding:NSASCIIStringEncoding];
        //result.letter = data[0];
        
        [_nextLetters setObject:result forKey:letter];
    }
    
    return result;
}

- (id) init
{
    if (self = [super init]) {
        _nextLetters = [[NSMutableDictionary alloc] init];
        _endOfWord = NO;
    }
    
    return self;
}

@end

@implementation WordDatabase
{
    NSMutableDictionary *_firstLetters;
    NSMutableArray *_solutions;
    NSMutableSet *_solutionWords;
    
    // For counting
    uint32 _wordCount;
}

- (id) init
{
    if (self = [super init]) {
        _firstLetters = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (WordLetter*) getFirstLetter:(NSString*)letter
{
    if (letter == nil || letter.length != 1) {
        return nil;
    }
    
    WordLetter *letterData = [_firstLetters objectForKey:letter];
    
    if (letterData == nil) {
        letterData = [[WordLetter alloc] init];
        
        letterData.letter = letter;
        
        [_firstLetters setObject:letterData forKey:letter];
    }
    
    return letterData;
}

- (int) addWord:(NSString*)word
{
    if (word.length < MIN_WORD_LENGTH) {
        // Too short word
        return -4;
    }
    if (word.length > MAX_WORD_LENGTH) {
        // Too long word
        return -5;
    }
    
    word = [word uppercaseString];
    
    NSString *firstLetter = [word substringToIndex:1];
    
    if ([firstLetter isEqualToString:@"-"]) {
        //NSLog(@"#Warning: cannot add word %@, starts with a dash", word);
        return -1;
    }
    
    // Get first letter
    WordLetter *letter = [self getFirstLetter:firstLetter];
    
    if (letter == nil) {
        NSLog(@"#Error: cannot get first letter");
        return -2;
    }
    
    //int index = 1;
    int length = (int)word.length;
    
    for (int i = 1; i < length; i++) {
        
        NSString *key = [word substringWithRange:NSMakeRange(i, 1)];
        
        WordLetter *nextLetter = [letter getWordLetterForLetter:key create:YES];
        if (nextLetter == nil) {
            NSLog(@"#Error: cannot add word");
            return -6;
        }
        
        // Done
        if (i == length - 1) {
            if (nextLetter.endOfWord) {
                // This word already added
                return -3;
            } else {
                // Add word
                nextLetter.endOfWord = YES;
            }
            //NSLog(@"Word added: %@", word);
        }
        else {
            letter = nextLetter;
        }
    }
    
    return 0;
}

- (BOOL) removeWord:(NSString*)word
{
    if (word.length < MIN_WORD_LENGTH) {
        // Too short word
        return NO;
    }
    if (word.length > MAX_WORD_LENGTH) {
        // Too long word
        return NO;
    }

    word = [word uppercaseString];
    
    NSString *firstLetter = [word substringToIndex:1];
    
    // Get first letter
    WordLetter *letter = [self getFirstLetter:firstLetter];
    
    if (letter == nil) {
        NSLog(@"#Error: cannot get first letter");
        return NO;
    }
    
    int length = (int)word.length;
    
    for (int i = 1; i < length; i++) {
        
        NSString *key = [word substringWithRange:NSMakeRange(i, 1)];
        
        WordLetter *nextLetter = [letter getWordLetterForLetter:key create:NO];
        if (nextLetter == nil) {
            // Word not found
            return NO;
        }
        
        // Done
        if (i == length - 1) {
            if (nextLetter.endOfWord) {
                // This word was added, now remove
                nextLetter.endOfWord = NO;
                return YES;
            } else {
                // This word is not added
                return NO;
            }
        }
        else {
            letter = nextLetter;
        }
    }
    
    return NO;
}

- (uint32) removeAllWords
{
    _wordCount = 0;
        
    // Get all words
    NSArray *keys = [_firstLetters allKeys];
    for (NSString *key in keys) {
        WordLetter *letter = [_firstLetters objectForKey:key];
        
        [self recursiveWordLogFrom:letter withString:key addToArray:nil remove:YES];
    }
    
    return _wordCount;
}

- (NSArray*) wordList
{
    NSMutableArray *array = [NSMutableArray array];
    
    // Get all words
    NSArray *keys = [_firstLetters allKeys];
    for (NSString *key in keys) {
        WordLetter *letter = [_firstLetters objectForKey:key];
        
        [self recursiveWordLogFrom:letter withString:key addToArray:array remove:NO];
    }
    
    return array;
}

- (void) logAllWords
{
    NSArray *keys = [_firstLetters allKeys];
    for (NSString *key in keys) {
        WordLetter *letter = [_firstLetters objectForKey:key];
        
        [self recursiveWordLogFrom:letter withString:key addToArray:nil remove:NO];
    }
}

- (void) recursiveWordLogFrom:(WordLetter*)letter withString:(NSString*)string addToArray:(NSMutableArray*)array remove:(BOOL) remove
{
    if (letter.endOfWord) {
        if (array == nil && !!! remove) {
            // Normal logging
            NSLog(@"%@", string);
        } else if (array != nil){
            // Array logging
            [array addObject:string];
        }
        else {
            // Remove word
            letter.endOfWord = NO;
        }
        _wordCount ++;
    }

    NSArray *keys = [letter.nextLetters allKeys];
    for (NSString *key in keys) {
        WordLetter *nextLetter = [letter.nextLetters objectForKey:key];
        
        [self recursiveWordLogFrom:nextLetter withString:[string stringByAppendingString:key] addToArray:array remove:remove];
    }
}

- (NSArray*) solutionsForPuzzle:(Puzzle*)puzzle
{
    _solutions = [NSMutableArray array];
    _solutionWords = [NSMutableSet set];
    
    // Start from each of the letters and get all possible words
    
    for (SolutionLetter *letter in puzzle.firstLetters) {
        // Get corresponding dictionary letter
        WordLetter *dictionaryLetter = [_firstLetters objectForKey:letter.letter];
        
        // No words with this letter
        if (dictionaryLetter == nil) {
            continue;
        }
        
        letter.used = YES;
        letter.depth = 0;
        
        PuzzleSolution *solution = [[PuzzleSolution alloc] init];
        [solution setPosition:letter.position forLetterIndex:0];
        solution.word = letter.letter;
        
        [self recursiveSearchAt:letter dictionaryPosition:dictionaryLetter solution:solution];
        
        letter.used = NO;
    }
    
    return _solutions;
}

- (void) recursiveSearchAt:(SolutionLetter*)puzzleLetter dictionaryPosition:(WordLetter*)dictionaryLetter solution:(PuzzleSolution*)solution
{
    if (dictionaryLetter.endOfWord) {
        // Found one word
        if (!!! [_solutionWords containsObject:solution.word]) {
            [_solutions addObject:solution];
            [_solutionWords addObject:solution.word];
        }
    }
    
    // Get next letters
    for (SolutionLetter *letter in puzzleLetter.nextLetters) {
        
        // Cannot enter same letter twice
        if (letter.used) {
            continue;
        }
        
        WordLetter *targetDictLetter = [dictionaryLetter.nextLetters objectForKey:letter.letter];
        
        // No words for this letter
        if (targetDictLetter == nil) {
            continue;
        }
        
        // This can go on, so go on
        letter.used = YES;
        letter.depth = puzzleLetter.depth + 1;
        
        
        PuzzleSolution *nextSolution = [solution solutionByAppendingPosition:letter.position andString:letter.letter];
        [nextSolution setPosition:letter.position forLetterIndex:letter.depth];

        [self recursiveSearchAt:letter dictionaryPosition:targetDictLetter solution:nextSolution];
        
        letter.used = NO;
    }
}

@end
