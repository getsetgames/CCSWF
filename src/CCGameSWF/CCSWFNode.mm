//
//  CCSWFNode.m
//
//  Created by dario on 13-02-25.
//
//

#import "CCSWFNode.h"
#import "CCGameSWF.h"
#import "cocos2d.h"
#import "gameswf.h"
#import "gameswf_player.h"
#import "gameswf_root.h"
#import "ccMacros.h"
#import "gameswf_types.h"
#import "gameswf_impl.h"

@interface CCSWFNode_touchContainer : NSObject
{
    CGPoint m_position;
    int m_state;
}

@property (readonly) CGPoint position;
@property (readonly) int state;

+(id) touchContainerWithPosition:(CGPoint)position andState:(int)state;
-(id) initWithPosition:(CGPoint)position andState:(int)state;

@end

@implementation CCSWFNode_touchContainer

@synthesize position = m_position;
@synthesize state = m_state;

+(id) touchContainerWithPosition:(CGPoint)position andState:(int)state
{
    return [[[CCSWFNode_touchContainer alloc] initWithPosition:position andState:state] autorelease];
}

-(id) initWithPosition:(CGPoint)position andState:(int)state
{
    self = [super init];
    if (self)
    {
        m_position = position;
        m_state = state;
    }
    return self;
}

@end

@interface CCSWFNode_imp : NSObject
{
    @public
    gameswf::gc_ptr<gameswf::player> m_player;
    gameswf::gc_ptr<gameswf::root>	m_movie;
}

+(gameswf::gc_ptr<gameswf::player>) sharedPlayer;
-(id) initWithSWFFile:(NSString*)file;

@end

@implementation CCSWFNode_imp

+(gameswf::gc_ptr<gameswf::player>) sharedPlayer
{
    static gameswf::gc_ptr<gameswf::player> k_player = new gameswf::player();
    return k_player;
}

-(id) initWithSWFFile:(NSString *)file
{
    self = [super init];
    if (self)
    {
        // make sure CCGameSWF is initialized //
        [CCGameSWF sharedInstance];
        m_player = [[self class] sharedPlayer];
        m_player->set_separate_thread(false);
        m_movie = m_player->load_file([file UTF8String]);
        if (m_movie == NULL)
        {
            printf("ERROR: Cannot open input file %s", [file UTF8String]);
            [self release];
            return nil;
        }
    }
	
	return self;
}

-(void) dealloc
{
    m_movie = NULL;
    m_player = NULL;
    [super dealloc];
}

@end



@implementation CCSWFNode

@synthesize autoUpdate = m_autoUpdate;
-(void) setAutoUpdate:(BOOL)autoUpdate
{
    if (self.isRunning)
    {
        if (!autoUpdate && m_autoUpdate)
        {
            [self unscheduleUpdate];
        }
        else if (autoUpdate && !m_autoUpdate)
        {
            [self scheduleUpdate];
        }
    }
    
    m_autoUpdate = autoUpdate;
}

-(NSString*) movieName
{
    return [NSString stringWithUTF8String:imp->m_movie->m_movie->m_name.c_str()];
}

-(void) setMovieName:(NSString *)movieName
{
    imp->m_movie->m_movie->m_name = [movieName UTF8String];
}

-(CGSize) displayContentSize
{
    return CGSizeMake(self.contentSize.width * m_localScaleX, self.contentSize.height * m_localScaleY);
}

-(CGSize) displayContentSizeInPixels
{
    return CGSizeMake(self.contentSizeInPixels.width * m_localScaleX, self.contentSizeInPixels.height * m_localScaleY);
}

+(id) nodeWithSWFFile:(NSString*)file
{
    return [[[CCSWFNode alloc] initWithSWFFile:file] autorelease];
}

-(id) initWithSWFFile:(NSString*)file
{
    self = [super init];
    if (self)
    {
        imp = [[CCSWFNode_imp alloc] initWithSWFFile:file];
        if (!imp)
        {
            [self release];
            return nil;
        }
        m_movieWidth = imp->m_movie->m_def->m_frame_size.m_x_max - imp->m_movie->m_def->m_frame_size.m_x_min;
        m_movieHeight = imp->m_movie->m_def->m_frame_size.m_y_max - imp->m_movie->m_def->m_frame_size.m_y_min;
        m_localScaleX = (imp->m_movie->get_movie_width() / m_movieWidth);
        m_localScaleY = -(imp->m_movie->get_movie_height() / m_movieHeight);
        m_scaleX = 1.0;
        m_scaleY = 1.0;
        
        m_touchEvents = [[NSMutableArray alloc] init];
        
        [self setContentSizeInPixels:CGSizeMake(m_movieWidth, m_movieHeight)];
        [self setScale:1.0];
        [self setAnchorPoint:ccp(0.5f, 0.5f)];
    }
    return self;
}

-(float) scale
{
    NSAssert( m_scaleX == m_scaleY, @"CCNode#scale. ScaleX != ScaleY. Don't know which one to return");
	return m_scaleX;
}

-(void) setScale:(float)scale
{
    m_scaleX = m_scaleY = scale;
    [super setScaleX:m_localScaleX * m_scaleX];
    [super setScaleY:m_localScaleY * m_scaleY];
}

-(float) scaleX
{
    return m_scaleX;
}

-(void) setScaleX:(float)scaleX
{
    m_scaleX = scaleX;
    [super setScaleX:m_localScaleX * m_scaleX];
}

-(float) scaleY
{
    return m_scaleY;
}

-(void) setScaleY:(float)scaleY
{
    m_scaleY = scaleY;
    [super setScaleY:m_localScaleY];
}

-(void) dealloc
{
    [m_touchEvents release];
    [imp release];
    [super dealloc];
}

-(void) onEnter
{
    if (m_autoUpdate)
    {
        [self scheduleUpdate];
    }
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
    [super onEnterTransitionDidFinish];
}

-(void) onExit
{
    [self unscheduleAllSelectors];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(CGPoint) getTouchInMovieCoordinates:(UITouch*)touch
{
    // find the movie rect in pixels //
    CGRect movieRect = CGRectMake(
                                  self.positionInPixels.x - (self.contentSizeInPixels.width * super.scaleX * self.anchorPoint.x),
                                  self.positionInPixels.y - (self.contentSizeInPixels.height * -super.scaleY * self.anchorPoint.y),
                                  self.contentSizeInPixels.width * super.scaleX,
                                  self.contentSizeInPixels.height * -super.scaleY
                                  );
    
    // find the touch position in pixels //
    CGPoint touchPoint = ccpMult([[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]], CC_CONTENT_SCALE_FACTOR());

    // find the touch position in respect to the movie //
    CGPoint touchInMovie = ccp(
                               (touchPoint.x - movieRect.origin.x) / m_scaleX,
                               ((self.contentSizeInPixels.height * -super.scaleY) - (touchPoint.y - movieRect.origin.y)) / m_scaleY
                               );
    
    return touchInMovie;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // make rect for movie //
    CGRect movieRect = CGRectMake(0, 0, (self.contentSizeInPixels.width * super.scaleX), (self.contentSizeInPixels.height * -super.scaleY));
    // find the touch position in pixels //
    CGPoint touchPoint = [self getTouchInMovieCoordinates:touch];
    BOOL isInMovie = CGRectContainsPoint(movieRect, touchPoint);
    [m_touchEvents addObject:[CCSWFNode_touchContainer touchContainerWithPosition:touchPoint andState:0]];
    [m_touchEvents addObject:[CCSWFNode_touchContainer touchContainerWithPosition:touchPoint andState:1]];
    return isInMovie;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    [m_touchEvents addObject:[CCSWFNode_touchContainer touchContainerWithPosition:[self getTouchInMovieCoordinates:touch] andState:1]];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [m_touchEvents addObject:[CCSWFNode_touchContainer touchContainerWithPosition:[self getTouchInMovieCoordinates:touch] andState:0]];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [m_touchEvents addObject:[CCSWFNode_touchContainer touchContainerWithPosition:[self getTouchInMovieCoordinates:touch] andState:0]];
}

-(void) update:(ccTime)dt
{
    if (m_touchEvents.count)
    {
        CCSWFNode_touchContainer *touch = [m_touchEvents objectAtIndex:0];
        imp->m_movie->notify_mouse_state(touch.position.x, touch.position.y, touch.state);
        [m_touchEvents removeObjectAtIndex:0];
    }
    
    imp->m_movie->advance(dt);
    // TODO: Enable sound //
    // sound->advance(dt);
}

-(const char*) callFuncationNamed:(NSString*)functionName withArguments:(NSString*)argsFormat, ...
{
    va_list	args;
    va_start(args, argsFormat);
    const char*	result = imp->m_movie->call_method_args([functionName UTF8String], [argsFormat UTF8String], args);
    va_end(args);
    
    return result;
}

-(void) draw
{
    CC_DISABLE_DEFAULT_GL_STATES();
    
    glEnable(GL_BLEND);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDisable(GL_TEXTURE_2D);
    
	imp->m_movie->display();
    
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    
    CC_ENABLE_DEFAULT_GL_STATES();
}

@end
