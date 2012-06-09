//
//  FaceDetector.m
//  SquareCam 
//
//  Created by Eduard Feicho on 07.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "FaceDetector.h"
#import "UIImageCVMatConverter.h"
#import "UIImage+Resize.h"

@interface FaceDetector(PrivateMethods)
- (cv::CascadeClassifier*)loadCascade:(NSString*)filename;
@end


@implementation FaceDetector

#pragma mark - Properties

@synthesize detectEyes;

#pragma mark - Constructor

- (id)init;
{
	self = [super init];
	if (self) {
#ifdef __cplusplus
		face_cascade = NULL;
		eyes_cascade = NULL;
#endif
		self.detectEyes = YES;
		
		[self loadCascades];
	}
	return self;
}

- (void)dealloc;
{
#ifdef __cplusplus
	if (face_cascade != NULL) delete face_cascade;
	if (eyes_cascade != NULL) delete eyes_cascade;
#endif
}

#pragma mark - Other Methods

- (void)loadCascades;
{
	face_cascade = [self loadCascade:@"haarcascade_frontalface_default"];
	eyes_cascade = [self loadCascade:@"haarcascade_eye"];
}


- (cv::CascadeClassifier*)loadCascade:(NSString*)filename;
{
	NSString *real_path = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
	cv::CascadeClassifier* cascade = new cv::CascadeClassifier();
	
	if (real_path != nil && !cascade->load([real_path UTF8String])) {
		NSLog(@"Unable to load cascade file %@.xml", filename);
	} else {
		NSLog(@"Loaded cascade file %@.xml", filename);
	}
	return cascade;
}


- (UIImage*)detectFaces:(UIImage*)image;
{
	std::vector<cv::Rect> faces;
	
	// convert to OpenCV mat
	cv::Mat cvMat = [UIImageCVMatConverter cvMatFromUIImage:image];
	cv::Mat grayMatOriginal = [UIImageCVMatConverter cvMatGrayFromUIImage:image];
	
	// scale input image for faster processing
	float scale = 2;
	cv::Mat grayMat =  cv::Mat((cvMat.rows / scale), (cvMat.cols / scale), CV_8UC3);
	cv::resize(grayMatOriginal, grayMat, grayMat.size(), 0, 0, CV_INTER_LINEAR);
	cv::equalizeHist(grayMat, grayMat);
	
	
	// haar detect
	float haar_scale = 1.1;
	int haar_minNeighbors = 2;
	int haar_flags = 0 | CV_HAAR_SCALE_IMAGE | CV_HAAR_DO_CANNY_PRUNING;
	cv::Size haar_minSize = cvSize(20, 20);
	
	face_cascade->detectMultiScale( grayMat, faces, haar_scale, haar_minNeighbors, haar_flags, haar_minSize );
	
	printf("Face detector: %lu faces detected\n", faces.size());
	
	
	// create a CGContext with the original image and 
	CGContextRef contextRef = [self createContextForImage:image];
	// draw faces
	[self context:contextRef drawFaces:faces scale:scale];
	
	if (detectEyes) {
		for( int i = 0; i < faces.size(); i++ ) {
			std::vector<cv::Rect> eyes;
			
			//-- In each face, detect eyes
			cv::Mat faceROI = grayMat( faces[i] );
			eyes_cascade->detectMultiScale( faceROI, eyes, haar_scale, haar_minNeighbors, haar_flags, haar_minSize );
			
			printf("Face detector: %lu eyes detected\n", eyes.size());
			
			// draw eyes
			[self context:contextRef drawEyes:eyes inFace:faces[i] scale:scale];
		}
	}
	
	return [self convertContext2Image:contextRef];	
//	return [UIImageCVMatConverter UIImageFromCVMat:[UIImageCVMatConverter cvMatFromUIImage:image] withUIImage:targetImage];
}


- (UIImage*)convertContext2Image:(CGContextRef)contextRef;
{
	// make image out of bitmap context
    CGImageRef cgImage = CGBitmapContextCreateImage(contextRef);
    UIImage* image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(contextRef);
	
	return image;
}

- (CGContextRef)createContextForImage:(UIImage*)image;
{
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    CGFloat widthStep = image.size.width;
    
    CGContextRef contextRef = CGBitmapContextCreate(NULL,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    widthStep*4,              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
	CGColorSpaceRelease(colorSpace);
	
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    return contextRef;
}


- (void)context:(CGContextRef)contextRef drawFaces:(std::vector<cv::Rect>&)faces scale:(CGFloat)scale;
{
	CGContextSetLineWidth(contextRef,2);//set the line width
	CGContextSetRGBStrokeColor(contextRef, 20.0 /255, 101.0 / 255.0, 211.0 / 255.0, 1.0);
    
    // for each face found, draw a box
    for( int i = 0; i < faces.size(); i++ ) {		
		//ellipse( cvImageGray, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
		CGRect rect = CGContextConvertRectToDeviceSpace(contextRef, CGRectMake(faces[i].x*scale, faces[i].y*scale, faces[i].width*scale, faces[i].height*scale));
		CGContextAddEllipseInRect(contextRef, rect);
		CGContextStrokePath(contextRef);
	}
}


- (void)context:(CGContextRef)contextRef drawEyes:(std::vector<cv::Rect>&)eyes inFace:(cv::Rect&)faceRect scale:(CGFloat)scale;
{
	CGContextSetLineWidth(contextRef,2);//set the line width
	CGContextSetRGBStrokeColor(contextRef, 20.0 /255, 101.0 / 255.0, 18.0 / 255.0, 1.0);
	
	// note, the natural limit of two eyes
	for( int j = 0; j < eyes.size() && j < 2; j++ ) {
		cv::Point center( faceRect.x*scale + eyes[j].x*scale + eyes[j].width*scale*0.5, faceRect.y*scale + eyes[j].y*scale + eyes[j].height*scale*0.5 );
		int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25*scale );
		
		//circle( cvImage, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
		CGRect rect = CGContextConvertRectToDeviceSpace(contextRef, CGRectMake(center.x - radius, center.y-radius, radius*2, radius*2));
		CGContextAddEllipseInRect(contextRef, rect);
		CGContextStrokePath(contextRef);
	}
}


@end
