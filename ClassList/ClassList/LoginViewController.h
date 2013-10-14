//
//  LoginViewController.h
//  ClassList
//
//  Created by Stefan Dimitrov on 10/11/13.
//  Copyright (c) 2013 Stefan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;



@end
