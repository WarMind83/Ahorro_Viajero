import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clase para gestionar los anuncios en la aplicación
class AdManager with ChangeNotifier {
  // Claves para SharedPreferences
  static const String _keyAdFree = 'ad_free';
  static const String _keyPersonalizedAds = 'personalized_ads';

  // IDs de los anuncios (se deben reemplazar por los IDs reales en producción)
  static String get _bannerAdUnitId {
    if (kReleaseMode) {
      // IDs de producción
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Reemplazar con ID real
    } else {
      // IDs de prueba
      return 'ca-app-pub-3940256099942544/6300978111'; // ID de prueba de Google
    }
  }

  static String get _interstitialAdUnitId {
    if (kReleaseMode) {
      // IDs de producción
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'; // Reemplazar con ID real
    } else {
      // IDs de prueba
      return 'ca-app-pub-3940256099942544/1033173712'; // ID de prueba de Google
    }
  }

  // Estado de los anuncios
  bool _isAdFree = false;
  bool _personalizedAds = true;
  bool _adsInitialized = false;

  // Anuncios actuales
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  
  // Contador para mostrar anuncios intersticiales
  int _interstitialAdCounter = 0;
  static const int _interstitialAdFrequency = 3; // Mostrar cada 3 acciones

  // Getters
  bool get isAdFree => _isAdFree;
  bool get personalizedAds => _personalizedAds;
  bool get adsInitialized => _adsInitialized;
  BannerAd? get bannerAd => _bannerAd;

  // Constructor
  AdManager() {
    _initAds();
  }

  // Inicializar anuncios
  Future<void> _initAds() async {
    await _loadPreferences();
    
    if (!_isAdFree) {
      MobileAds.instance.initialize().then((_) {
        _adsInitialized = true;
        _loadBannerAd();
        _loadInterstitialAd();
        notifyListeners();
      }).catchError((error) {
        debugPrint('Error al inicializar los anuncios: $error');
      });
    }
  }

  // Cargar preferencias del usuario
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAdFree = prefs.getBool(_keyAdFree) ?? false;
      _personalizedAds = prefs.getBool(_keyPersonalizedAds) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar preferencias: ${e.toString()}');
    }
  }

  // Establecer estado sin anuncios
  Future<void> setAdFree(bool adFree) async {
    if (_isAdFree == adFree) return;
    
    _isAdFree = adFree;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAdFree, adFree);
      
      if (adFree) {
        // Eliminar los anuncios si se ha activado modo sin anuncios
        _disposeBannerAd();
        _disposeInterstitialAd();
      } else if (_adsInitialized) {
        // Volver a cargar anuncios si se desactiva el modo sin anuncios
        _loadBannerAd();
        _loadInterstitialAd();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al establecer estado sin anuncios: ${e.toString()}');
    }
  }

  // Establecer preferencia de anuncios personalizados (GDPR)
  Future<void> setPersonalizedAds(bool personalized) async {
    if (_personalizedAds == personalized) return;
    
    _personalizedAds = personalized;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyPersonalizedAds, personalized);
      
      // Recargar anuncios con la nueva configuración
      if (!_isAdFree && _adsInitialized) {
        _disposeBannerAd();
        _disposeInterstitialAd();
        _loadBannerAd();
        _loadInterstitialAd();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al establecer preferencia de anuncios personalizados: ${e.toString()}');
    }
  }

  // Cargar un anuncio de banner
  void _loadBannerAd() {
    if (_isAdFree || !_adsInitialized) return;
    
    _disposeBannerAd();
    
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(nonPersonalizedAds: !_personalizedAds),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('Banner ad loaded');
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          _bannerAd = null;
          notifyListeners();
        },
      ),
    );
    
    _bannerAd!.load();
  }

  // Cargar un anuncio intersticial
  void _loadInterstitialAd() {
    if (_isAdFree || !_adsInitialized) return;
    
    _disposeInterstitialAd();
    
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: AdRequest(nonPersonalizedAds: !_personalizedAds),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('Interstitial ad loaded');
          
          // Configurar callback para cerrar
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd(); // Volver a cargar para próximo uso
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd(); // Volver a cargar para próximo uso
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  // Mostrar un anuncio intersticial
  Future<bool> showInterstitialAd() async {
    if (_isAdFree || !_adsInitialized) return false;
    
    // Incrementar contador y verificar frecuencia
    _interstitialAdCounter++;
    if (_interstitialAdCounter < _interstitialAdFrequency) return false;
    
    // Reiniciar contador
    _interstitialAdCounter = 0;
    
    // Verificar si existe el anuncio
    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return false;
    }
    
    // Mostrar anuncio
    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('Error al mostrar anuncio intersticial: ${e.toString()}');
      _loadInterstitialAd();
      return false;
    }
  }

  // Disponer el anuncio de banner
  void _disposeBannerAd() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
  }

  // Disponer el anuncio intersticial
  void _disposeInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
      _interstitialAd = null;
    }
  }

  // Limpiar recursos
  @override
  void dispose() {
    _disposeBannerAd();
    _disposeInterstitialAd();
    super.dispose();
  }
}