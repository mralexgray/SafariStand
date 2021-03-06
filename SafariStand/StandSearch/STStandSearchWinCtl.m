//
//  STStandSearchWinCtl.m
//  SafariStand


#import "SafariStand.h"
#import "STStandSearchWinCtl.h"
#import "STStandSearchViewCtl.h"


@implementation STStandSearchWinCtl
STStandSearchWinCtl* sharedStandSearchWinCtl;

@synthesize viewCtl;

+ (void)showStandSearcWindow
{
    if(!sharedStandSearchWinCtl){
        sharedStandSearchWinCtl=[[STStandSearchWinCtl alloc]initWithWindowNibName:@"STStandSearchWinCtl"];
    }
    [sharedStandSearchWinCtl showWindow:nil];
}


- (void)dealloc
{
    self.viewCtl=nil;
    [super dealloc];
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    self.viewCtl=[STStandSearchViewCtl viewCtl];
    NSView* swView=[self.viewCtl view];//load
    
    //addSubview
    NSRect bounds=[[[self window]contentView]bounds];
    [[[self window]contentView] addSubview:swView];
    [swView setFrame:NSMakeRect(0, 0, bounds.size.width, bounds.size.height)];
    [swView setBounds:NSMakeRect(0, 0, bounds.size.width, bounds.size.height)];
    
    [super windowDidLoad];
    
    [[super window] makeFirstResponder:self.viewCtl.searchField];

    [[self window] setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
    
    [[self window] setContentBorderThickness:30.5 forEdge:NSMinYEdge];

}

- (void)windowWillClose:(NSNotification *)aNotification
{
    if(sharedStandSearchWinCtl==self){
        sharedStandSearchWinCtl=nil;
    }
    
    [self autorelease];
}


@end
