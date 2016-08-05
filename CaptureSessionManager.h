//
//  CaptureSessionManager.h
//  StreetView
//
//  Created by Susan Rudd on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


@interface CaptureSessionManager : NSObject {
    
}

@property  AVCaptureVideoPreviewLayer *previewLayer;
@property  AVCaptureSession *captureSession;

- (void)addVideoPreviewLayer;
- (void)addVideoInput;

@end
