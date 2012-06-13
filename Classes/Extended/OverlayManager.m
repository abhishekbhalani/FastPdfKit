//
//  OverlayManager.m
//  SampleProject
//

#import "OverlayManager.h"

/** 
 Just import every Extension you need, that's it!
 */

#import <FPKYouTube/FPKYouTube.h>
#import <FPKMap/FPKMap.h>
#import <FPKGalleryFade/FPKGalleryFade.h>
#import <FPKGalleryTap/FPKGalleryTap.h>
#import <FPKMessage/FPKMessage.h>
#import <FPKWebPopup/FPKWebPopup.h>
#import <FPKGallerySlide/FPKGallerySlide.h>
#import <FPKPayPal/FPKPayPal.h>

@implementation OverlayManager

- (id)init {
    
	self = [super init];
	if (self != nil)
	{
		NSArray * exts = [[NSArray alloc] initWithObjects:@"FPKPayPal", @"FPKGallerySlide", @"FPKWebPopup", @"FPKMessage", @"FPKGalleryTap", @"FPKMap", @"FPKYouTube", @"FPKGalleryFade", nil];
		[self setExtensions:exts];
        [exts release];
        
	}
	return self;
}

@end
