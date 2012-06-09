//
//  FaceDetector.h
//  SquareCam 
//
//  Created by Eduard Feicho on 07.06.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#endif



@interface FaceDetector : NSObject
{
#ifdef __cplusplus
	cv::CascadeClassifier* eyes_cascade;
	cv::CascadeClassifier* face_cascade;
#else
	void* eyes_cascade;
	void* face_cascade;
#endif
};

- (void)loadCascade;
- (UIImage*)detectFace:(UIImage*)image;


@end



/*
 //
 //  FaceDetector.h
 //  SquareCam 
 //
 //  Created by Eduard Feicho on 07.06.12.
 //  Copyright (c) 2012 Eduard Feicho. All rights reserved.
 //
 
 #import <UIKit/UIKit.h>
 
 #include <opencv2/objdetect/objdetect.hpp>
 #include <opencv2/imgproc/imgproc.hpp>
 
 struct MyCascadeClassifierWrapper {
 cv::CascadeClassifier cascadeClassifier;
 };
 
 
 
 @interface FaceDetector : NSObject
 {
 cv::CascadeClassifier* eyes_cascade;
 cv::CascadeClassifier* face_cascade;
 };
 
 - (void)loadCascade;
 - (UIImage*)detectFace:(UIImage*)image;
 
 
 @end
*/
