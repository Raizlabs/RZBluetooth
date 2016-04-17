//
//  RZBTestPeripheral.m
//  UMTSDK
//
//  Created by Brian King on 7/23/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZBMockCentralManager.h"
#import "RZBMockPeripheral.h"

@import ObjectiveC.runtime;

@implementation RZBMockPeripheral

@synthesize mockDelegate = _mockDelegate;
@synthesize state = _state;

+ (BOOL)resolveInstanceMethod:(SEL)aSelector
{
    BOOL resolved = [super resolveInstanceMethod:aSelector];
    if (resolved == NO) {
        Method method = class_getInstanceMethod([CBPeripheral class], aSelector);
        if (method) {
            const char *types = method_getTypeEncoding(method);
            IMP impl = method_getImplementation(method);
            class_addMethod(self, aSelector, impl, types);
            resolved = YES;
        }
    }
    return resolved;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return [RZBMockPeripheral isKindOfClass:aClass] || [CBPeripheral isSubclassOfClass:aClass];
}

- (void)readRSSI
{
    [self.mockDelegate mockPeripheralReadRSSI:(id)self];
}

- (void)discoverServices:(NSArray *)serviceUUIDs
{
    [self.mockDelegate mockPeripheral:(id)self discoverServices:serviceUUIDs];
}

- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service
{
    [self.mockDelegate mockPeripheral:(id)self discoverCharacteristics:characteristicUUIDs forService:service];
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic
{
    [self.mockDelegate mockPeripheral:(id)self readValueForCharacteristic:characteristic];
}

- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type
{
    [self.mockDelegate mockPeripheral:(id)self writeValue:data forCharacteristic:characteristic type:type];
}

- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic
{
    [self.mockDelegate mockPeripheral:(id)self setNotifyValue:enabled forCharacteristic:characteristic];
}

- (CBMutableService *)newServiceForUUID:(CBUUID *)serviceUUID
{
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    return service;
}

- (CBMutableCharacteristic *)newCharacteristicForUUID:(CBUUID *)serviceUUID
{
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:serviceUUID
                                                                                 properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify
                                                                                      value:nil
                                                                                permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    return characteristic;
}

- (CBMutableService *)serviceForUUID:(CBUUID *)serviceUUID
{
    for (CBMutableService *service in self.services) {
        if ([service.UUID isEqual:serviceUUID]) {
            return service;
        }
    }
    return nil;
}

- (void)fakeRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    dispatch_async(self.mockCentralManager.queue, ^{
        [self.delegate peripheral:(id)self didReadRSSI:RSSI error:error];
    });
}

- (void)fakeDiscoverService:(NSArray *)services error:(NSError *)error
{
    NSMutableSet *existing = self.services ? [NSMutableSet setWithArray:self.services] : [NSMutableSet set];
    if (services) {
        [existing addObjectsFromArray:services];
    }
    self.services = [existing allObjects];
    for (CBMutableService *service in self.services) {
        [service setValue:self forKey:@"peripheral"];
    }
    dispatch_async(self.mockCentralManager.queue, ^{
        [self.delegate peripheral:(id)self didDiscoverServices:error];
    });
}

- (void)fakeDiscoverServicesWithUUIDs:(NSArray *)serviceUUIDs error:(NSError *)error
{
    NSMutableArray *services = [NSMutableArray array];
    for (CBUUID *serviceUUID in serviceUUIDs) {
        [services addObject:[self newServiceForUUID:serviceUUID]];
    }
    [self fakeDiscoverService:services error:error];
}

- (void)fakeUpdateName:(NSString *)name;
{
    dispatch_async(self.mockCentralManager.queue, ^{
        self.name = name;
        [self.delegate peripheralDidUpdateName:(id)self];
    });
}

- (void)fakeDiscoverCharacteristicsWithUUIDs:(NSArray *)characteristicUUIDs forService:(CBMutableService *)service error:(NSError *)error
{
    NSMutableArray *characteristics = [NSMutableArray array];
    for (CBUUID *characteristicUUID in characteristicUUIDs) {
        [characteristics addObject:[self newCharacteristicForUUID:characteristicUUID]];
    }
    [self fakeDiscoverCharacteristics:characteristics forService:service error:error];
}

- (void)fakeDiscoverCharacteristics:(NSArray *)services forService:(CBMutableService *)service error:(NSError *)error
{
    NSMutableSet *existing = service.characteristics ? [NSMutableSet setWithArray:service.characteristics] : [NSMutableSet set];
    if (services) {
        [existing addObjectsFromArray:services];
    }
    service.characteristics = [existing allObjects];
    dispatch_async(self.mockCentralManager.queue, ^{
        [self.delegate peripheral:(id)self didDiscoverCharacteristicsForService:(id)service error:error];
    });
}

- (void)fakeCharacteristic:(CBMutableCharacteristic *)characteristic updateValue:(NSData *)value error:(NSError *)error
{
    dispatch_async(self.mockCentralManager.queue, ^{
        characteristic.value = value;
        [self.delegate peripheral:(id)self didUpdateValueForCharacteristic:(id)characteristic error:error];
    });
}

- (void)fakeCharacteristic:(CBMutableCharacteristic *)characteristic writeResponseWithError:(NSError *)error;
{
    dispatch_async(self.mockCentralManager.queue, ^{
        [self.delegate peripheral:(id)self didWriteValueForCharacteristic:(id)characteristic error:error];
    });
}

- (void)fakeCharacteristic:(CBMutableCharacteristic *)characteristic notify:(BOOL)notifyState error:(NSError *)error
{
    dispatch_async(self.mockCentralManager.queue, ^{
        if (error == nil) {
            [characteristic setValue:@(notifyState) forKey:@"isNotifying"];
        }
        [self.delegate peripheral:(id)self didUpdateNotificationStateForCharacteristic:(id)characteristic error:error];
    });
}

@end
