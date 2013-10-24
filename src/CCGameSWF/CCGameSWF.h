//
//  CCGameSWF.h
//  CCGameSWF
//
//  Created by dario on 13-02-22.
//
//

@protocol CCSWFFscommandResponder <NSObject>
@optional
-(void) movieNamed:(NSString*)movieName sentCommand:(NSString*)command withArguments:(NSString*)args;
@end

@interface CCGameSWF : NSObject <CCSWFFscommandResponder>
{
    NSMutableDictionary *m_fscommandListeners;
}

+(CCGameSWF*) sharedInstance;

-(void) addFscommandResponder:(id<CCSWFFscommandResponder>)responder forMovieNamed:(NSString*)movieName;
-(void) removeFscommandResponder:(id<CCSWFFscommandResponder>)responder forMovieNamed:(NSString*)movieName;

@end
