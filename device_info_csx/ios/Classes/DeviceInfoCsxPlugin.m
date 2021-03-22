#import "DeviceInfoCsxPlugin.h"
#import <sys/utsname.h>
#import <mach/mach.h>
#import <AvoidCrash/AvoidCrash.h>
#import <sys/sysctl.h>

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...){}
#endif

@implementation DeviceInfoCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [AvoidCrash becomeEffective];
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"device_info_csx"
            binaryMessenger:[registrar messenger]];
  DeviceInfoCsxPlugin* instance = [[DeviceInfoCsxPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getIosDeviceInfo" isEqualToString:call.method]) {
    UIDevice* device = [UIDevice currentDevice];
    struct utsname un;
    uname(&un);

    NSArray *diskStorage = [self getROMDetail];
    NSArray *romStorage = [self getRAMDetail];
    result(@{
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
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

// return value is false if code is run on a simulator
- (NSString*)isDevicePhysical {
  #if TARGET_OS_SIMULATOR
    NSString* isPhysicalDevice = @"false";
  #else
    NSString* isPhysicalDevice = @"true";
  #endif

  return isPhysicalDevice;
}

// ram 获得当前设备可用的内存,单位byte
- (double)getRamCanUseAll {
  vm_statistics_data_t vmStats;
  mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
  kern_return_t kernReturn = host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vmStats,&infoCount);
  if(kernReturn != KERN_SUCCESS) {
    return NSNotFound;
  }
  return (double)(vm_page_size * vmStats.free_count);
}

// 获取当前任务所占用的内存：单位byte
- (double)getUsedRam {
  task_basic_info_data_t taskInfo;
  mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
  kern_return_t kernReturn = task_info(mach_task_self(),TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
  if(kernReturn != KERN_SUCCESS) {
    return NSNotFound;
  }
  return (double)taskInfo.resident_size;
}

- (NSArray *)getRAMDetail {
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
  return @[@(mem_total==nil?0:mem_total), @(mem_used==nil?0:mem_used)];
}

- (NSArray *)getROMDetail{
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
