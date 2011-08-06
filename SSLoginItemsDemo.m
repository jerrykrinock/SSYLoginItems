//#import <Foundation/Foundation.h>
//#import <CoreServices/CoreServices.h>
#import "SSYLoginItems.h"

NSString* const kSafariPath = @"/Applications/Safari.app" ;

void TestIsLoginItem(
					 NSString* path,
					 BOOL doLog,
					 BOOL* isLoginItem_p,
					 BOOL* isHidden_p) {
	NSNumber* loginItem = nil ;
	NSNumber* hidden = nil ;
	NSError* error = nil ;
	BOOL ok = [SSYLoginItems isURL:[NSURL fileURLWithPath:path]
						 loginItem:&loginItem
							hidden:&hidden
							 error:&error] ;
	if (!ok) {
		NSLog([error description]) ;
	}
	
	if (doLog) {
		NSLog(@"isLoginItem=%@ hidden=%@ for %@", loginItem, hidden, path) ;
	}
	
	if (isLoginItem_p != NULL) {
		*isLoginItem_p = [loginItem boolValue] ;
	}
	
	if (isHidden_p != NULL) {
		*isHidden_p = [hidden boolValue] ;
	}
}	


void TestIsSafariLoginItem(BOOL expectedIsLoginItem, BOOL expectedHidden) {
	BOOL actualIsLoginItem ;
	BOOL actualIsHidden ;
	TestIsLoginItem(
					kSafariPath,
					NO,
					&actualIsLoginItem,
					&actualIsHidden
					) ;
	if ((expectedIsLoginItem == actualIsLoginItem) && (expectedHidden == actualIsHidden)) {
		NSLog(@"Did read expected result using API:  Safari isLoginItem=%d, isHidden=%d",
			  actualIsLoginItem,
			  actualIsHidden) ;
	}
	else {
		NSLog(@"Did read UNEXPECTED result using API for Safari:\n      isLoginItem: expected:%d, actual:%d\n      isHidden: expected%d, actual:%d",
			  expectedIsLoginItem,
			  actualIsLoginItem,
			  expectedHidden,
			  actualIsHidden) ;
	}
}

void MakeTestSafariLoginItemHidden(BOOL hidden) {
	NSLog(@"Will set Safari a Login Item with hidden=%d", hidden) ;
	NSError* error = nil ;
	char charNotUsed ;
	[SSYLoginItems addLoginURL:[NSURL fileURLWithPath:kSafariPath]
					   hidden:[NSNumber numberWithBool:hidden]
						error:&error] ;
	if (error != nil) {
		NSLog([error description]) ;
		goto end ;
	}
	NSLog(@"Did set Safari a Login Item with hidden=%d", hidden) ;
	TestIsSafariLoginItem(YES, hidden) ;
	NSLog(@"Verify that Safari is a login item with hidden=%d.", hidden) ;
	NSLog(@"Then press 'return' to continue.") ;
	scanf ("%c", &charNotUsed) ;
end: 
	;
}

void RemoveTestSafariLoginItem() {
	NSLog(@"Will remove Safari from Login Items.") ;
	NSError* error = nil ;
	char charNotUsed ;
	[SSYLoginItems removeLoginURL:[NSURL fileURLWithPath:kSafariPath]
						   error:&error] ;
	if (error != nil) {
		NSLog([error description]) ;
		goto end ;
	}
	TestIsSafariLoginItem(NO, NO) ;
	NSLog(@"Verify that Safari is not a login item.") ;
	NSLog(@"Then press 'return' to continue.") ;
	scanf ("%c", &charNotUsed) ;
end:
	;
}

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	// Fill in some application paths which may or may not be in your
	// System Preferences > Login Items, and see if the correct answer
	// is printed in the console output.
	NSLog(@"****** TEST #1 ***********") ;
	TestIsLoginItem(@"/Applications/NoSuchApp.app", YES, NULL, NULL) ;
	TestIsLoginItem(@"/Applications/Pages.app", YES, NULL, NULL) ;
	TestIsLoginItem(@"/Applications/Automator.app", YES, NULL, NULL) ;
	TestIsLoginItem(@"/Applications/Mail.app", YES, NULL, NULL) ;
	TestIsLoginItem(@"/Applications/iTunes.app", YES, NULL, NULL) ;
	TestIsLoginItem(@"/Applications/Chess.app", YES, NULL, NULL) ;
	TestIsLoginItem(@"/Applications/Path Finder.app", YES, NULL, NULL) ;
	TestIsLoginItem(@"/Applications/iChat.app", YES, NULL, NULL) ;
	NSLog(@"Look in your System Preferences > Accounts > Login Items.") ;
	NSLog(@"Compare and verify the above findings.") ;
	NSLog(@"Then press 'return' to continue.") ;
	char charNotUsed ;
	scanf ("%c", &charNotUsed) ;

	NSURL* url = [NSURL fileURLWithPath:kSafariPath] ;
	NSNumber* isLogin ;
	NSNumber* hidden = nil ;
	
	NSNumber* safariWasLogin ;
	NSNumber* safariWasHidden ;
	NSError* error = nil ;

	// See if Safari is a Login Item
	BOOL ok = [SSYLoginItems isURL:url
						 loginItem:&isLogin
							hidden:&hidden
							 error:&error] ;
	if (!ok) {
		NSLog([error description]) ;
	}
	safariWasLogin = isLogin ; // so we can set it back for you later
	safariWasHidden = hidden ; // so we can set it back for you later

	NSLog(@"****** TEST #2 ***********") ;
	NSLog(@"Initally, API finds that Safari isLogin=%@ hidden=%@", isLogin, hidden) ;				
	NSLog(@"Compare and verify the above findings.") ;
	NSLog(@"Then press 'return' to continue.") ;
	scanf ("%c", &charNotUsed) ;
	
	// Make Safari a login item, not hidden
	NSLog(@"****** TEST #3 ***********") ;
	MakeTestSafariLoginItemHidden(NO) ;
	
	// Remove Safari from login items
	NSLog(@"****** TEST #4 ***********") ;
	RemoveTestSafariLoginItem() ;

	// Make Safari a login item, hidden
	NSLog(@"****** TEST #5 ***********") ;
	MakeTestSafariLoginItemHidden(YES) ;
	
	// Set back to original setting
	NSLog(@"Restoring your Login Items to their initial state regarding Safari.") ;
	if ([safariWasLogin boolValue]) {
		MakeTestSafariLoginItemHidden([safariWasHidden boolValue]) ;
	}
	else {
		RemoveTestSafariLoginItem() ;
	}
	
	NSLog(@"This demo program has completed.") ;
	[pool drain] ;

	return 0 ;
}
