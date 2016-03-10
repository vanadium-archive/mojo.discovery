#!mojo mojo:dart_content_handler?strict=true
// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:mojo_apptest/apptest.dart';
import 'package:mojo/application.dart';

import 'package:v23discovery/discovery.dart';

main(List args, Object handleToken) {
  runAppTests(handleToken, [discoveryApptests]);
}

discoveryApptests(Application application, String url) {
  test('Advertise and Scan', () async {
    const String mojoUrl = 'https://mojo.v.io/discovery.mojo';
    const String interfaceName = 'v.io/myInterface';

    // Advertise
    Client client1 = new Client(application.connectToService, mojoUrl);
    Advertisement input = new Advertisement(
        interfaceName, ['v.io/myAddress1', 'v.io/myAddress2']);
    input.attributes['myAttr1'] = 'myAttrValue1';
    input.attributes['myAttr2'] = 'myAttrValue2';
    String attachmentContent = new List.generate(500, (_) => 'X').join();
    input.attachments['myAttachment'] = UTF8.encode(attachmentContent);
    Advertiser advertiser = await client1.advertise(input);

    // Scan
    Client client2 = new Client(application.connectToService, mojoUrl);
    Scanner scanner = await client2.scan('v.InterfaceName = "$interfaceName"');
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
}
