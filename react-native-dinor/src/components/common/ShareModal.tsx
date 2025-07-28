/**
 * Composant ShareModal - Modal de partage
 */

import React from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  Modal, 
  TouchableOpacity, 
  ScrollView 
} from 'react-native';
import DinorIcon from '@/components/icons/DinorIcon';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

interface ShareModalProps {
  visible: boolean;
  onClose: () => void;
  title?: string;
  content?: string;
  url?: string;
}

const ShareModal: React.FC<ShareModalProps> = ({
  visible,
  onClose,
  title = 'Partager',
  content = '',
  url = '',
}) => {
  const shareOptions = [
    { name: 'WhatsApp', icon: '📱', action: () => console.log('Share to WhatsApp') },
    { name: 'Facebook', icon: '📘', action: () => console.log('Share to Facebook') },
    { name: 'Twitter', icon: '🐦', action: () => console.log('Share to Twitter') },
    { name: 'Email', icon: '📧', action: () => console.log('Share via Email') },
    { name: 'SMS', icon: '💬', action: () => console.log('Share via SMS') },
    { name: 'Copier le lien', icon: '📋', action: () => console.log('Copy link') },
  ];

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <View style={styles.container}>
          <View style={styles.header}>
            <TouchableOpacity style={styles.closeButton} onPress={onClose}>
              <DinorIcon name="close" size={24} color={COLORS.DARK_GRAY} />
            </TouchableOpacity>
            <Text style={styles.title}>{title}</Text>
            <View style={styles.placeholder} />
          </View>

          <ScrollView style={styles.content}>
            <View style={styles.shareOptions}>
              {shareOptions.map((option, index) => (
                <TouchableOpacity
                  key={index}
                  style={styles.shareOption}
                  onPress={option.action}
                >
                  <Text style={styles.shareIcon}>{option.icon}</Text>
                  <Text style={styles.shareText}>{option.name}</Text>
                </TouchableOpacity>
              ))}
            </View>
          </ScrollView>
        </View>
      </View>
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
    maxHeight: '70%',
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
  },
  placeholder: {
    width: 44,
  },
  content: {
    padding: DIMENSIONS.SPACING_4,
  },
  shareOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  shareOption: {
    width: '30%',
    alignItems: 'center',
    padding: DIMENSIONS.SPACING_4,
    marginBottom: DIMENSIONS.SPACING_4,
  },
  shareIcon: {
    fontSize: 32,
    marginBottom: 8,
  },
  shareText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    textAlign: 'center',
  },
});

export default ShareModal; 