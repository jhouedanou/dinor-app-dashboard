/**
 * Composant AuthModal - Modal d'authentification
 */

import React, { useState } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  Modal, 
  TouchableOpacity, 
  TextInput,
  Alert,
  KeyboardAvoidingView,
  Platform
} from 'react-native';
import { useAuthStore } from '@/stores/authStore';
import DinorIcon from '@/components/icons/DinorIcon';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

interface AuthModalProps {
  visible: boolean;
  onClose: () => void;
  onAuthenticated: (user: any) => void;
}

const AuthModal: React.FC<AuthModalProps> = ({
  visible,
  onClose,
  onAuthenticated,
}) => {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);

  const { login, register } = useAuthStore();

  const handleSubmit = async () => {
    if (!email || !password || (!isLogin && !name)) {
      Alert.alert('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    setLoading(true);

    try {
      if (isLogin) {
        const result = await login({ email, password });
        if (result.success) {
          onAuthenticated(result.user);
          onClose();
        } else {
          Alert.alert('Erreur', result.error || 'Erreur de connexion');
        }
      } else {
        const result = await register({ name, email, password });
        if (result.success) {
          onAuthenticated(result.user);
          onClose();
        } else {
          Alert.alert('Erreur', result.error || 'Erreur d\'inscription');
        }
      }
    } catch (error: any) {
      Alert.alert('Erreur', error.message || 'Une erreur est survenue');
    } finally {
      setLoading(false);
    }
  };

  const resetForm = () => {
    setEmail('');
    setPassword('');
    setName('');
  };

  const toggleMode = () => {
    setIsLogin(!isLogin);
    resetForm();
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <KeyboardAvoidingView 
        style={styles.overlay}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <View style={styles.container}>
          <View style={styles.header}>
            <TouchableOpacity style={styles.closeButton} onPress={onClose}>
              <DinorIcon name="close" size={24} color={COLORS.DARK_GRAY} />
            </TouchableOpacity>
            <Text style={styles.title}>
              {isLogin ? 'Connexion' : 'Inscription'}
            </Text>
          </View>

          <View style={styles.content}>
            {!isLogin && (
              <TextInput
                style={styles.input}
                placeholder="Nom complet"
                value={name}
                onChangeText={setName}
                autoCapitalize="words"
              />
            )}

            <TextInput
              style={styles.input}
              placeholder="Email"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
            />

            <TextInput
              style={styles.input}
              placeholder="Mot de passe"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />

            <TouchableOpacity
              style={[styles.submitButton, loading && styles.submitButtonDisabled]}
              onPress={handleSubmit}
              disabled={loading}
            >
              <Text style={styles.submitButtonText}>
                {loading ? 'Chargement...' : (isLogin ? 'Se connecter' : 'S\'inscrire')}
              </Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.toggleButton} onPress={toggleMode}>
              <Text style={styles.toggleButtonText}>
                {isLogin ? 'Pas de compte ? S\'inscrire' : 'Déjà un compte ? Se connecter'}
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  container: {
    backgroundColor: COLORS.WHITE,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingBottom: 40,
    maxHeight: '80%',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: DIMENSIONS.SPACING_4,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.BACKGROUND,
  },
  closeButton: {
    width: 44,
    height: 44,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    flex: 1,
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.DARK_GRAY,
    textAlign: 'center',
    marginRight: 44, // Compenser le bouton fermer
  },
  content: {
    padding: DIMENSIONS.SPACING_4,
  },
  input: {
    borderWidth: 1,
    borderColor: COLORS.BACKGROUND,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    padding: DIMENSIONS.SPACING_4,
    marginBottom: DIMENSIONS.SPACING_4,
    fontSize: TYPOGRAPHY.fontSize.md,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  submitButton: {
    backgroundColor: COLORS.PRIMARY_RED,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    padding: DIMENSIONS.SPACING_4,
    alignItems: 'center',
    marginTop: DIMENSIONS.SPACING_4,
  },
  submitButtonDisabled: {
    opacity: 0.6,
  },
  submitButtonText: {
    color: COLORS.WHITE,
    fontSize: TYPOGRAPHY.fontSize.md,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  toggleButton: {
    alignItems: 'center',
    marginTop: DIMENSIONS.SPACING_4,
  },
  toggleButtonText: {
    color: COLORS.PRIMARY_RED,
    fontSize: TYPOGRAPHY.fontSize.sm,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
});

export default AuthModal; 