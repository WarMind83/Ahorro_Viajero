import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/budget_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/ad_manager.dart';
import 'services/consent_manager.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BudgetProvider>(create: (_) => BudgetProvider()),
        ChangeNotifierProvider<ExpenseProvider>(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider<AdManager>(
          create: (_) {
            final adManager = AdManager();
            // Verificar y mostrar el estado de los anuncios en el inicio
            Future.delayed(const Duration(seconds: 2), () {
              debugPrint('==================================================');
              debugPrint('ESTADO DE ANUNCIOS: ${adManager.isAdFree ? 'SIN ANUNCIOS (Compra activa)' : 'CON ANUNCIOS (Compra no realizada)'}');
              debugPrint('==================================================');
            });
            return adManager;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          // Inicializar la referencia del BudgetProvider en el ExpenseProvider
          final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
          final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
          expenseProvider.setBudgetProvider(budgetProvider);
          
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ahorro Viajero',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
              Locale('es', 'MX'),
            ],
            home: const ConsentWrapper(child: HomeScreen()),
          );
        }
      ),
    );
  }
}

class ConsentWrapper extends StatefulWidget {
  final Widget child;
  
  const ConsentWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  State<ConsentWrapper> createState() => _ConsentWrapperState();
}

class _ConsentWrapperState extends State<ConsentWrapper> {
  bool _dialogShown = false;
  
  @override
  void initState() {
    super.initState();
    // Verificar si hay que mostrar el diálogo de consentimiento
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConsentDialog();
    });
  }
  
  Future<void> _checkConsentDialog() async {
    // Verificar si ya se ha mostrado el diálogo
    final hasShownDialog = await ConsentManager.hasShownConsentDialog();
    
    // Si no se ha mostrado, mostrar el diálogo
    if (!hasShownDialog && mounted && !_dialogShown) {
      setState(() {
        _dialogShown = true;
      });
      
      final consent = await ConsentManager.showGdprConsentDialog(context);
      
      // Actualizar configuración de anuncios según el consentimiento
      if (mounted) {
        final adManager = Provider.of<AdManager>(context, listen: false);
        await adManager.setPersonalizedAds(consent);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}