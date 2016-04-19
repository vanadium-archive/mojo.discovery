#!mojo mojo:dart_content_handler?strict=true
// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:mojo_apptest/apptest.dart';
import 'package:mojo/application.dart';

import 'package:v23discovery/discovery.dart';

const String mojoUrl = 'https://mojo.v.io/discovery.mojo';
const String interfaceName = 'v.io/myInterface';

main(List args, Object handleToken) {
  runAppTests(handleToken, [discoveryApptests]);
}

discoveryApptests(Application application, String url) {
  test('Local Discovery - Advertise and Scan', () async {
    // Advertise
    Client advertiseClient = new Client(application.connectToService, mojoUrl);
    Advertisement input =
        new Advertisement(interfaceName, ['/h1:123/x', '/h1:123/y']);
    input.attributes['myAttr1'] = 'myAttrValue1';
    input.attributes['myAttr2'] = 'myAttrValue2';
    String attachmentContent = new List.generate(500, (_) => 'X').join();
    input.attachments['myAttachment'] = UTF8.encode(attachmentContent);
    Advertiser advertiser = await advertiseClient.advertise(input);

    // Scan
    Client scanClient = new Client(application.connectToService, mojoUrl);
    Scanner scanner =
        await scanClient.scan('v.InterfaceName = "$interfaceName"');
    Update update = await scanner.onUpdate.first;

    expect(update.updateType, equals(UpdateTypes.found));
    expect(update.id, isNotEmpty);
    expect(update.interfaceName, equals(interfaceName));
    expect(update.addresses, equals(input.addresses));
    expect(update.attributes, equals(input.attributes));
    expect(UTF8.decode(await update.fetchAttachment('myAttachment')),
        equals(attachmentContent));
    expect(update.fetchAttachment('badAttachmentKey'), throwsArgumentError);

    // Clean up
    await advertiser.stop();
    await scanner.stop();
  });

  // TODO(aghassemi): Multiple mojo connections seem to hange in Dart
  // Test passes on its own but not when combined with the test above.
  // Disabling for now until the mojo issues is resolved.
  // test('Global Discovery - Advertise and Scan', () async {
  //   const String path = 'a/b';
  //   const Duration ttl = const Duration(seconds: 10);
  //   const Duration scanInterval = const Duration(seconds: 1);
  //
  //   // Advertise
  //   // Gloabl discovery only supports address.
  //   Client advertiseClient = new Client.global(
  //       application.connectToService, mojoUrl, path,
  //       ttl: ttl);
  //   Advertisement input = new Advertisement('', ['/h1:123/x', '/h1:123/y']);
  //   Advertiser advertiser = await advertiseClient.advertise(input);
  //
  //   // Scan
  //   Client scanClient = new Client.global(
  //       application.connectToService, mojoUrl, path,
  //       scanInteral: scanInterval);
  //   Scanner scanner = await scanClient.scan('');
  //   Update update = await scanner.onUpdate.first;
  //
  //   expect(update.updateType, equals(UpdateTypes.found));
  //   expect(update.id, isNotEmpty);
  //   expect(update.addresses, equals(input.addresses));
  //
  //   // Clean up
  //   await advertiser.stop();
  //   await scanner.stop();
  // });
}
