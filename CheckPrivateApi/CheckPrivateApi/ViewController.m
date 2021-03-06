//
//  ViewController.m
//  CheckPrivateApi
//
//  Created by mac on 15/12/2.
//  Copyright © 2015年 kaicheng. All rights reserved.
//

#import "ViewController.h"
#include <dlfcn.h>
#import <objc/runtime.h>
#import <AdSupport/AdSupport.h>

#define USER_NAME       @"user name"
#define IP_ADDRESS      @"ip address"
#define USER_TOKEN      @"user token"

@interface APIInfromation : NSObject
@property(nonatomic,strong) NSString * ID;
@property(nonatomic,strong) NSString * classPath;
@property(nonatomic,strong) NSString * className;
@property(nonatomic,strong) NSString * classInitMethod;
@property(nonatomic,strong) NSArray *  callMethods;

-(instancetype) initWithJsonObject:(NSDictionary *) json;
@end


@implementation APIInfromation

-(instancetype) initWithJsonObject:(NSDictionary *) json
{
    self = [super init];
    if(self)
    {
        self.ID = [NSString stringWithFormat:@"%@", json[@"id"]];
        self.classPath = json[@"class_path"];
        self.className = json[@"class_name"];
        self.classInitMethod = json[@"init_method"];
        self.callMethods = [self parseCallMethods:json[@"call_methods"]];
        
    }
    
    return self;
}

-(NSArray *) parseCallMethods:(NSString *) methodsString
{
    NSArray * tmpMethods = [methodsString componentsSeparatedByString:@";"];
    NSMutableArray * finalMethods = [[NSMutableArray alloc] init];
    for(NSString * method in tmpMethods) {
        NSString * finalMethod = [NSString stringWithFormat:@"%@;",method];
        [finalMethods addObject:finalMethod];
    }
    
    return finalMethods;
}

@end


@interface NSObject(SafePerformSelector)
-(id) performSelectorSafely:(SEL)aSelector;
@end

@implementation NSObject(SafePerformSelector)
-(id) performSelectorSafely:(SEL)aSelector;
{
    NSParameterAssert(aSelector != NULL);
    NSParameterAssert([self respondsToSelector:aSelector]);
    
    NSMethodSignature* methodSig = [self methodSignatureForSelector:aSelector];
    if(methodSig == nil)
        return nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    const char* retType = [methodSig methodReturnType];
    if(strcmp(retType, @encode(id)) == 0 || strcmp(retType, @encode(void)) == 0){
        return [self performSelector:aSelector];
    }
    else if(strcmp(retType, "i") == 0 || strcmp(retType, "I") == 0 || strcmp(retType, "s") == 0 || strcmp(retType, "S") == 0 || strcmp(retType, "c") == 0)
    {
       return [NSString stringWithFormat:@"%@",[self performSelector:aSelector]];
    }
    else if(strcmp(retType, "f") == 0 || strcmp(retType, "d") == 0)
    {
       return [NSString stringWithFormat:@"%@",[self performSelector:aSelector]];
    }
    else if(strcmp(retType, "L") == 0  || strcmp(retType, "l") == 0 || strcmp(retType, "Q") == 0 ||  strcmp(retType, "q") == 0)
    {
       return [NSString stringWithFormat:@"%@",[self performSelector:aSelector]];
    }
    else
    {
        NSString * message = [NSString stringWithFormat:@"-[%@ performSelector:@selector(%@)] shouldn't be used. The selector doesn't return an object or void", [self class], NSStringFromSelector(aSelector)];
        NSLog(@"%@",message);
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        
        return nil;
    }
#pragma clang diagnostic pop
}
@end


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *tfIPAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfName;

@property (nonatomic, strong) APIInfromation *  apiInformation;
@property (nonatomic, strong) NSMutableDictionary * callResults;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tfName.text = [[NSUserDefaults standardUserDefaults] objectForKey: USER_NAME];
    self.tfIPAddress.text = [[NSUserDefaults standardUserDefaults] objectForKey: IP_ADDRESS];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)checkApi:(id)sender {
    [self.tfIPAddress resignFirstResponder];
    [self.tfName resignFirstResponder];
    
    [self fetchApiInformation];
    
    if(self.tfIPAddress.text.length > 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.tfIPAddress.text forKey:IP_ADDRESS];
    }
    
    if(self.tfName.text.length > 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.tfName.text forKey:USER_NAME];
    }
    
}

-(void) uploadResult
{
    NSString * getInfoUrlString = [NSString stringWithFormat:@"http://%@:3000/api_result/%@",self.tfIPAddress.text,self.apiInformation.ID];
    NSURL * requestUrl = [NSURL URLWithString:getInfoUrlString];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"PATCH";
    
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *contentDic = [[NSMutableDictionary alloc] init];
    for( NSString * method in self.apiInformation.callMethods)
    {
        id result = [self.callResults objectForKey:method];
        if(result)
        {
            [contentDic setObject:result forKey:method];
        }
    }
    
    NSString * deviceName = [UIDevice currentDevice].name;
    NSString * deviceModel = [UIDevice currentDevice].model;
    NSString * deviceOSVersion = [UIDevice currentDevice].systemVersion;
    NSString * deviceADFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    [paramsDic setObject:contentDic forKey:@"result"];
    [paramsDic setObject:deviceName forKey:@"device_name"];
    [paramsDic setObject:deviceModel forKey:@"device_model"];
    [paramsDic setObject:deviceOSVersion forKey:@"device_os_version"];
    [paramsDic setObject:deviceADFA forKey:@"device_adfa"];
    
    NSError * error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:paramsDic options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }];
    
    [postDataTask resume];
}

-(void) fetchApiInformation
{
    NSString * getInfoUrlString = [NSString stringWithFormat:@"http://%@:3000/api_info?name=%@",self.tfIPAddress.text,self.tfName.text];
    NSURL * requestUrl = [NSURL URLWithString:getInfoUrlString];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
       dispatch_async(dispatch_get_main_queue(), ^(void) {
            if(!error)
            {
                NSError * jsonError = nil;
                NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                self.apiInformation = [[APIInfromation alloc] initWithJsonObject:jsonDic];
                
                
                if(jsonError)
                {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"解析json数据失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
                else
                {
                    [self callApi];
                }
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取API数据失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
       });
    }] resume];
    
}

-(void) callApi
{
    void *lib = dlopen([self.apiInformation.classPath UTF8String], RTLD_LAZY);
    if (lib)
    {
        Class targetClass = NSClassFromString(self.apiInformation.className);
        SEL initSelector = NSSelectorFromString(self.apiInformation.classInitMethod);
        if([targetClass  respondsToSelector:initSelector] || self.apiInformation.classInitMethod.length == 0)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id bs = nil;
            
            if(self.apiInformation.classInitMethod.length != 0)
            {
                if([self.apiInformation.classInitMethod hasPrefix:@"init"])
                {
                    @try {
                        bs = [[targetClass alloc] performSelector:initSelector];
                    }
                    @catch (NSException *exception) {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"初始化方法错误" message:exception.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alert show];
                        
                    }
                   
                }
                else
                {
                    bs  = [targetClass performSelector:initSelector];
                }
            }
            else
            {
                bs = targetClass;
            }
            
            if(bs)
            {
                @try {
                    
                    self.callResults  = [NSMutableDictionary dictionary];
                    for (NSString * method in self.apiInformation.callMethods) {
                        
                        id result = [self callMethod:method target:bs];
                        result = [NSString stringWithFormat:@"%@",result];
                        [self.callResults setObject:result forKey:method];
                        
                    }
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
                        [self uploadResult];
                    });

                    [self.tableView reloadData];
                    
                }
                @catch (NSException *exception) {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:exception.description delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
              
                
            }
            else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"初始化方法取得实例为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
#pragma clang diagnostic pop
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该类不支持此初始化方法" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法打开该类库" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

-(id) callMethod:(NSString *) method target:(id) target
{
    NSError * error = nil;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@":(\\((.*?)\\)(.+?))[\\s|;]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:method
                                      options:0
                                        range:NSMakeRange(0, [method length])];
    
    NSMutableArray * params = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange paramTypeRange = [match rangeAtIndex:2];
        NSRange paramValueRange = [match rangeAtIndex:3];
        
        NSString * paramType = [method substringWithRange:paramTypeRange];
        NSString * paramValue = [method substringWithRange:paramValueRange];
       
        
        NSDictionary * paramInformation = @{@"type":paramType, @"value": paramValue };
        [params addObject: paramInformation];
    }
    
    NSString * methodSelectorString = [regex stringByReplacingMatchesInString:method options:0 range:NSMakeRange(0, method.length) withTemplate:@":"];
    methodSelectorString = [methodSelectorString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    SEL methodSelector = NSSelectorFromString(methodSelectorString);
    
    id result = [self invokeMethod:methodSelector target:target params:params];
    return  result;
    
}

-(id) invokeMethod:(SEL) selector  target:(id) target params:(NSArray*) params
{
    if([target respondsToSelector:selector] ||[[target class] respondsToSelector:selector] )
    {
        BOOL isClassMethod = NO;
        NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
        if(!methodSignature)
        {
            methodSignature = [[target class] methodSignatureForSelector:selector];
            if(methodSignature)
            {
                isClassMethod = YES;
            }
        }
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        if(isClassMethod)
        {
            [invocation setTarget:[target class]];
        }
        else
        {
            [invocation setTarget:target];
        }
        [invocation setSelector:selector];
       
        //设置参数
        NSInteger paramIndex = 0;
        for (NSDictionary * paramDic in params) {
           id arg = [self getValueWithParamInfo:paramDic];
           [invocation setArgument:&arg atIndex:2 + paramIndex];
           paramIndex ++;
        }
        
        Method method = nil;
        if(isClassMethod)
        {
            method = class_getClassMethod([target class] , selector);
        }
        else
        {
            method = class_getInstanceMethod([target class] , selector);
        }

        char returnType[ 256 ];
        method_getReturnType(method, returnType, 256 );
        
        void * result = nil;
        if(strcmp(returnType, "v") == 0)
        {
            return  nil;
        }
        else
        {
            [invocation invoke];
            [invocation getReturnValue:&result];
        }
        
        id  finalResult =  [self getObjectFromTypeEncoding:returnType data:result];
        return finalResult;
    }
    else
    {
       return @"不支持该方法";
    }
    
    return nil;
}

-(id) getObjectFromTypeEncoding:(char *) retType data:(void *) data
{
    if(data == NULL)
    {
        return  nil;
    }
    else if(strcmp(retType, @encode(id)) == 0 || strcmp(retType, @encode(void)) == 0 || strcmp(retType, "") == 0){
        return (__bridge id)(data);
    }
    else if(strcmp(retType, "i") == 0 || strcmp(retType, "I") == 0 || strcmp(retType, "s") == 0 || strcmp(retType, "S") == 0 || strcmp(retType, "c") == 0 || strcmp(retType, "C") == 0 || strcmp(retType, "B") == 0)
    {
        NSInteger result = (NSInteger) data;
        return [NSString stringWithFormat:@"%ld",(long)result];
    }
    else if(strcmp(retType, "f") == 0 || strcmp(retType, "d") == 0)
    {
        CGFloat* result = (CGFloat*) &data;
        return [NSString stringWithFormat:@"%f",*result];
    }
    else if(strcmp(retType, "L") == 0  || strcmp(retType, "l") == 0)
    {
        long  result = (long ) data;
        return [NSString stringWithFormat:@"%ld",result];
    }
    else if(strcmp(retType, "Q") == 0 ||  strcmp(retType, "q") == 0)
    {
        long long result = (long long) data;
        return [NSString stringWithFormat:@"%lld",result];
    }
    else
    {
        return nil;
    }
}

-(id) getValueWithParamInfo:(NSDictionary *) paramDic
{
    id arg = nil;
    NSString * type = paramDic[@"type"];
    NSString * value = paramDic[@"value"];
    
    if ([type isEqualToString: @"int"]) {
        arg = @([value intValue]);
    }
    else if([type isEqualToString:@"NSInteger"])
    {
        arg = @([value integerValue]);
    }
    else if([type isEqualToString:@"float"] || [type isEqualToString:@"CGFloat"])
    {
        arg = @([value floatValue]);
    }
    else if([type isEqualToString:@"double"])
    {
        arg = @([value doubleValue]);
    }
    else if([type isEqualToString:@"long long"])
    {
        arg = @([value longLongValue]);
    }
    else if([type containsString:@"NSArray"] || [type containsString:@"NSMutableArray"] || [type containsString:@"NSDictionary"] || [type containsString:@"NSMutableDictionary"] || [value hasPrefix:@"["] || [value hasPrefix:@"{"])
    {
        NSData * jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
        arg = jsonObject;
    }
    else if([type containsString:@"NSNumber"])
    {
        NSNumber * numberValue = @([value doubleValue]);
        arg = numberValue;
    }
    else if([type containsString:@"NSURL"])
    {
        NSURL * url = [NSURL URLWithString:value];
        arg = url;
    }
    else
    {
        arg = value;
    }
    
    return  arg;
}


#pragma  mark -  UITableViewDelegate and UITableViewDataSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.apiInformation.callMethods.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }

    NSString *  method = [self.apiInformation.callMethods objectAtIndex:indexPath.row];
    id   result = [self.callResults objectForKey:method];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"方法：%@",method];
    cell.detailTextLabel.textColor = [UIColor purpleColor];
    
    cell.textLabel.text = [NSString stringWithFormat:@"结果:%@",result];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return  cell;
}



-(UIView * ) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * header = [[UILabel alloc] init ];
    header.text = self.apiInformation.className;
    header.textAlignment = NSTextAlignmentCenter;
    header.textColor = [UIColor orangeColor];
    return header;
}


@end

