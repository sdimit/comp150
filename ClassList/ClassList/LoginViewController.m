//
//  LoginViewController.m
//  ClassList
//
//  Created by Stefan Dimitrov on 10/11/13.
//  Copyright (c) 2013 Stefan. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
	// Do any additional setup after loading the view.
    [self.loginField setReturnKeyType:UIReturnKeyNext];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.loginField becomeFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.loginField) {
        [self.passwordField becomeFirstResponder];
    } else if (theTextField == self.passwordField) {
        [theTextField resignFirstResponder];
        [self validate];
    }
    return YES;
}

- (void) login{
    
    [self performSegueWithIdentifier:@"showMain" sender:self];

}

- (void) validate{
    if (![self.loginField hasText]){
        [self.loginField becomeFirstResponder];
        [self shakeView];
    }
    
}

- (void)shakeView{
    
    void(^shakeEffectIn)(void) = ^{
        [self.loginField setTransform:CGAffineTransformMakeTranslation(5, 0)];
        [self.loginField setTransform:CGAffineTransformIdentity];
    };
    void(^shakeEffectOut)(void) = ^{
        [self.loginField setTransform:CGAffineTransformMakeTranslation(-5, 0)];
        [self.loginField setTransform:CGAffineTransformIdentity];
    };
    
    [UIView animateWithDuration:0.1 animations:shakeEffectIn completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:shakeEffectOut];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
