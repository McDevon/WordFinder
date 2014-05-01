//
//  WordDatabase.m
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

#import "WordDatabase.h"
#import "Puzzle.h"

@implementation WordLetter
{
    //char _letter;
    NSString *_letter;
    NSMutableDictionary *_nextLetters;
    BOOL _endOfWord;
    
    // For searching
    LetterPosition _position;
    int _depth;
    BOOL _used;
}

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
        
        //const char *data = [letter cStringUsingEncoding:NSASCIIStringEncoding];
        //letterData.letter = data[0];
        
        letterData.letter = letter;
        
        [_firstLetters setObject:letterData forKey:letter];
    }
    
    return letterData;
}

- (BOOL) addWord:(NSString*)word
{
    if (word.length < 3) {
        //NSLog(@"#Error: cannot add word %@, too short", word);
        return NO;
    }
    
    word = [word uppercaseString];
    
    NSString *firstLetter = [word substringToIndex:1];
    
    if ([firstLetter isEqualToString:@"-"]) {
        //NSLog(@"#Warning: cannot add word %@, starts with a dash", word);
        return NO;
    }
    
    // Get first letter
    WordLetter *letter = [self getFirstLetter:firstLetter];
    
    if (letter == nil) {
        NSLog(@"#Error: cannot get first letter");
        return NO;
    }
    
    //int index = 1;
    int length = (int)word.length;
    //const char *letterArray = [word cStringUsingEncoding:NSASCIIStringEncoding];
    
    for (int i = 1; i < length; i++) {
        //char letterWord[2];
        //letterWord[0] = letterArray[i];
        //letterWord[1] = '\0';
        
        NSString *key = [word substringWithRange:NSMakeRange(i, 1)];
        
        WordLetter *nextLetter = [letter getWordLetterForLetter:key create:YES];
        if (nextLetter == nil) {
            //NSLog(@"#Error: cannot add word");
            return NO;
        }
        
        // Done
        if (i == length - 1) {
            nextLetter.endOfWord = YES;
            //NSLog(@"Word added: %@", word);
        }
        else {
            letter = nextLetter;
        }
    }
    
    return YES;
}

- (void) removeWord:(NSString*)word
{
    
}

- (void) logAllWords
{
    NSArray *keys = [_firstLetters allKeys];
    for (NSString *key in keys) {
        WordLetter *letter = [_firstLetters objectForKey:key];
        
        [self recursiveWordLogFrom:letter withString:key];
    }
}

- (void) recursiveWordLogFrom:(WordLetter*)letter withString:(NSString*)string
{
    if (letter.endOfWord) {
        NSLog(@"%@", string);
    }

    NSArray *keys = [letter.nextLetters allKeys];
    for (NSString *key in keys) {
        WordLetter *nextLetter = [letter.nextLetters objectForKey:key];
        
        [self recursiveWordLogFrom:nextLetter withString:[string stringByAppendingString:key]];
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
