//
//  RZBMockedCentralManager.h
//  RZBluetooth
//
//  Created by Brian King on 4/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import CoreBluetooth;

@protocol RZBMockCentralManagerDelegate, RZBMockedPeripheral;

NS_ASSUME_NONNULL_BEGIN

@protocol RZBMockedCentralManager <NSObject>

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options;
- (void)stopScan;
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *, id> *)options;
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;

- (id<RZBMockedPeripheral>)peripheralForUUID:(NSUUID *)uuid;

@property(weak, nonatomic) id<RZBMockCentralManagerDelegate> mockDelegate;
@property(strong, nonatomic) dispatch_queue_t queue;

- (void)fakeStateChange:(CBCentralManagerState)state;
- (void)fakeScanPeripheralWithUUID:(NSUUID *)peripheralUUID advInfo:(NSDictionary *)info RSSI:(NSNumber *)RSSI;

- (void)fakeConnectPeripheralWithUUID:(NSUUID *)peripheralUUID error:(NSError *__nullable)error;
- (void)fakeDisconnectPeripheralWithUUID:(NSUUID *)peripheralUUID error:(NSError *__nullable)error;

@end

@protocol RZBMockCentralManagerDelegate <NSObject>

- (void)mockCentralManager:(id<RZBMockedCentralManager>)mockCentralManager retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;
- (void)mockCentralManager:(id<RZBMockedCentralManager>)mockCentralManager scanForPeripheralsWithServices:(NSArray *)services options:(NSDictionary *)options;
- (void)mockCentralManagerStopScan:(id<RZBMockedCentralManager>)mockCentralManager;

- (void)mockCentralManager:(id<RZBMockedCentralManager>)mockCentralManager connectPeripheral:(id<RZBMockedPeripheral>)peripheral options:(NSDictionary *)options;
- (void)mockCentralManager:(id<RZBMockedCentralManager>)mockCentralManager cancelPeripheralConnection:(id<RZBMockedPeripheral>)peripheral;

@end

NS_ASSUME_NONNULL_END
