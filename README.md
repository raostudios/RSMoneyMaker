# RSMoneyMaker

[![CI Status](https://travis-ci.org/raostudios/RSMoneyMaker.svg?branch=master)](https://travis-ci.org/raostudios/RSMoneyMaker)
[![Version](https://img.shields.io/cocoapods/v/RSMoneyMaker.svg?style=flat)](http://cocoapods.org/pods/RSMoneyMaker)
[![License](https://img.shields.io/cocoapods/l/RSMoneyMaker.svg?style=flat)](http://cocoapods.org/pods/RSMoneyMaker)
[![Platform](https://img.shields.io/cocoapods/p/RSMoneyMaker.svg?style=flat)](http://cocoapods.org/pods/RSMoneyMaker)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RSMoneyMaker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RSMoneyMaker"
```

## Usage

### Initialize

``` [IAPManager initializeStoreWithProducts:@[weatherProduct] withSharedSecret:@"..."];

### Make Purchase

``` IAPManager *manager = [IAPManager sharedManager];
    [manager purchaseProduct:[IAPProducts productForIdentifier:self.productIdentifier].storeKitProduct withCompletion:^(NSError *error) {
      ...
    }];


## Author

Venkat S. Rao, vrao423@gmail.com

## License

RSStoreKit is available under the MIT license. See the LICENSE file for more info.
