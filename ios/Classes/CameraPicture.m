//
//  CameraPicture.m
//  camerawesome
//
//  Created by Dimitri Dessus on 24/07/2020.
//

#import "CameraPicture.h"

@implementation CameraPicture {
  CameraPicture *selfReference;
}

- (instancetype)initWithPath:(NSString *)path
                 orientation:(NSInteger)orientation
                 captureSize:(CGSize)pictureSize
                      result:(FlutterResult)result {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _path = path;
    _result = result;
    _orientation = orientation;
    _pictureSize = pictureSize;
    selfReference = self;
    return self;
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
    didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer
                previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer
                        resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                         bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings
                                   error:(NSError *)error {
    selfReference = nil;
    if (error) {
        _result([FlutterError errorWithCode:@"" message:@"" details:@""]);
        return;
    }
    NSData *data = [AVCapturePhotoOutput
      JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer
                            previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithCGImage:[UIImage imageWithData:data].CGImage
                                       scale:1.0
                                 orientation:_orientation];
    // TODO(sigurdm): Consider writing file asynchronously.
    bool success = [UIImageJPEGRepresentation(image, 1.0) writeToFile:_path atomically:YES];
    if (!success) {
        _result([FlutterError errorWithCode:@"IOError" message:@"Unable to write file" details:nil]);
        return;
    }
    _result(nil);
}

@end
