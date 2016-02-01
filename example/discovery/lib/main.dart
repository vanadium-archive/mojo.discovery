// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:v23discovery/discovery.dart' as discovery;
import 'package:flutter/services.dart' show shell;
import 'package:uuid/uuid.dart';

const String _discoveryMojoUrl =
    'https://discovery.mojo.v.io/discovery.mojo';

void main() {
  runApp(
    new MaterialApp(
      title: "Discovery Demo",
      routes: <String, RouteBuilder>{
        '/': (RouteArguments args) => new DiscoveryDemo()
      }
    )
  );
}

final discovery.Client _discoveryClient =
    new discovery.Client(shell.connectToService, _discoveryMojoUrl);

class DiscoveryDemo extends StatefulComponent {
  @override
  State createState() => new DiscoveryDemoState();
}

final String instanceName = 'sample${new Uuid().v4()}';
const String interfaceName = 'examples.discovery.sample';

// The color of the icon to signify that the action is running.
final highlightColor = Colors.blue[500];
class DiscoveryDemoState extends State {
  // The message to advertise.
  // TODO: After v23proxy works for dart send this via rpc rather than
  // attributes.
  String message = 'Hello world!';
  bool isAdvertising = false;
  bool isScanning = false;
  // The currently running advertisement.  This is used to stop the
  // advertisement when we are done.
  discovery.Advertiser adv = null;

  // The currently running scanner.  This is used to stop the
  // scanning when we are done.
  discovery.Scanner scanner = null;
  // A SplayTreeMap is used so the iteration order is stable.
  Map<String, String> foundMessages = new SplayTreeMap();

  Future _startAdvertising() async {
    Map<String, String> attrs = new Map();
    attrs['message'] = message;
    var service = new discovery.Service()
      ..attrs = attrs
      ..interfaceName = interfaceName
      ..instanceName = instanceName
      // TODO put in a real endpoint here.  An empty array results in an
      // advertisement error.
      ..addrs = ['localhost:4000'];
    adv = await _discoveryClient.advertise(service);
    setState(() { isAdvertising = true;});
  }

  Future _stopAdvertising() async {
    await adv?.stop();
    adv = null;
    setState(() { isAdvertising = false; });
  }

  void _toggleAdvertising() {
    if (!isAdvertising) {
      _startAdvertising();
    } else {
      _stopAdvertising();
    }
  }

  Future _maybeUpdateAdv() async {
    if (!isAdvertising) {
      return;
    }
    // Don't call _stopAdvertising so the button's background color doesn't
    // change briefly while we update the advertisement.
    await adv.stop();
    await _startAdvertising();
  }

  Future _startScanning() async {
    var query = 'v.InterfaceName = "${interfaceName}"';
    scanner = await _discoveryClient.scan(query);
    scanner.onUpdate.listen((update) {
      // Ignore advertisements for this device.
      if (update.service.instanceName == instanceName) {
        return;
      }
      setState(() {
        var instanceName = update.service.instanceName;
        if (update.updateType == discovery.UpdateType.found) {
          foundMessages[instanceName] = update.service.attrs['message'];
        } else {
          foundMessages.remove(instanceName);
        }
      });
    });
    setState(() { isScanning = true;});
  }

  Future _stopScanning() async {
    await scanner.stop();
    scanner = null;
    setState(() { isScanning = false; });
  }

  void _toggleScanning() {
    if (!isScanning) {
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  // Builds the row that contains the message input and the buttons to start
  // and stop discovery.
  Widget _buildButtonBar() {
    var advColor;
    if (isAdvertising) {
      advColor = highlightColor;
    }
    var advButton = new IconButton(
      icon: 'notification/tap_and_play',
      color: advColor,
      onPressed: _toggleAdvertising
    );


    var scanColor;
    if (isScanning) {
      scanColor = highlightColor;
    }
    var scanButton = new IconButton(
      icon: 'action/search',
      color: scanColor,
      onPressed: _toggleScanning
    );

    var input = new Input(
      initialValue: message,
      onChanged: (String value) {
        message = value;
        _maybeUpdateAdv();
      });
    return new Row(
      children: [
        new Text('Message'),
         new Flexible(child: input), advButton, scanButton]);
  }

  Widget build(BuildContext context) {
    List<Widget> children = [_buildButtonBar()];
    foundMessages.forEach((k, v) {
      children.add(new Text('${k}: ${foundMessages[k]}', key:new Key(k)));
    });

    return new Scaffold(
      toolBar: new ToolBar(
        center: new Text("Discovery Demo")
      ),
      body: new Material(
        child: new Column(children: children)
      )
    );
  }
}
