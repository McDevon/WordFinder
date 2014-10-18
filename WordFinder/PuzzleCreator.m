//
//  PuzzleCreator.m
//  WordFinder
//
//  Created by Jussi Enroos on 1.5.2014.
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

#import "PuzzleCreator.h"

#define MAX_LETTERS_IN_LANGUAGE 50

@interface PuzzleLetter : NSObject
{
    // Letter data for creating puzzles
    NSString *_letter;
    
    // Amount of this letter appeared on the words
    uint32 _amount;
    
    // Weight of this letter (on scale 0...1)
    double _weight;
    
    // Relations to other letters (how often in same word)
    uint32 _relations[MAX_LETTERS_IN_LANGUAGE];
    
    // Index in the array
    uint32 _index;
}

@property (copy) NSString* letter;
@property uint32 amount;
@property double weight;
@property uint32 index;

- (void) updateWeightWithFullLetterCount:(uint32) letterCount;
- (uint32) relationForIndex:(int) index;
- (void) setRelation:(uint32) relation forIndex:(uint32) index;
- (void) increaseRelationForIndex:(uint32) index withValue:(uint32) value;

@end

@implementation PuzzleLetter

- (void) updateWeightWithFullLetterCount:(uint32) letterCount
{
    _weight = (double)_amount / (double)letterCount;
}

- (uint32) relationForIndex:(int) index
{
    return _relations[index];
}

- (void) setRelation:(uint32) relation forIndex:(uint32) index
{
    _relations[index] = relation;
}

- (void) increaseRelationForIndex:(uint32) index withValue:(uint32) value
{
    _relations[index] += value;
}


@end

@implementation PuzzleCreator
{
    // Data on all letters in both dictionary and an array
    NSMutableArray *_letterArray;
    NSMutableDictionary *_letterDictionary;
    
    // All letters in all words summed
    uint32 _letterCount;
}

- (PuzzleLetter*) getLetter:(NSString*) letterString create:(BOOL) create
{
    PuzzleLetter *letter = [_letterDictionary objectForKey:letterString];
    
    if (create && letter == nil) {
        // New letter, add to dictionary and to array
        letter = [[PuzzleLetter alloc] init];
        letter.letter = letterString;
        
        // Set index in array
        letter.index = (uint32)_letterArray.count;
        [_letterArray addObject:letter];
        
        [_letterDictionary setObject:letter forKey:letterString];
    }
    
    return letter;
}

- (BOOL) addWordToDatabase:(NSString*) word
{
    // Go through each letter
    
    NSMutableSet *addedLetters = [NSMutableSet set];
    
    for (int i = 0; i < word.length; i++) {
        NSString *letterString = [word substringWithRange:NSMakeRange(i, 1)];
        
        // Find in dictionary
        PuzzleLetter *letter = [self getLetter:letterString create:YES];
        
        // Alloc failed
        /*if (letter == nil) {
            return NO;
        }*/
        
        // Increase appearance amount
        letter.amount++;
        
        _letterCount++;
        
        if (!!! [addedLetters containsObject:letterString]) {
            // Get neighbors in this word (not the most efficient way, but no speed is required here)
            [self addRelationsToLetter:letter forWord:word];
            
            // Only set neighbors once per letter per word
            [addedLetters addObject:letterString];
        }
    }
    
    return NO;
}

- (void) addRelationsToLetter:(PuzzleLetter*)letter forWord:(NSString*)word
{
    // Go through each letter
    
    for (int i = 0; i < word.length; i++) {
        NSString *letterString = [word substringWithRange:NSMakeRange(i, 1)];
        
        // Skip self
        if ([letterString isEqualToString:letter.letter]) {
            continue;
        }
        
        // Find in dictionary
        PuzzleLetter *neighbor = [self getLetter:letterString create:YES];
    
        // Increase relation
        [letter increaseRelationForIndex:neighbor.index withValue:1];
    }
}

- (uint32) addWordListToDatabase:(NSArray*) wordList
{
    uint32 count = 0;
    
    for (NSString *word in wordList) {
        count += [self addWordToDatabase:word] ? 1 : 0;
    }
    return count;
}

- (NSString*) randomPuzzleWithLetterCount:(uint32) count longWord:(uint32) letters
{
    // Create a new random puzzle with a word of at least this many letters
    uint32 tries = 0;
    
    // No words added
    if (_letterArray.count == 0) {
        return nil;
    }
    
    PuzzleLetter *startingLetter;
    
    while (tries < 500) {
        // Get random starting letter
        startingLetter = nil;
        
        // Random index
        uint32 index = arc4random_uniform(_letterCount);
        uint32 letterBase = 0;
        
        for (PuzzleLetter *letter in _letterArray) {
            letterBase += letter.amount;
            if (index < letterBase) {
                startingLetter = letter;
                break;
            }
        }
        
        // Get a random letter either from starting letter's neighbors or just any letter
        
        tries++;
    }
    
    return nil;
}

@end
