//
//  ViewController.m
//  IMDemo
//
//  Created by 孙震 on 2022/8/17.
//

#import "ViewController.h"
#import <QNIMSDK/QNIMSDK.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UITextField *conversationId;
@property (weak, nonatomic) IBOutlet UISwitch *groupSwitch;
//@property (assign,nonatomic)  long long groupId;

@end

@implementation ViewController

#pragma mark - life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userName.text = @"shawn";
    self.password.text = @"123";
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - action methods
/// 登录
- (IBAction)login:(id)sender {
    NSString *name = self.userName.text;
    NSString *pwd = self.password.text;
    [[QNIMClient sharedClient] signInByName:name password:pwd completion:^(QNIMError * _Nonnull error) {
        if(error.errorCode != 0) {
            [self addLog:[NSString stringWithFormat:@"登录失败:%@",error.errorMessage]];
        }else{
            [self addLog:@"登录成功"];
        }
    }];
}

/// 注册
- (IBAction)regist:(id)sender {
    NSString *name = self.userName.text;
    NSString *pwd = self.password.text;
    [[QNIMClient sharedClient] signUpNewUser:name password:pwd completion:^(QNIMUserProfile * _Nonnull profile, QNIMError * _Nonnull error) {
        if(error){
            [self addLog:[NSString stringWithFormat:@"注册失败 %@",error.errorMessage]];
        }else{
            [self addLog:[NSString stringWithFormat:@"注册成功 uid:%lld,username:%@",profile.userId,profile.userName]];
        }
    }];
}
/// 退出
- (IBAction)leave:(id)sender {
    [[QNIMUserService sharedOption] getProfileForceRefresh:YES completion:^(QNIMUserProfile * _Nonnull profile, QNIMError * _Nonnull aError) {
        [[QNIMClient sharedClient] signOutID:profile.userId ignoreUnbindDevice:YES completion:^(QNIMError * _Nonnull error) {
            if (error) {
                [self addLog:[NSString stringWithFormat:@"退出失败%@",error.errorMessage]];
            }else{
                [self addLog:@"退出成功"];
            }
        }];
    }];
}

 

- (IBAction)createGroup:(id)sender {
//    QNIMCreatGroupOption *group =  [[QNIMCreatGroupOption alloc] initWithGroupName:@"test" groupDescription:@"test group description" isPublic:YES];
    
    QNIMCreatGroupOption *groupOption  =  [[QNIMCreatGroupOption alloc] init];
    groupOption.name = @"test";
    groupOption.isChatroom = YES;
    groupOption.groupDescription = @"test group desc";
    [[QNIMGroupService sharedOption] creatGroupWithCreateGroupOption:groupOption completion:^(QNIMGroup * _Nonnull group, QNIMError * _Nonnull error) {
        if(error){
            [self addLog:[NSString stringWithFormat:@"creatGroupWithCreateGroupOption error %@",error.errorMessage]];
        }else{
            self.conversationId.text = [NSString stringWithFormat:@"%lld",group.groupId];
            [self addLog:[NSString stringWithFormat:@"成功创建群 id:%lld",group.groupId]];
        }
    }];
}

- (IBAction)joinGroup:(id)sender {
    [[QNIMGroupService sharedOption] joinGroupWithGroupId:self.conversationId.text message:@"test" completion:^(QNIMError * _Nonnull error) {
        if(error){
            [self addLog:[NSString stringWithFormat:@"加入群聊失败  %@",error.errorMessage]];
        }else{
            [self addLog:[NSString stringWithFormat:@"成功加入群聊 %@",self.conversationId.text]];

        }
    }];
}

#pragma mark private methods
 
- (void)addLog:(NSString *)log {
    NSLog(@"%@",log);
    self.logView.text = [NSString stringWithFormat:@"%@ \n %@",self.logView.text,log];
}
@end
