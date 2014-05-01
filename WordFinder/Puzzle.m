//
//  Puzzle.m
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

#import "Puzzle.h"
#import "WordDatabase.h"

@implementation Puzzle
{
    NSMutableArray *_firstLetters;
    
    NSString *_string;
    //char *_letters;
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
        //_letters = calloc(sizeof(char), width * height);
        _width = width;
        _height = height;
        _length = width * height;
        
        /*const char *word = [string UTF8String];
        
        // strcpy
        unsigned int i = 0;
        unsigned int len = (unsigned int)string.length;
        while (i < width * height && i < len) {
            _letters[i] = word[i];
            i++;
        }
        _letters[i] = '\0';
        */
        
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

/*- (char) letterAtX:(int)x y:(int)y
{
    int index = _width * y + x;
    
    if (_letters == NULL || index >= _length) {
        return 0;
    }
    
    return _letters[index];
}*/

- (NSString*) stringAtX:(int)x y:(int)y
{
    int index = _width * y + x;
    
    if (_string == nil || index >= _string.length) {
        return 0;
    }
    
    return [_string substringWithRange:NSMakeRange(index, 1)];
}

- (void) dealloc
{
    /*if (_letters != NULL) {
        free(_letters);
        _letters = NULL;
    }*/
}

@end
