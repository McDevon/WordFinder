//
//  Puzzle.h
//  WordFinder
//
//  Created by Jussi Enroos on 30.4.2014.
//  Copyright (c) 2014 Jussi Enroos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Puzzle : NSObject

@property (retain) NSMutableArray *firstLetters;

+ (instancetype) puzzleWithString:(NSString*)string width:(int)width height:(int)height;

- (id) initWithString:(NSString*)string width:(int)width height:(int)height;

//- (char) letterAtX:(int)x y:(int)y;
- (NSString*) stringAtX:(int)x y:(int)y;

@end
