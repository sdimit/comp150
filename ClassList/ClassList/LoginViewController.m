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
    
    [self.loginButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.loginField becomeFirstResponder];
	// Do any additional setup after loading the view.
    [self.loginField setReturnKeyType:UIReturnKeyNext];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
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

- (void) dismiss{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void) validate{
    if (![self.loginField hasText]){
        [self.loginField becomeFirstResponder];
    [UIView animateWithDuration:0.1 animations:^{
      //  [self.loginField setBackgroundColor:
        //    [UIColor colorWithRed:255/255.0f green:127/255.0f blue:127/255.0f alpha:1.0f]];
        self.loginField.transform = CGAffineTransformMakeTranslation(5, 0);
        self.loginField.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.1 animations:^{
              //          self.loginField.backgroundColor = [UIColor clearColor];
                        self.loginField.transform = CGAffineTransformMakeTranslation(-5, 0);
                        self.loginField.transform = CGAffineTransformIdentity;
                    }
                                     completion:nil];
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
