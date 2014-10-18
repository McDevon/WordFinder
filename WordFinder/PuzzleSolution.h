//
//  PuzzleSolution.h
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

#import <Foundation/Foundation.h>

struct LetterPosition {
    int x;
    int y;
};

typedef struct LetterPosition LetterPosition;

static inline LetterPosition lpm(int x, int y)
{
    LetterPosition p; p.x = x; p.y = y; return p;
}

@interface SolutionLetter : NSObject

//@property char letter;
@property (copy) NSString *letter;
@property (retain) NSMutableArray *nextLetters;

@property LetterPosition position;
@property int depth;
@property BOOL used;

@end



@interface PuzzleSolution : NSObject

@property (copy) NSString *word;

- (NSComparisonResult) compareWordLengths:(PuzzleSolution*) anotherSolution;

- (id) solutionByAppendingPosition:(LetterPosition) position andString:(NSString*) string;

- (LetterPosition) positionOfLetterIndex:(unsigned int)index;
- (void) setPosition:(LetterPosition) position forLetterIndex:(unsigned int)index;

@end
