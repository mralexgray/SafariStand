//
//  STPrefWindowModule.m
//  SafariStand


#import "SafariStand.h"
#import "STPrefWindowModule.h"

#import "STSDownloadModule.h"
#import "STSContextMenuModule.h"




@implementation STPrefWindowModule

/*
 @interface SCUserDefaults : NSUserDefaults
 - (id)objectForKey:(id)arg1;
 - (void)setObject:(id)arg1 forKey:(id)arg2;
 - (void)removeObjectForKey:(id)arg1;
 - (void)registerDefaults:(id)arg1;
 - (BOOL)synchronize;
 */


-(id)initWithStand:(STCSafariStandCore*)core
{
    self = [super initWithStand:core];
    if (self) { 
        //SafariStand Setting
        NSMenu *standMenu=core.standMenu;
        [standMenu addItem:[NSMenuItem separatorItem]];
        id m=[standMenu addItemWithTitle:@"SafariStand Setting..." action:@selector(actShowPrefWindow:) keyEquivalent:@","];
        [m setKeyEquivalentModifierMask:NSCommandKeyMask|NSAlternateKeyMask];
        [m setTarget:self];
        [m setTag:kMenuItemTagSafariStandSetting];
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}

-(IBAction)actShowPrefWindow:(id)sender{
    if(!prefWinCtl){
        prefWinCtl=[[STPrefWindowCtl alloc]initWithWindowNibName:@"STCPrefWin"];
        [prefWinCtl window];
        [[STCSafariStandCore si]sendMessage:@selector(stMessagePrefWindowLoaded:) toAllModule:self];
    }
    [prefWinCtl showWindow:self];
}



-(void)addPane:(NSView*)view withIdentifier:(NSString*)identifier title:(NSString*)title icon:(NSImage*)icon
{
    [prefWinCtl addPane:view withIdentifier:identifier title:title icon:icon];
}



@end


@implementation STPrefWindowCtl
@synthesize oCurrentVarsionLabel=_oCurrentVarsionLabel;
@synthesize currentVersionString=_currentVersionString;
@synthesize latestVersionString=_latestVersionString;
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {

        self.currentVersionString=[[STCSafariStandCore si]currentVersionString];
        self.latestVersionString=[[STCSafariStandCore si]latestVersionString];
        
        //other plugin support
        otherDefaults=nil;
        id sudc=[NSUserDefaultsController sharedUserDefaultsController];
        id dflts=[sudc defaults];
        //NSUserDefaults or SCUserDefaults
        if (![[dflts className]isEqualToString:@"NSUserDefaults"] && [sudc respondsToSelector:@selector(_setDefaults:)]) {
            otherDefaults=[dflts retain];
            LOG(@"sharedUserDefaultsController %@", [otherDefaults className]);
        }
    }
    return self;
}



- (void)windowDidBecomeKey:(NSNotification *)notification
{
    //other plugin support
    if(otherDefaults){
        objc_msgSend([NSUserDefaultsController sharedUserDefaultsController], 
                     @selector(_setDefaults:), [NSUserDefaults standardUserDefaults]);

    }

}
- (void)windowDidResignKey:(NSNotification *)notification
{

    //other plugin support
    //シートでもresignするから注意
    if(otherDefaults){
        objc_msgSend([NSUserDefaultsController sharedUserDefaultsController], 
                     @selector(_setDefaults:), otherDefaults);
        
    }
    
}


- (void)windowWillClose:(NSNotification *)notification{
    [[STCSafariStandCore si]sendMessage:@selector(stMessagePrefWindowWillClose:) toAllModule:self];

}

//STSDownloadModule

- (IBAction)actShowDownloadFolderAdvanedSetting:(id)sender
{
    if([[self window]attachedSheet])return;
    
    STSDownloadModule* dlModule=[STCSafariStandCore mi:@"STSDownloadModule"];
    NSWindow* sheet=[dlModule advancedSettingSheet];
    [NSApp beginSheet:sheet modalForWindow:[self window] modalDelegate:[sheet delegate]
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)actShowSquashCMAdvanedSetting:(id)sender
{
    if([[self window]attachedSheet])return;
    
    STSContextMenuModule* cmModule=[STCSafariStandCore mi:@"STSContextMenuModule"];
    NSWindow* sheet=[cmModule advancedSquashSettingSheet];
    [NSApp beginSheet:sheet modalForWindow:[self window] modalDelegate:[sheet delegate]
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}



@end