//
//  CCSWFNode.h
//
//  Created by dario on 13-02-25.
//
//

#import "CCNode.h"
#import "CCTouchDelegateProtocol.h"

@class CCSWFNode_imp;

@interface CCSWFNode : CCNode <CCTargetedTouchDelegate>
{
    CCSWFNode_imp *imp;
    GLfloat m_movieWidth;
    GLfloat m_movieHeight;
    GLfloat m_localScaleX;
    GLfloat m_localScaleY;
    GLfloat m_scaleX;
    GLfloat m_scaleY;
    NSMutableArray *m_touchEvents;
    
    BOOL m_autoUpdate;
}

@property (nonatomic, assign) BOOL autoUpdate;
@property (nonatomic, assign) NSString *movieName;
@property (nonatomic, readonly) CGSize displayContentSize;
@property (nonatomic, readonly) CGSize displayContentSizeInPixels;


+(id) nodeWithSWFFile:(NSString*)file;
-(id) initWithSWFFile:(NSString*)file;

-(void) update:(ccTime)dt;
-(const char*) callFuncationNamed:(NSString*)functionName withArguments:(NSString*)argsFormat, ...;

@end

