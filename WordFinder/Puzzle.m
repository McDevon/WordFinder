//
//  Puzzle.m
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

#import "Puzzle.h"
#import "WordDatabase.h"

@implementation Puzzle
{
    NSMutableArray *_firstLetters;
    
    NSString *_string;
    int _width;
    int _height;
    int _length;
}

+ (instancetype) puzzleWithString:(NSString*)string width:(int)width height:(int)height
{
    return [[self alloc] initWithString:string width:width height:height];
}

- (id) initWithString:(NSString*)string width:(int)width height:(int)height
{
    if (self = [super init]) {
        _string = string;

        _width = width;
        _height = height;
        _length = width * height;
        
        // Create first letter list
        _firstLetters = [[NSMutableArray alloc] init];
        
        if (string.length >= _length) {
            for (int i = 0; i < _length; i++) {
                SolutionLetter *letter = [[SolutionLetter alloc] init];
                
                letter.letter = [string substringWithRange:NSMakeRange(i, 1)];
                
                [_firstLetters addObject:letter];
            }
            
            // Create links
            for (int y = 0; y < _height; y++) {
                for (int x = 0; x < _width; x++) {
                    int index = _width * y + x;
                    SolutionLetter * letter = [_firstLetters objectAtIndex:index];
                    letter.position = lpm(x, y);
                    
                    for (int j = MAX(0, y - 1); j <= MIN(_height - 1, y + 1); j++) {
                        for (int i = MAX(0, x - 1); i <= MIN(_width - 1, x + 1); i++) {
                            int targetIndex = _width * j + i;
                            SolutionLetter *target = [_firstLetters objectAtIndex:targetIndex];
                            [letter.nextLetters addObject:target];
                        }
                    }
                }
            }

        }
        
    }
    
    return self;
}

- (NSString*) stringAtX:(int)x y:(int)y
{
    int index = _width * y + x;
    
    if (_string == nil || index >= _string.length) {
        return 0;
    }
    
    return [_string substringWithRange:NSMakeRange(index, 1)];
}

@end
