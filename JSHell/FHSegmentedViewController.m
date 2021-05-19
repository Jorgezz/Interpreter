//
//  KPSegmentedViewController.m
//  KPKuaiPai
//
//  Created by Johnny iDay on 13-12-14.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "FHSegmentedViewController.h"
#import <objc/runtime.h>
#import <SDWebImage/SDGraphicsImageRenderer.h>

@interface UIImageRenderInfo:NSObject{
@public
    struct {
        int image_with_size_color_corners_radius:1;
        int image_with_size_color_corners_cornerRadii:1;
        int image_with_size_color_radius_border:1;
        int image_with_color_radius_border_resize:1;
        int image_with_color_radius_border_hresize:1;
    } selContext;
}
@property(nonatomic,assign) CGSize size;
@property(nonatomic,strong) UIColor * color;

@property(nonatomic,assign) UIRectCorner corners;
@property(nonatomic,assign) CGSize cornerRadii;

@property(nonatomic,assign) CGFloat borderWidth;
@property(nonatomic,strong) UIColor * borderColor;

@property(nonatomic,assign) CGFloat innerBorderWidth;
@property(nonatomic,strong) UIColor * innerBorderColor;

@end

@implementation UIImageRenderInfo
@end

@interface UIImage (Color)
@property(nonatomic,strong) UIImageRenderInfo * renderInfo;
@end

@implementation UIImage (Color)

- (void)setRenderInfo:(UIImageRenderInfo *)renderInfo {
    objc_setAssociatedObject(self, @selector(renderInfo), renderInfo, OBJC_ASSOCIATION_RETAIN);
}

- (UIImageRenderInfo *)renderInfo {
    return (UIImageRenderInfo *) objc_getAssociatedObject(self, @selector(renderInfo));
}

+ (instancetype)imageWithSize:(CGSize)size color:(UIColor *)color cornerRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor innerBorderWidth:(CGFloat)innerBorderWidth innerBorderColor:(UIColor *)innerBorderColor
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGRect rect = {.origin = CGPointZero, .size = size};
    rect = CGRectInset(rect, borderWidth/2.0, borderWidth/2.0);
    
    UIBezierPath *path;
    if (radius > 0) {
        CGFloat realRadius = radius-borderWidth/2.0;
        if (realRadius < 0) {
            realRadius = 0;
        }
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:realRadius];
    }
    else {
        path = [UIBezierPath bezierPathWithRect:rect];
    }
    path.lineWidth = borderWidth;
    
    if (color) {
        [color setFill];
        [path fill];
    }
    
    if (borderColor) {
        [borderColor setStroke];
        [path stroke];
    }
    if (innerBorderWidth > 0) {
        rect = CGRectInset(rect, (borderWidth + innerBorderWidth)/2.0, (borderWidth + innerBorderWidth)/2.0);
        UIBezierPath *innerBorderPath;
        if (radius > 0) {
            CGFloat realInnerRadius = radius - borderWidth - innerBorderWidth/2.0;
            if (realInnerRadius < 0) {
                realInnerRadius = 0;
            }
            innerBorderPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:realInnerRadius];
        }
        else {
            innerBorderPath = [UIBezierPath bezierPathWithRect:rect];
        }
        innerBorderPath.lineWidth = innerBorderWidth;
        if (innerBorderColor) {
            [innerBorderColor setStroke];
            [innerBorderPath stroke];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (@available(iOS 13.0, *)) {
        if (!borderColor && !innerBorderColor) {
            color = [color colorWithAlphaComponent:1.0];
            image = [image imageWithTintColor:color];
        }else {
            image.renderInfo = ({
                UIImageRenderInfo *renderInfo = [UIImageRenderInfo new];
                renderInfo.size = size;
                renderInfo.color = color;
                renderInfo.cornerRadii = CGSizeMake(radius, radius) ;
                renderInfo.borderWidth = borderWidth;
                renderInfo.borderColor = borderColor;
                renderInfo.innerBorderColor = innerBorderColor;
                renderInfo.innerBorderWidth = innerBorderWidth;
                renderInfo->selContext.image_with_size_color_radius_border = 1;
                renderInfo;
            });
        }
    }
    
    return image;
}


@end

@interface FHSegmentedViewController ()

@end

@implementation FHSegmentedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] init];
        _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.navigationItem.titleView = _segmentedControl;
    } else {
        [_segmentedControl removeAllSegments];
    }
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:12], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    [_segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [_segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    [_segmentedControl setBackgroundImage:[UIImage imageWithSize:CGSizeMake(50, 30) color:UIColor.whiteColor cornerRadius:5 borderWidth:0 borderColor:nil innerBorderWidth:0 innerBorderColor:nil]
                              forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:[UIImage imageWithSize:CGSizeMake(50, 30) color:[UIColor.lightGrayColor colorWithAlphaComponent:0.4] cornerRadius:5 borderWidth:0 borderColor:nil innerBorderWidth:0 innerBorderColor:nil]
                                         forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles
{
    if ([_segmentedControl numberOfSegments] > 0) {
        return;
    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] title:titles[i]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers imagesNamed:(NSArray *)imageNames {
	if ([_segmentedControl numberOfSegments] > 0) {
		return;
	}
	for (int i = 0; i < [viewControllers count]; i++) {
		[self pushViewController:viewControllers[i] imageNamed:imageNames[i]];
	}
	[_segmentedControl setSelectedSegmentIndex:0];
	self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers images:(NSArray *)images {
	if ([_segmentedControl numberOfSegments] > 0) {
		return;
	}
	for (int i = 0; i < [viewControllers count]; i++) {
		[self pushViewController:viewControllers[i] image:images[i]];
	}
	[_segmentedControl setSelectedSegmentIndex:0];
	self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if ([_segmentedControl numberOfSegments] > 0) {
        return;
    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] title:[viewControllers[i] title]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)pushViewController:(UIViewController *)viewController
{
    [self pushViewController:viewController title:viewController.title];
}
- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title
{
    [_segmentedControl insertSegmentWithTitle:title atIndex:_segmentedControl.numberOfSegments animated:NO];
    [self addChildViewController:viewController];
    [_segmentedControl sizeToFit];
}

- (void)pushViewController:(UIViewController *)viewController imageNamed:(NSString *)imageName
{
	[_segmentedControl insertSegmentWithImage:[UIImage imageNamed:imageName] atIndex:_segmentedControl.numberOfSegments animated:NO];
	[self addChildViewController:viewController];
	[_segmentedControl sizeToFit];
}

- (void)pushViewController:(UIViewController *)viewController image:(UIImage *)image {
	[_segmentedControl insertSegmentWithImage:image atIndex:_segmentedControl.numberOfSegments animated:NO];
	[self addChildViewController:viewController];
	[_segmentedControl sizeToFit];
}

- (void)segmentedControlSelected:(id)sender
{
    self.selectedViewControllerIndex = _segmentedControl.selectedSegmentIndex;
}

- (void)setSelectedViewControllerIndex:(NSInteger)index
{
    if (!_selectedViewController) {
        _selectedViewController = self.childViewControllers[index];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
            CGFloat deltaTop = 20.0f;
            if (self.navigationController && !self.navigationController.navigationBar.translucent) {
                deltaTop = self.navigationController.navigationBar.frame.size.height;
            }
            CGRect frame = self.view.frame;
            [_selectedViewController view].frame = CGRectMake(frame.origin.x, frame.origin.y - deltaTop, frame.size.width, frame.size.height);
			//            [[_selectedViewController view] sizeToFit];
        } else {
            [_selectedViewController view].frame = self.view.frame;
        }
        [self.view addSubview:[_selectedViewController view]];
        [_selectedViewController didMoveToParentViewController:self];
    } else if (index != _selectedViewControllerIndex) {
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
            [self.childViewControllers[index] view].frame = self.view.frame;
        }
        [self transitionFromViewController:_selectedViewController toViewController:self.childViewControllers[index] duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
            _selectedViewController = self.childViewControllers[index];
            _selectedViewControllerIndex = index;
        }];
    }
}

@end
