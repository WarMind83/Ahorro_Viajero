import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentManager {
  // Clave para almacenar el estado de consentimiento
  static const String _keyConsentShown = 'gdpr_consent_shown';
  static const String _keyConsentAccepted = 'gdpr_consent_accepted';

  // Verificar si ya se ha mostrado el diálogo de consentimiento
  static Future<bool> hasShownConsentDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyConsentShown) ?? false;
    } catch (e) {
      debugPrint('Error al verificar estado de consentimiento: ${e.toString()}');
      return false;
    }
  }

  // Verificar si el usuario ha aceptado anuncios personalizados
  static Future<bool> hasAcceptedPersonalizedAds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyConsentAccepted) ?? false;
    } catch (e) {
      debugPrint('Error al verificar aceptación de anuncios: ${e.toString()}');
      return false;
    }
  }

  // Mostrar diálogo de consentimiento GDPR
  static Future<bool> showGdprConsentDialog(BuildContext context) async {
    bool consent = false;
    
    // Mostrar diálogo
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad y Cookies'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta aplicación muestra anuncios personalizados para mantenerse gratuita. '
                'Utilizamos cookies y datos de navegación para personalizar anuncios y '
                'medir el rendimiento de la aplicación.'
              ),
              const SizedBox(height: 12),
              const Text(
                'Al aceptar, nos permite utilizar estos datos para mostrar anuncios más '
                'relevantes para ti. Si no aceptas, seguirás viendo anuncios, pero no estarán '
                'personalizados.'
              ),
              const SizedBox(height: 12),
              const Text(
                'En cualquier momento puedes cambiar esta configuración en los ajustes de la aplicación.'
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              consent = false;
              Navigator.of(context).pop();
            },
            child: const Text('Rechazar'),
          ),
          ElevatedButton(
            onPressed: () {
              consent = true;
              Navigator.of(context).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    
    // Guardar preferencias
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyConsentShown, true);
      await prefs.setBool(_keyConsentAccepted, consent);
    } catch (e) {
      debugPrint('Error al guardar consentimiento: ${e.toString()}');
    }
    
    return consent;
  }
}