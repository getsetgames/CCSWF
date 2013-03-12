//
//  HelloWorldLayer.m
//  CCSWFExample
//
//  Created by dario on 13-03-12.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCSWFNode.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        // ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        // load and add the "Hello World" flash movie to the hierarchy //
        CCNode *swf = [CCSWFNode nodeWithSWFFile:[[NSBundle mainBundle] pathForResource:@"HelloWorld" ofType:@"swf"]];
        [self addChild:swf];
        // position it on the center of the screen //
        swf.position =  ccp( size.width /2 , size.height/2 );
        // register as listeners to the fscommands from the swf movie //
        [[CCGameSWF sharedInstance] addFscommandResponder:self forMovieNamed:[(CCSWFNode*)swf movieName]];
        // scale it down if the device is not retina //
        //swf.scale = 0.5f * CC_CONTENT_SCALE_FACTOR(); // WARNING: Scalinf the movie breaks touches //
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) movieNamed:(NSString*)movieName sentCommand:(NSString*)command withArguments:(NSString*)args
{
    if ([command isEqualToString:@"printSomething"])
    {
        NSLog(@"%@", args);
    }
}
@end
