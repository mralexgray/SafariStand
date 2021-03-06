//
//  STSTitleBarModule.m
//  SafariStand


#import "SafariStand.h"
#import "STSTitleBarModule.h"

#import "STSafariConnect.h"

@implementation STSTitleBarModule

BOOL showingPathPopUpMenu;

IMP orig_showPathPopUpMenu;
void ST_showPathPopUpMenu(id self, SEL _cmd){
    showingPathPopUpMenu=YES;
    orig_showPathPopUpMenu(self, _cmd);
    showingPathPopUpMenu=NO;
}
IMP orig_popUpContextMenu;
void ST_popUpContextMenu(id self, SEL _cmd, NSMenu* menu, NSPoint pt, double width, NSView* view, long long selection, id font,
                         unsigned long long arg7, id arg8){
    
    if(showingPathPopUpMenu && [[NSUserDefaults standardUserDefaults]boolForKey:kpImprovePathPopupMenu]){
        [[STCSafariStandCore mi:@"STSTitleBarModule"]alterPathPopUpMenu:menu];

    }
    orig_popUpContextMenu(self, _cmd, menu, pt, width, view, selection, font, arg7, arg8);
}

- (id)initWithStand:(id)core
{
    self = [super initWithStand:core];
    if (self) {

        showingPathPopUpMenu=NO;
        orig_showPathPopUpMenu = RMF(NSClassFromString(@"TitleBarButton"),
                                                       @selector(showPathPopUpMenu), ST_showPathPopUpMenu);
        orig_popUpContextMenu = RMF(NSClassFromString(@"NSCarbonMenuImpl"),
                                @selector(popUpMenu:atLocation:width:forView:withSelectedItem:withFont:withFlags:withOptions:), ST_popUpContextMenu);
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)prefValue:(NSString*)key changed:(id)value
{
    //if([key isEqualToString:])
}

- (void)alterPathPopUpMenu:(NSMenu*)menu
{
    /*
     _popUpItemAction:
     NSURL doNothing:
     NSURL goToMenuItemURL:
     
     */
    NSMenuItem* m;

    NSInteger i, cnt=[menu numberOfItems];
    for (i=cnt-1; i>=0; i--) {
        NSMenuItem* itm=[menu itemAtIndex:i];
        if([[itm representedObject]isKindOfClass:[NSURL class]] && [[itm title]hasPrefix:@"http"]){
            NSRange range=[[itm title]rangeOfString:@"://"];
            NSInteger idx=range.location+range.length;
            NSString* title;
            if(idx>=0){
                title=[[itm title]substringFromIndex:idx];
            }else{
                title=[itm title];
            }
            title=[NSString stringWithFormat:LOCALIZE(@"Google Site Search:%@"),title];
            NSMenuItem* altItem=[[NSMenuItem alloc]initWithTitle:title action:@selector(STGoogleSiteSearchMenuItemAction:) keyEquivalent:@""];
            [menu insertItem:altItem atIndex:i+1];
            [altItem setImage:[itm image]];
            [altItem setRepresentedObject:[itm representedObject]];
            [altItem setAlternate:YES];
            [altItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
            [altItem release];
        }
    }
    /*for (NSMenuItem* itm in [menu itemArray]) {

     id obj=[itm representedObject];
     if(obj)LOG(@"%@, %@, %@",[itm title], [obj className], NSStringFromSelector([itm action]));
        else LOG(@"xx:%@, %@",[itm title], NSStringFromSelector([itm action]));
    }*/
    
    i=1;
    if([[NSUserDefaults standardUserDefaults]boolForKey:kpCopyLinkTagAddTargetBlank]){
        m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag (_blank)")
                                    action:@selector(STCopyWindowURLTagBlank:) keyEquivalent:@""];
    }else{
        m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag")
                                    action:@selector(STCopyWindowURLTag:) keyEquivalent:@""];
    }
    [menu insertItem:m atIndex:i++];
    [m release];
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:kpCopyLinkTagAddTargetBlank]){
        m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag")
                                    action:@selector(STCopyWindowURLTag:) keyEquivalent:@""];
    }else{
        m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag (_blank)")
                                    action:@selector(STCopyWindowURLTagBlank:) keyEquivalent:@""];
    }
    [menu insertItem:m atIndex:i++];
    [m setAlternate:YES];
    [m setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [m release];

    
    
    m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link and Title") action:@selector(STCopyWindowTitleAndURL:) keyEquivalent:@""];
    [menu insertItem:m atIndex:i++];
    [m release];
    m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link (space) Title") action:@selector(STCopyWindowTitleAndURLSpace:) keyEquivalent:@""];
    [menu insertItem:m atIndex:i++];
    [m setAlternate:YES];
    [m setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [m release];
    
    
    m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Page Title") action:@selector(STCopyWindowTitle:) keyEquivalent:@""];
    [menu insertItem:m atIndex:i++];
    //[m setAlternate:YES];
    //[m setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [m release];
    m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link as Markdown") action:@selector(STCopyWindowTitleAndURLAsMarkdown:) keyEquivalent:@""];
    [menu insertItem:m atIndex:i++];
    [m release];
    m=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link as Hatena") action:@selector(STCopyWindowTitleAndURLAsHatena:) keyEquivalent:@""];
    [menu insertItem:m atIndex:i++];
    [m setAlternate:YES];
    [m setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [m release];

    if(![[menu itemAtIndex:i]isSeparatorItem]){
        [menu insertItem:[NSMenuItem separatorItem] atIndex:i++];
    }
    
    
}





@end
