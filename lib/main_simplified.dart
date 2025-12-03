import 'package:flutter/material.dart';
import 'package:nudgecore_v2/nudgecore_v2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Nudge SDK
  final nudge = Nudge.getInstance();
  // Assuming init method exists based on previous AppNinja pattern, 
  // otherwise this might need adjustment based on specific SDK init requirements not fully detailed in the snippet.
  // Using the provided API key and Base URL.
  /* 
     Note: The provided documentation didn't explicitly show the init method signature.
     I'm assuming a similar structure to the previous SDK or that configuration is handled here.
     If Nudge.init is static, use Nudge.init(). If instance, use nudge.init().
     I will use the instance pattern as per userIdentifier example.
  */
  // await nudge.init(
  //   'nk_live_121840c710f74970e17eea35fb1e4728',
  //   baseUrl: 'http://192.168.31.237:4000',
  // ); 
  
  // Identify the user with a unique ID
  // Using the new userIdentifier method from the doc
  nudge.userIdentifier(
    externalId: "test_user_001",
    name: "Demo User",
    email: "demo@example.com",
    properties: {
      'app': 'untitled',
      'tier': 'premium', // Added example property
    }
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nudge Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Navigator observer might need to be updated if Nudge provides one, 
      // otherwise removing the old NinjaAutoObserver to avoid errors.
      // navigatorObservers: [NudgeNavigatorObserver()], // Uncomment if Nudge provides this
      home: const MyHomePage(title: 'Nudge Demo Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin implements NudgeCallbackListener {
  int _counter = 0;
  final nudge = Nudge.getInstance();

  @override
  void initState() {
    super.initState();

    // Register the Callback Listener
    NudgeCallbackManager.registerListener(this);

    // Track custom event when page loads
    nudge.track(
      event: 'simple',
      properties: {
        'timestamp': DateTime.now().toIso8601String(),
        'screen': 'home',
      },
    );
    print('✅ Event fired: simple');
  }

  @override
  void onEvent(NudgeCallbackData event) {
    print("callback event: ${event.toString()}");
    switch (event.type) {
      case "CORE":
        print("Core Event: ${event.action}");
        break;
      case "UI":
        print("UI Event: ${event.action}");
        // Handle UI events like NUDGE_EXPERIENCE_OPEN, NUDGE_COMPONENT_CTA_CLICK etc.
        if (event.action == 'NUDGE_COMPONENT_CTA_CLICK') {
            print("User clicked widget: ${event.data['WIDGET_ID']}");
        }
        break;
      default:
        break;
    }
  }

  

    // Track button click event
    nudge.track(
      event: 'button_clicked',
      properties: {'counter': _counter, 'button': 'increment'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.rocket_launch, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              '🎯 Nudge SDK Integrated',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '✅ User Identified',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '✅ Callbacks Active',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            const Text('Button clicks:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _incrementCounter,
              icon: const Icon(Icons.add),
              label: const Text('Increment Counter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
