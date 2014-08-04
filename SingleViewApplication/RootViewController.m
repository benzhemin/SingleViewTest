//
//  RootViewController.m
//  SingleViewApplication
//
//  Created by Bob on 7/14/14.
//  Copyright (c) 2014 chinapnr. All rights reserved.
//

#import "RootViewController.h"
#import <CoreText/CoreText.h>

@interface RootViewController ()

@end

@interface CusLayer : CALayer
@end

@implementation CusLayer

-(id<CAAction>)actionForKey:(NSString *)event{
    if ([event isEqualToString:@"position"]) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:15.0f];
        return animation;
    }
    return nil;
}

@end


@interface TestView : UIView
@end

@implementation TestView

-(UIImage *)createPureColorImage:(UIColor *)color size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    /*
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGAffineTransform trans = CGContextGetCTM(ctx);
    CGAffineTransform text_trans = CGContextGetTextMatrix(ctx);
    
    CGPoint point = CGContextGetTextPosition(ctx);
    
    NSLog(@"%@", NSStringFromCGAffineTransform(trans));
    NSLog(@"%@", NSStringFromCGAffineTransform(text_trans));
    
    CGContextSaveGState(ctx);
    {
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        
        CGAffineTransform text_trans = CGContextGetTextMatrix(ctx);
        NSLog(@"%@", NSStringFromCGAffineTransform(text_trans));
        
        CGContextTranslateCTM(ctx, 0.0f, rect.size.height);
        CGContextScaleCTM(ctx, 1.0f, -1.0f);
        
        CGAffineTransform text_trans2 = CGContextGetTextMatrix(ctx);
        NSLog(@"%@", NSStringFromCGAffineTransform(text_trans2));
    }
     */
    
    UIImage *redImage = [self createPureColorImage:[UIColor purpleColor] size:CGSizeMake(100, 100)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect frame = CGRectMake(0, 0, 100, 100);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:frame];
    CGContextAddPath(ctx, [path CGPath]);
    
    CGContextClip(ctx);
    
    CGContextDrawImage(ctx, frame, redImage.CGImage);
    
    /*
    [redImage drawInRect:CGRectMake((self.bounds.size.width-redImage.size.width)/2,
                                    (self.bounds.size.height-redImage.size.height)/2,
                                    redImage.size.width,
                                    redImage.size.height)];
    */
    
    /*
    NSAttributedString *attriString = [[[NSMutableAttributedString alloc] initWithString:@"this is test!"] autorelease];

    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, rect.size.height), 1.f, -1.f));
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attriString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    CFRelease(framesetter);
    
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
    */
    
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.testView = [[[TestView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)] autorelease];
    self.testView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_testView];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    [_testView addGestureRecognizer:panRecognizer];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if ((recognizer.state == UIGestureRecognizerStateChanged) || (recognizer.state == UIGestureRecognizerStateEnded)) {
        //得到当前的偏移量，距上次移动
        CGPoint translation = [recognizer translationInView:self.testView];
        CGAffineTransform translationTransform = CGAffineTransformTranslate(self.testView.transform, translation.x, translation.y);
        [self.testView setTransform:translationTransform];
        //重置偏移量，如果不重置，参考值总是testView未移动的值
        [recognizer setTranslation:CGPointZero inView:self.testView]; // clean translation.
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    CusLayer *layer = [CusLayer layer];
    layer.bounds = CGRectMake(0, 0, 120, 120);
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.position = CGPointMake(150, 200);
    
    [self.view.layer addSublayer:layer];
    layer.hidden = NO;
    
    CusLayer *bluelayer = [CusLayer layer];
    bluelayer.bounds = CGRectMake(0, 0, 100, 100);
    bluelayer.backgroundColor = [UIColor blueColor].CGColor;
    bluelayer.position = CGPointMake(150, 200);
    [self.view.layer addSublayer:bluelayer];
    bluelayer.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CATransition *transition = [CATransition animation];
        transition.beginTime = CACurrentMediaTime()+1.0;
        transition.duration = 2.0;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        transition.repeatCount = HUGE_VALF;
        
        [bluelayer addAnimation:transition forKey:nil];
        [layer addAnimation:transition forKey:nil];
        
        [CATransaction begin];
        bluelayer.hidden = NO;
        layer.opacity = 0.2;
        [CATransaction commit];
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end




















