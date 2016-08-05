//
//  CaptureSessionManager.m
//  StreetView
//
//  Created by Susan Rudd on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "CaptureSessionManager.h"


@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

- (void)addVideoInput {
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];	
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        

		if (!error) {
			if ([[self captureSession] canAddInput:videoIn]){
				[[self captureSession] addInput:videoIn];
                [self captureSession].sessionPreset = AVCaptureSessionPresetPhoto;
            }
			else
				NSLog(@"Couldn't add video input");		
		}
		else
			NSLog(@"Couldn't create video input");
	}
	else
		NSLog(@"Couldn't create video capture device");
}

- (void)dealloc {
    
	[[self captureSession] stopRunning];
    
	previewLayer = nil;
	captureSession = nil;
    
}


@end

