//
//  CommonTool.m
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/5.
//

#import "CommonTool.h"
#import <sys/utsname.h>
#import <mach/mach.h>
#import <sys/sysctl.h>

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...){}
#endif

@implementation CommonTool

//进入app的设置界面
+ (BOOL)openAppSetting{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            __block bool result;
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                result = success;
            }];
            return result;
        } else {
            return [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        return false;
    }
}

//获取iOS设备的信息
+ (NSDictionary *)getDeviceInfo {
    UIDevice* device = [UIDevice currentDevice];
        struct utsname un;
        uname(&un);

        NSArray *diskStorage = [self getROMDetail];
        NSArray *romStorage = [self getRAMDetail];
    return @{
          @"name" : [device name],
          @"systemName" : [device systemName],
          @"systemVersion" : [device systemVersion],
          @"model" : [device model],
          @"localizedModel" : [device localizedModel],
          @"identifierForVendor" : [[device identifierForVendor] UUIDString],
          @"isPhysicalDevice" : [self isDevicePhysical],
          @"utsname" : @{
            @"sysname" : @(un.sysname),
            @"nodename" : @(un.nodename),
            @"release" : @(un.release),
            @"version" : @(un.version),
            @"machine" : @(un.machine),
          },
          @"storage":@{
            @"ramUseB" : [romStorage lastObject],
            @"ramAllB" : [romStorage firstObject],
            @"romUseB" : [diskStorage lastObject],
            @"romAllB" : [diskStorage firstObject],
          },
        };
}

//获取所有userdefault存储的数据
+ (NSDictionary *)getUserDefaults {
    NSDictionary* tempDic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    return tempDic;
}

//本地存储
+ (void)setUserDefault:(NSDictionary *)dic {
    if (dic != nil) {
        for (NSString *keyStr in dic.allKeys) {
            id value = dic[keyStr];
            [[NSUserDefaults standardUserDefaults] setValue:value forKey:keyStr];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// return value is false if code is run on a simulator
+ (NSString*)isDevicePhysical {
  #if TARGET_OS_SIMULATOR
    NSString* isPhysicalDevice = @"false";
  #else
    NSString* isPhysicalDevice = @"true";
  #endif

  return isPhysicalDevice;
}

// ram 获得当前设备可用的内存,单位byte
+ (double)getRamCanUseAll {
  vm_statistics_data_t vmStats;
  mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
  kern_return_t kernReturn = host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vmStats,&infoCount);
  if(kernReturn != KERN_SUCCESS) {
    return NSNotFound;
  }
  return (double)(vm_page_size * vmStats.free_count);
}

// 获取当前任务所占用的内存：单位byte
+ (double)getUsedRam {
  task_basic_info_data_t taskInfo;
  mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
  kern_return_t kernReturn = task_info(mach_task_self(),TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
  if(kernReturn != KERN_SUCCESS) {
    return NSNotFound;
  }
  return (double)taskInfo.resident_size;
}

+ (NSArray *)getRAMDetail {
  mach_port_t host_port;
  mach_msg_type_number_t host_size;
  vm_size_t pagesize;
    
  host_port = mach_host_self();
  host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
  host_page_size(host_port, &pagesize);
    
  vm_statistics_data_t vm_stat;
  if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
    NSLog(@"Failed to fetch vm statistics");
  }
    
  /* Stats in bytes */
  natural_t mem_used = (vm_stat.active_count +
                        vm_stat.inactive_count +
                        vm_stat.wire_count) * pagesize;
  natural_t mem_free = vm_stat.free_count * pagesize;
  natural_t mem_total = mem_used + mem_free;
  NSLog(@"运行内存已用: %u 可用: %u 总共: %u", mem_used, mem_free, mem_total);
  return @[@(mem_total), @(mem_used)];
}

+ (NSArray *)getROMDetail{
  double totalSpace = 0.f;
  double totalFreeSpace=0.f;
  NSError *error = nil;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
  if (dictionary) {
    NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
    NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
    totalSpace = [fileSystemSizeInBytes floatValue];
    totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
    NSLog(@"Storage Memory Capacity of %f B with %f B Free memory available.", totalSpace, totalFreeSpace);
  } else {
    NSLog(@"Storage Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], [error code]);
  }
  return @[@(totalSpace), @(totalSpace-totalFreeSpace)];
}
@end
