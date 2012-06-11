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

- (FPKOverlayManager *)init
{
	self = [super init];
	if (self != nil)
	{
		/**
            Add Extensions to the array, or use the initWithExtension: method         
         */
        
        NSArray * exts = [[NSArray alloc] initWithObjects:@"FPKPayPal", @"FPKWebPopup", @"FPKGallerySlide", @"FPKMessage", @"FPKGalleryTap", @"FPKMap", @"FPKYouTube", @"FPKGalleryFade", nil];
                
		[self setExtensions:exts];
        
        // TODO: fix the fact that when properly released, the
        // document view controller will crash. Likely, extension is not
        // retained properly
        
        //[exts release]; 
	}
	return self;
}


@end
