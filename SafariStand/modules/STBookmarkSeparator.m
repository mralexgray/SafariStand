//
//  STBookmarkSeparator.m
//  SafariStand


#import "SafariStand.h"
#import "STBookmarkSeparator.h"
#import "STSafariConnect.h"

#define kSeparatorStr	@"-:-"
#define kSeparatorLength	3

@implementation STBookmarkSeparator
@synthesize orig_addMenuItemForBookmark;

static id ST_addMenuItemForBookmark_with(id self, SEL _cmd, id bookmark, id tabLocation, id menu)
{

	id returnValue=nil;
    static STBookmarkSeparator* bookmarkSeparator;
    if(!bookmarkSeparator)bookmarkSeparator=[STCSafariStandCore mi:@"STBookmarkSeparator"];

    returnValue=[bookmarkSeparator menuItemForBookmarkLeaf:bookmark];
    if(returnValue){
        [menu addItem:returnValue];
        return returnValue;
    }
    
	returnValue=[bookmarkSeparator orig_addMenuItemForBookmark](self, _cmd, bookmark, tabLocation, menu);    
    
	return returnValue;
}

//bookmark追加ポップアップメニューに区切り線フォルダを表示しない
//-(id)[NewBookmarksController _addBookmarkFolder:toMenu:]
IMP orig_addBookmarkFolder_toMenu;

static id ST_addBookmarkFolder_toMenu(id self, SEL _cmd, id bookmark, id menu){
    NSString* title=STWebBookmarkTitle(bookmark);
    if ([title hasPrefix:kSeparatorStr]) {
        return nil;
    }

    return orig_addBookmarkFolder_toMenu(self, _cmd, bookmark, menu);
}

-(id)initWithStand:(id)core
{
    self = [super init];
    if (self) {
        Class tmpClas;
        tmpClas=NSClassFromString(@"BookmarksControllerObjC");
        if(tmpClas){
            //gSeparatorIcon=[[NSImage alloc]initWithSize:NSMakeSize(1,16)];
            orig_addMenuItemForBookmark = RMF(
                        tmpClas,
                        @selector(addMenuItemForBookmark:withTabPlacementHint:toMenu:),
                        ST_addMenuItemForBookmark_with);
        }
        
        tmpClas=NSClassFromString(@"NewBookmarksController");
        if(tmpClas){
            //bookmark追加ポップアップメニューに区切り線フォルダを表示しない
            orig_addBookmarkFolder_toMenu = RMF(
                        tmpClas,
                        @selector(_addBookmarkFolder:toMenu:),
                        ST_addBookmarkFolder_toMenu);
        }    
    }
    
    return self;
}



//セパレータにする
-(NSMenuItem*)menuItemForBookmarkLeaf:(id)bookmarkLeaf
{
	id returnValue=nil;
    
    int bookmarkType=STWebBookmarkType(bookmarkLeaf);
    
	if(bookmarkType==wbFolder){
		//this is WebBookmarkLeaf
		NSString *menuTitle=nil;
		BOOL	isSeparator=NO;

        NSString*   title=STWebBookmarkTitle(bookmarkLeaf);
        if([title hasPrefix:kSeparatorStr]){
            isSeparator=YES;
            if([title length]==kSeparatorLength)return [NSMenuItem separatorItem];
            else menuTitle=[title substringFromIndex:kSeparatorLength];
            
            if(!menuTitle)return [NSMenuItem separatorItem];
			if([menuTitle length]==1){
				if([menuTitle isEqualToString:@"."]){
					menuTitle=@" ";
				}
			}
            returnValue=[[NSMenuItem alloc]initWithTitle:menuTitle action:@selector(standdummyselector) keyEquivalent:@""];
			//returnValue=[menu addItemWithTitle:menuTitle action:@selector(standdummyselector) keyEquivalent:@""];
			[returnValue setTarget:nil];
			[returnValue setEnabled:NO];
            [returnValue autorelease];
			//[returnValue setRepresentedObject:nil];

		}
	}		
    
	return returnValue;    
}
@end
