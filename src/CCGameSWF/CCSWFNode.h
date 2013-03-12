//
//  CCSWFNode.h
//  GSGGameSWF
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
    NSString *m_movieName;
    NSMutableArray *m_touchEvents;
}

+(id) nodeWithSWFFile:(NSString*)file;
-(id) initWithSWFFile:(NSString*)file;

@end

