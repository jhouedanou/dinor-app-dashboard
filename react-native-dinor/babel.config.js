module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: [
    [
      'module-resolver',
      {
        root: ['./src'],
        extensions: ['.ios.js', '.android.js', '.js', '.ts', '.tsx', '.json'],
        alias: {
          '@': './src',
          '@/components': './src/components',
          '@/screens': './src/screens', 
          '@/navigation': './src/navigation',
          '@/styles': './src/styles',
          '@/stores': './src/stores',
          '@/services': './src/services',
          '@/utils': './src/utils'
        }
      }
    ],
    'react-native-reanimated/plugin' // OBLIGATOIRE en dernier
  ]
};