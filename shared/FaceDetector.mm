//
//  FaceDetector.m
//  SquareCam 
//
//  Created by Eduard Feicho on 07.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "FaceDetector.h"
#import "UIImageCVMatConverter.h"



@implementation FaceDetector


- (id)init;
{
	self = [super init];
	if (self) {
#ifdef __cplusplus
		face_cascade = new cv::CascadeClassifier();
		eyes_cascade = new cv::CascadeClassifier();
#endif
	}
	return self;
}


- (void)loadCascade;
{
	NSString *face_cascade_filename = @"haarcascade_frontalface_alt";
	NSString *eyes_cascade_filename = @"haarcascade_eye_tree_eyeglasses";
	
	NSString *path_frontalface = [[NSBundle mainBundle] pathForResource:face_cascade_filename ofType:@"xml"];
	NSString *path_eyeglasses  = [[NSBundle mainBundle] pathForResource:eyes_cascade_filename ofType:@"xml"];
	
	if (path_frontalface != nil && !face_cascade->load([path_frontalface UTF8String])) {
		NSLog(@"Unable to load cascade file %@.xml", face_cascade_filename);
	} else {
		NSLog(@"Loaded cascade file %@.xml", face_cascade_filename);
	}
	if (path_eyeglasses != nil && !eyes_cascade->load([path_eyeglasses UTF8String])) {
		NSLog(@"Unable to load cascade file %@.xml", eyes_cascade_filename);
	} else {
		NSLog(@"Loaded cascade file %@.xml", eyes_cascade_filename);
	}
}



- (UIImage*)detectFace:(UIImage*)image;
{
	std::vector<cv::Rect> faces;
	
	cv::Mat cvImage = [UIImageCVMatConverter cvMatFromUIImage:image];
	cv::Mat cvImageGray = [UIImageCVMatConverter cvMatGrayFromUIImage:image];
	cv::Mat cvImageTmp = cvImageGray;
	/*
	face_cascade->detectMultiScale( cvImageGray, faces, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
	
	for( int i = 0; i < faces.size(); i++ ) {
		cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
		ellipse( cvImageGray, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, cv::Scalar( 255, 0, 255 ), 4, 8, 0 );
		
		cv::Mat faceROI = cvImageGray( faces[i] );
		std::vector<cv::Rect> eyes;
		
		//-- In each face, detect eyes
		eyes_cascade->detectMultiScale( faceROI, eyes, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );

		for( int j = 0; j < eyes.size(); j++ )
		{
			cv::Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5 );
			int radius = cvRound( (eyes[j].width + eyes[j].height)*0.25 );
			circle( cvImage, center, radius, cv::Scalar( 255, 0, 0 ), 4, 8, 0 );
		}
		
	}
	
	*/
	
	return [UIImageCVMatConverter UIImageFromCVMat:cvImage];
}

@end
