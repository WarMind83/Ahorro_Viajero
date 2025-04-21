import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentManager {
  static const String _gdprConsentKey = 'gdpr_consent';
  static const String _ccpaOptOutKey = 'ccpa_opt_out';
  static const String _consentShownKey = 'consent_dialog_shown';

  // Obtener si el usuario ha dado consentimiento GDPR
  static Future<bool> hasGdprConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_gdprConsentKey) ?? false;
  }

  // Establecer consentimiento GDPR
  static Future<void> setGdprConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_gdprConsentKey, consent);
  }

  // Obtener si el usuario ha optado por no vender datos (CCPA)
  static Future<bool> hasCcpaOptOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ccpaOptOutKey) ?? false;
  }

  // Establecer opción de no vender datos (CCPA)
  static Future<void> setCcpaOptOut(bool optOut) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ccpaOptOutKey, optOut);
  }

  // Verificar si ya se ha mostrado el diálogo de consentimiento
  static Future<bool> hasShownConsentDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentShownKey) ?? false;
  }

  // Marcar que se ha mostrado el diálogo de consentimiento
  static Future<void> setConsentDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentShownKey, true);
  }

  // Mostrar diálogo de consentimiento GDPR
  static Future<bool> showGdprConsentDialog(BuildContext context) async {
    final bool hasConsent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Uso de datos y privacidad'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ahorro Viajero utiliza información de su dispositivo para mostrar anuncios personalizados y mejorar su experiencia.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esto incluye:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('Identificadores de dispositivo'),
              _buildBulletPoint('Datos de uso de la aplicación'),
              _buildBulletPoint('Información técnica sobre su dispositivo'),
              const SizedBox(height: 16),
              const Text(
                '¿Nos permite utilizar esta información para ofrecerle anuncios personalizados?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Puede cambiar esta configuración en cualquier momento desde los ajustes de la aplicación.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No permitir'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Permitir'),
          ),
        ],
      ),
    ) ?? false;

    await setGdprConsent(hasConsent);
    await setConsentDialogShown();
    
    return hasConsent;
  }

  static Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}