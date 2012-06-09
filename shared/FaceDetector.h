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

#include <list>
using namespace std;
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
	
	BOOL detectEyes;
};

@property (nonatomic, assign) BOOL detectEyes;


- (void)loadCascades;
- (UIImage*)detectFaces:(UIImage*)image;

- (UIImage*)convertContext2Image:(CGContextRef)contextRef;
- (CGContextRef)createContextForImage:(UIImage*)image;

#ifdef __cplusplus
- (void)context:(CGContextRef)contextRef drawFaces:(std::vector<cv::Rect>&)faces scale:(CGFloat)scale;
- (void)context:(CGContextRef)contextRef drawEyes:(std::vector<cv::Rect>&)eyes inFace:(cv::Rect&)faceRect scale:(CGFloat)scale;
#endif


@end
