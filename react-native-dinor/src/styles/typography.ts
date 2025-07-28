export const TYPOGRAPHY = {
  fontFamily: {
    primary: 'Roboto',          // Identique Vue
    heading: 'OpenSans'         // Identique Vue (Open Sans)
  },
  fontSize: {
    sm: 12,                     // 12px exact
    md: 16,                     // 16px exact
    lg: 20,                     // 20px exact
    xl: 24                      // 24px exact
  },
  fontWeight: {
    normal: '400' as const,     // 400 exact
    medium: '500' as const,     // 500 exact  
    semibold: '600' as const,   // 600 exact
    bold: '700' as const        // 700 exact
  },
  lineHeight: {
    tight: 1.2,                 // 1.2 exact
    normal: 1.5,                // 1.5 exact
    relaxed: 1.7                // 1.7 exact
  }
} as const;