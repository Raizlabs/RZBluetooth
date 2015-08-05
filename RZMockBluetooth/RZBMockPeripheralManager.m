//
//  RZBSimulatedDevice.m
//  UMTSDK
//
//  Created by Brian King on 7/30/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZBMockPeripheralManager.h"
#import "RZBSimulatedCallback.h"

@implementation RZBMockPeripheralManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _services = [NSMutableArray array];
    }
    return self;
}

- (void)startAdvertising:(NSDictionary *)advertisementData
{
    _isAdvertising = YES;
    [self.mockDelegate mockPeripheralManager:self startAdvertising:advertisementData];
}

- (void)stopAdvertising
{
    _isAdvertising = NO;
    [self.mockDelegate mockPeripheralManagerStopAdvertising:self];
}

- (void)setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatency)latency forCentral:(CBCentral *)central
{
    [self.mockDelegate mockPeripheralManager:self setDesiredConnectionLatency:latency forCentral:central];
}

- (void)addService:(CBMutableService *)service
{
    [self.services addObject:service];
    [self.mockDelegate mockPeripheralManager:self addService:service];
}

- (void)removeService:(CBMutableService *)service
{
    [self.services removeObject:service];
    [self.mockDelegate mockPeripheralManager:self removeService:service];
}

- (void)removeAllServices
{
    [self.services removeAllObjects];
    [self.mockDelegate mockPeripheralManagerRemoveAllServices:self];
}

- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result
{
    [self.mockDelegate mockPeripheralManager:self respondToRequest:request withResult:result];
}

- (BOOL)updateValue:(NSData *)value forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:(NSArray *)centrals
{
    return [self.mockDelegate mockPeripheralManager:self updateValue:value forCharacteristic:characteristic onSubscribedCentrals:centrals];
}

- (void)fakeReadRequest:(CBATTRequest *)request
{
    [self.delegate peripheralManager:(id)self didReceiveReadRequest:request];
}

- (void)fakeWriteRequest:(CBATTRequest *)request
{
    [self.delegate peripheralManager:(id)self didReceiveWriteRequests:@[request]];
}

- (void)fakeNotifyState:(BOOL)enabled central:(CBCentral *)central characteristic:(CBMutableCharacteristic *)characteristic
{
    if (enabled) {
        [self.delegate peripheralManager:(id)self central:central didSubscribeToCharacteristic:(id)characteristic];
    }
    else {
        [self.delegate peripheralManager:(id)self central:central didUnsubscribeFromCharacteristic:(id)characteristic];
    }
}

@end
