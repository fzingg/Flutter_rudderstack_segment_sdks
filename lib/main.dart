import 'dart:io' show Platform;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app_firebase_emulator/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:rudder_sdk_flutter_platform_interface/platform.dart';
import 'package:rudder_sdk_flutter/RudderController.dart';

import 'package:flutter_segment/flutter_segment.dart';


const bool useEmulator = false;






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Segment.config(
    options: SegmentConfig(
      writeKey: '1GoiMgCYVKwws5fDCuhzt2wMmzvbtYfF',
      trackApplicationLifecycleEvents: false,
      amplitudeIntegrationEnabled: false,
      debug: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final RudderController rudderClient = RudderController.instance;
  String host = 'localhost';

  void __initialize() {
    MobileConfig mc = MobileConfig(autoCollectAdvertId: false);
    RudderConfigBuilder builder = RudderConfigBuilder();
    // builder.withFactory(RudderIntegrationAppcenterFlutter());
    // builder.withFactory(RudderIntegrationFirebaseFlutter());
    // builder.withFactory(RudderIntegrationBrazeFlutter());
    // builder.withFactory(RudderIntegrationAmplitudeFlutter());

    builder.withMobileConfig(mc);
    builder.withDataPlaneUrl("https://mindsetfrvk.dataplane.rudderstack.com");
    builder.withControlPlaneUrl("https://api.rudderlabs.com");
    builder.withLogLevel(RudderLogger.DEBUG);
    RudderOption options = RudderOption();
    //options.putIntegration("Amplitude", true);
    const String writeKey = "2Ip0ozDjJrKEWCLwsCa3Gpu9I7F";
    rudderClient.initialize(writeKey,config: builder.build(), options: options);
    setOutput("....");
    setOutput("initialize:\nwriteKey: $writeKey");
  }

  void __identify() {
    RudderTraits traits = RudderTraits()
        .putGender("Mr")
        .putFirstName("Frederic")
        .putLastName("ZINGG")
        .putPhone("913354670")
        .putBirthdayDate(DateTime.now())
        .putAge("47")
        .putEmail("fredzingg@gmail.com")
        .putCreatedAt("")
        .putDescription("Great developer")
        .putTitle("Consultant");

    Address address = Address();
    address.putCity("Silves");
    address.putCountry("Portugal");
    address.putStreet("22 Rua Francisco Pablos");
    address.putPostalCode("8300-157");
    address.putState("Faro");

    traits.putAddress(address);

    Company company = Company();
    company.putName("Mindset");
    company.putId("CompanyId1234556789");
    company.putIndustry("AI");

    traits.putCompany(company);

    traits.put("avatar","http://www.gravatar.com/avatar");

    const userId = "UserId123456789";

    rudderClient.identify(userId, traits: traits);
    setOutput(
        "identify : \nname:Frederic ZINGG\nage: 47\nemail:frederic@mindset.ai"
            "\nuserId: test_user_id\ntraits:empty");
  }


  void __track(String eventName) {
    RudderProperty property = RudderProperty();
    property.put("colour", "red");
    property.put("manufacturer", "hyundai");
    property.put("model", "i20");
    property.put("marks", [1, 2, 3, 4]);
    property.put("something nested", [
      {
        "nest_2": [76, 78],
        "nest_2_1": {"nest_2_2": "some val"}
      },
      {
        "string_arr": ["a", "b"]
      }
    ]);
    RudderOption options = RudderOption();
    options.putIntegration("All", true);
    options.putIntegration("Mixpanel", false);

    rudderClient.track(eventName,
        properties: property, options: options);

    setOutput(
        "track:\n\tproperty:\n\t\tcolour:red\n\t\tmanufacturer:hyundai\n\t\tmodel:i20"
            "\n\toptions:\n\t\tall:false\n\t\tMixpanel:false\n\tevent: $eventName");
  }


  void __screen() {
    RudderProperty screenProperty = RudderProperty();
    screenProperty.put("browser", "chrome");
    screenProperty.put("device", "mac book pro");
    rudderClient.screen("Walmart Cart web",
        category: "home", properties: screenProperty, options: null);

    setOutput(
        "screen:\n\tproperty:\n\t\tbrowser: chrome\n\t\tdevice: mac book pro\n\t\tname:Walmart Cart");
  }

  void __group() {
    RudderTraits groupTraits = RudderTraits();
    groupTraits.put("place", "kolkata");
    groupTraits.put("size", "fifteen");
    rudderClient.group("Integrations-Rudder", groupTraits: groupTraits);
    setOutput(
        "group\n\ttraits:\n\t\tplace:kolkata\n\t\tsize:fifteen\n\tid: Integrations-Rudder");
  }


  String _output = "";

  void setOutput(String text) {
    setState(() {
      _output = "output - $text";
    });
  }

  @override
  void didChangeDependencies() async{
    if (useEmulator) {
      db.useFirestoreEmulator(host, 8080);
      db.settings = const Settings(
        persistenceEnabled: false,
      );
    }

    await db.collection("users").doc("tadas").get().then((value) {
      setState(() {
        if (value.exists) {
          _counter = value.data()!['count'];
        }
      });
    });
    super.didChangeDependencies();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      incrementCounterEvents();
    });
  }

  void incrementCounterEvents() {
    db.collection("users").doc("tadas").set({'count': _counter});
    rudderstackTriggerEvents();
  }

  void rudderstackTriggerEvents() {

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: ()  {
                  Segment.track(
                    eventName: 'workflows',
                    properties: {
                      'property1': 'bar',
                      'property2': 1337,
                      'property3': true,
                    },
                  );
                },
                child: const Text('Segment track call')
            ),
            ElevatedButton(
                onPressed: () {
                  __initialize();
                },
                child: const Text('Initialize RudderStack SDK')
            ),
            ElevatedButton(
              onPressed: __identify,
              child: const Text('Identify call'),
            ),
            ElevatedButton(
              onPressed: () => __track("workflows"),
              child: const Text('Track workflows event'),
            ),
            ElevatedButton(
              onPressed: () => __track("journeys"),
              child: const Text('Track journeys event'),
            ),
            ElevatedButton(
              onPressed: __group,
              child: const Text('Group'),
            ),
            ElevatedButton(
                onPressed: _incrementCounter,
                child: const Icon(Icons.add)
            ),
            ElevatedButton(
              child: const Text('Rudder Context'),
              onPressed: () async {
                Map? context = await rudderClient.getRudderContext();
                setOutput(context.toString());
              },
            ),
            ElevatedButton(
              child: const Text('Set Advertsing ID'),
              onPressed: () {
                rudderClient.putAdvertisingId("899jj-hguscb");
                setOutput("Trying to set advertising id: 899jj-hguscb");
              },
            ),
            ElevatedButton(
              child: const Text('Set Device Token'),
              onPressed: () {
                rudderClient.putDeviceToken("device-token-format");
                setOutput("Trying to set device token: device-token-format");
              },
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$_output',
              style: Theme.of(context).textTheme.headline4,
            ),

          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



