//
//  PuzzleSolution.h
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

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
@property NSString *letter;
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
