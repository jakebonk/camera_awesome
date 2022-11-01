//
//  ImageStreamController.m
//  camerawesome
//
//  Created by Dimitri Dessus on 17/12/2020.
//

#import "ImageStreamController.h"

@implementation ImageStreamController

- (instancetype)initWithEventSink:(FlutterEventSink)imageStreamEventSink {
  self = [super init];
  _imageStreamEventSink = imageStreamEventSink;
  _streamImages = imageStreamEventSink != nil;
  return self;
}

# pragma mark - Camera Delegates
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
  int w = CVPixelBufferGetWidth(pixelBuffer);
      int h = CVPixelBufferGetHeight(pixelBuffer);
      int r = CVPixelBufferGetBytesPerRow(pixelBuffer);
      int bytesPerPixel = r/w;

      unsigned char *buffer = CVPixelBufferGetBaseAddress(pixelBuffer);

      UIGraphicsBeginImageContext(CGSizeMake(w, h));

      CGContextRef c = UIGraphicsGetCurrentContext();

      unsigned char* data = CGBitmapContextGetData(c);
      if (data != NULL) {
         int maxY = h;
         for(int y = 0; y<maxY; y++) {
            for(int x = 0; x<w; x++) {
               int offset = bytesPerPixel*((w*y)+x);
               data[offset] = buffer[offset];     // R
               data[offset+1] = buffer[offset+1]; // G
               data[offset+2] = buffer[offset+2]; // B
               data[offset+3] = buffer[offset+3]; // A
            }
         }
      }
      UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
      NSData *res = UIImageJPEGRepresentation(img,1.0);
  // Only send bytes for now
  _imageStreamEventSink(res);
  
  CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
}

@end
