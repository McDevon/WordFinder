//
//  PuzzleSolution.m
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
