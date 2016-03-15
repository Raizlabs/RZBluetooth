//
//  RZCentralManager.h
//  UMTSDK
//
//  Created by Brian King on 7/22/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZBDefines.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * RZCentralManager encapsulates all delegate interactions, exposing only the high
 * level Bluetooth actions. RZCentralManager will automatically connect, and
 * discover any needed services or characteristics. It will also wait for 
 * Core Bluetooth to become available, and even re-submit any commands if the 
 * CoreBluetooth process crashes.
 */
@interface RZBCentralManager : NSObject

/**
 * Create a new central manager on the main dispatch queue, with a default identifier.
 */
- (instancetype)init;

/**
 * Create a new central manager
 *
 * @param identifier the restore identifier.
 * @param queue the dispatch queue for the central to use. The main queue will be used if queue is nil.
 *              It is important that the dispatch queue be a serial queue
 *
 */
- (instancetype)initWithIdentifier:(NSString *)identifier queue:(dispatch_queue_t __nullable)queue;

/**
 * Expose the backing CBCentralManagerState. See RZBluetoothErrorForState to generate an
 * error object representing the non-functioning terminal states.
 */
@property (assign, nonatomic, readonly) CBCentralManagerState state;

/**
 * This block will be triggered whenever the central manager state changes.
 */
@property (nonatomic, copy) RZBStateBlock centralStateHandler;

/**
 * This block will be triggered when restored with an array of CBPeripheral objects
 */
@property (nonatomic, copy) RZBRestorationBlock restorationHandler;

/**
 * Helper to get a peripheral from a peripheralUUID
 */
- (CBPeripheral *)peripheralForUUID:(NSUUID *)peripheralUUID;

/**
 * Scan for peripherals with the specified UUIDs and options. Trigger the scanBlock
 * for every discovered peripheral. Multiple calls to this method will replace the previous
 * calls. 
 *
 * The onError: block will be triggered if there are any CBCentralManagerState errors and
 * for user interaction timeout errors if configured.
 */
- (void)scanForPeripheralsWithServices:(NSArray * __nullable)serviceUUIDs
                               options:(NSDictionary * __nullable)options
                onDiscoveredPeripheral:(RZBScanBlock)scanBlock
                               onError:(RZBErrorBlock __nullable)onError;

/**
 * Stop the peripheral scan.
 */
- (void)stopScan;

/**
 * This will make the central manager maintain a connection to the peripheral at 
 * all times, reconnecting to the peripheral when the connection fails. This is
 * one of the most common patterns for connecting to a device with
 * battery limitations. 
 *
 * This behavior will be disabled if cancelConnectionFromPeripheralUUID:completion: is called.
 *
 * @param peripheralUUID The UUID of the peripheral to connect to
 */
- (void)maintainConnectionToPeripheralUUID:(NSUUID *)peripheralUUID;

/**
 * Specify a block to invoke when the peripheral with peripheralUUID is connected.
 *
 * This block will be cleared if cancelConnectionFromPeripheralUUID:completion: is called.
 *
 * @param peripheralUUID The UUID of the peripheral
 * @param onConnection The block to invoke on connection
 */
- (void)setConnectionHandlerForPeripheralUUID:(NSUUID *)peripheralUUID
                                      handler:(RZBPeripheralBlock __nullable)onConnection;

/**
 * Specify a block to invoke when the peripheral with peripheralUUID is disconnected
 *
 * This block will be cleared if cancelConnectionFromPeripheralUUID:completion: is called.
 *
 * @param peripheralUUID The UUID of the peripheral
 * @param onDisconnection The block to invoke on connection
 */
- (void)setDisconnectionHandlerForPeripheralUUID:(NSUUID *)peripheralUUID
                                         handler:(RZBPeripheralBlock __nullable)onDisconnection;



/**
 * Cancel the connection to a peripheral. This will cancel the connection
 * if connected. If the peripheral is not connected, it trigger the completion
 * block immediately. If the peripheral has a maintained connection, the 
 * reconnect behavior will also be cancelled.
 *
 * @param peripheralUUID The UUID of the peripheral to connect to
 */
- (void)cancelConnectionFromPeripheralUUID:(NSUUID *)peripheralUUID
                                completion:(RZBPeripheralBlock __nullable)completion;

/**
 * Initiate a connection to a peripheral. This is exposed in case
 * someone wants to use it directly, but all of the above commands
 * will initiate a connection if needed, so this method is not needed.
 */
- (void)connectToPeripheralUUID:(NSUUID *)peripheralUUID
                     completion:(RZBPeripheralBlock __nullable)completion;

@end

NS_ASSUME_NONNULL_END
