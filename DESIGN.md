---
name: Democracy Core
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#434656'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737688'
  outline-variant: '#c3c5d9'
  surface-tint: '#004ced'
  primary: '#003ec7'
  on-primary: '#ffffff'
  primary-container: '#0052ff'
  on-primary-container: '#dfe3ff'
  inverse-primary: '#b7c4ff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#4b4e50'
  on-tertiary: '#ffffff'
  tertiary-container: '#636668'
  on-tertiary-container: '#e2e4e6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b7c4ff'
  on-primary-fixed: '#001452'
  on-primary-fixed-variant: '#0038b6'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#e0e3e5'
  tertiary-fixed-dim: '#c4c7c9'
  on-tertiary-fixed: '#191c1e'
  on-tertiary-fixed-variant: '#444749'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.2'
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

This design system is engineered to facilitate secure, high-stakes democratic participation. The brand personality is rooted in **Institutional Trust**, **Unbiased Neutrality**, and **Technical Precision**. It avoids decorative flourishes in favor of a "GovTech" aesthetic that prioritizes clarity, speed, and accessibility.

The visual style is **Corporate Modern**, leaning into high-contrast layouts and a structured grid. It evokes a sense of "digital infrastructure"—reliable, robust, and permanent. Every element is designed to minimize cognitive load, ensuring voters of all technical literacies can navigate the interface with absolute confidence in the security of their data.

## Colors

The palette is designed for maximum legibility and emotional stability.

*   **Primary (Royal Blue):** Used for navigation and primary brand identifiers. It represents authority and the steady hand of governance.
*   **Action (Emerald Green):** This is the "Success" and "Confirm" color. It is used sparingly for final submission actions and biometric confirmation to provide a positive, secure feedback loop.
*   **Surface & Neutrals:** We utilize a "Clean White" background strategy to ensure maximum contrast. Neutrals are cool-toned slates to maintain the professional, technological feel.
*   **Alerts:** High-visibility red (#EF4444) is reserved strictly for destructive actions or critical security warnings.

## Typography

This design system utilizes **Inter** exclusively to leverage its exceptional legibility at small sizes and its neutral, systematic character. 

Hierarchy is established through weight and scale rather than decorative shifts. For long-form text, such as ballot measures or legal terms, use `body-lg` to ensure readability for elderly users. Labels and micro-copy use `label-md` with a medium weight to differentiate them from interactive body text.

## Layout & Spacing

The system follows an **8px linear scale**, ensuring mathematical harmony across all components.

*   **Grid:** A 12-column fixed grid is used for desktop (max 1200px) to prevent line lengths from becoming unreadable. For mobile, a single-column fluid layout is used with 16px side margins.
*   **Rhythm:** Vertical spacing between sections should be generous (typically 64px or 80px) to create a sense of calm and prevent "information overwhelm."
*   **Alignment:** All interactive elements must align to the baseline grid to maintain a rigorous, engineered appearance.

## Elevation & Depth

This design system avoids heavy shadows and skeuomorphism to maintain a clean, "flat-modern" look. 

*   **Tonal Layering:** Depth is primarily communicated through surface color shifts. The main background is pure white (#FFFFFF), while secondary containers or "wells" use Tertiary Slate (#F8FAFC).
*   **Outlines:** Instead of shadows, use 1px solid borders (#E2E8F0) for cards and input fields.
*   **Active Elevation:** Only the primary Action buttons may use a subtle, high-diffusion shadow (0px 4px 12px, 10% opacity) to suggest interactability.
*   **Modal Overlays:** Use a heavy backdrop blur (12px) with a 40% opacity neutral tint to focus user attention entirely on critical security prompts or biometric requests.

## Shapes

The shape language is **Soft (Level 1)**. 

A 0.25rem (4px) base radius is applied to small components like checkboxes and inputs. For larger components like cards or buttons, a 0.5rem (8px) radius is used. This subtle rounding removes the aggressive "sharpness" of institutional software while retaining a serious, precise, and professional demeanor. It strikes the balance between "approachable" and "authoritative."