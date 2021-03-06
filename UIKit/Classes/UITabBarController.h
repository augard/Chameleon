/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIViewController.h>
#import <UIKit/UITabBar.h>

@protocol UITabBarControllerDelegate <NSObject>

- (void) tabBarController:(UITabBarController*)tabBarController didEndCustomizingViewControllers:(NSArray*)viewControllers changed:(BOOL)changed;
- (void) tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController;
- (BOOL) tabBarController:(UITabBarController*)tabBarController shouldSelectViewController:(UIViewController*)viewController;
- (void) tabBarController:(UITabBarController*)tabBarController willBeginCustomizingViewControllers:(NSArray*)viewControllers;
- (void) tabBarController:(UITabBarController*)tabBarController willEndCustomizingViewControllers:(NSArray*)viewControllers changed:(BOOL)changed;

@end


@interface UITabBarController : UIViewController <NSCoding, UITabBarDelegate>

#pragma mark Accessing the Tab Bar Controller Properties

@property (nonatomic, assign) id<UITabBarControllerDelegate> delegate;
@property (nonatomic, readonly) UITabBar* tabBar;


#pragma mark Managing the View Controllers

@property (nonatomic, copy) NSArray* viewControllers;
- (void) setViewControllers:(NSArray*)viewController animated:(BOOL)animated;
@property (nonatomic, copy) NSArray* customizableViewControllers;
@property(nonatomic, readonly) UINavigationController* moreNavigationController;


#pragma mark Managing the Selected Tab

@property (nonatomic, assign) UIViewController* selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end
