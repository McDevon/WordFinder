//
//  PuzzleSolution.m
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

#import "PuzzleSolution.h"

@implementation SolutionLetter
{
    //char _letter;
    NSString *_letter;
    NSMutableArray *_nextLetters;
    
    // For searching
    LetterPosition _position;
    int _depth;
    BOOL _used;
}

- (id) init
{
    if (self = [super init]) {
        _nextLetters = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end



@implementation PuzzleSolution
{
    NSString *_word;
    LetterPosition _positions[32];
}

- (id) solutionByAppendingPosition:(LetterPosition) position andString:(NSString*) string
{
    PuzzleSolution *solution = [[PuzzleSolution alloc] init];
    for (int i = 0; i < 32; i++) {
        [solution setPosition:_positions[i] forLetterIndex:i];
    }
    solution.word = [_word stringByAppendingString:string];
    
    return solution;
}

- (LetterPosition) positionOfLetterIndex:(unsigned int)index
{
    // Sanity check
    if (index > 31) {
        return lpm(-1, -1);
    }
    
    return _positions[index];
}

- (void) setPosition:(LetterPosition) position forLetterIndex:(unsigned int)index
{
    // Sanity check
    if (index > 31) {
        return;
    }
    
    _positions[index] = position;
}

- (NSComparisonResult) compareWordLengths:(PuzzleSolution*) anotherSolution
{
    if (_word.length > anotherSolution.word.length) {
        return NSOrderedAscending;
    } else if (_word.length < anotherSolution.word.length) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

@end
