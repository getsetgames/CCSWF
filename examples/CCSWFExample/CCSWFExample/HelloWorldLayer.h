//
//  HelloWorldLayer.h
//  CCSWFExample
//
//  Created by dario on 13-03-12.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCGameSWF.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <CCSWFFscommandResponder>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
