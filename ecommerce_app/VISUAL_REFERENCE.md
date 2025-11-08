# Modern Furniture Theme - Quick Visual Reference

## 🎨 Color Swatches

```
┌─────────────────────────────────────────────────────┐
│ PRIMARY PALETTE                                     │
├─────────────────────────────────────────────────────┤
│ ███ Charcoal Black  #2C2C2C  - Main text           │
│ ███ Walnut Brown    #6B4423  - Primary brand color │
│ ███ Warm Beige      #E8DCC4  - Secondary/borders   │
│ ███ Off-White       #FAF8F5  - Background          │
├─────────────────────────────────────────────────────┤
│ ACCENT PALETTE                                      │
├─────────────────────────────────────────────────────┤
│ ███ Soft Gray       #9E9E9E  - Body text           │
│ ███ Olive Green     #6B7C59  - Accent (organic)    │
│ ███ Terracotta      #CE8B70  - Accent (warmth)     │
│ ███ Light Gray      #F5F5F5  - Cards               │
└─────────────────────────────────────────────────────┘
```

## 📐 Spacing System

All spacing uses multiples of 4px for consistency:

```
4px   - Micro spacing (icon padding)
8px   - Small spacing (between elements)
12px  - Medium-small (chip spacing)
16px  - Medium (card padding, section gaps)
20px  - Medium-large (grid spacing)
24px  - Large (section padding, grid gaps)
32px  - Extra large (button padding horizontal)
40px  - Hero section padding
```

## 🔤 Typography Scale

```
POPPINS FONT FAMILY
├─ 32px / W600 / -0.5 letter → Headlines (Hero)
├─ 24px / W600 / 0.0 letter → Section Titles
├─ 20px / W600 / 0.5 letter → Page Headers
├─ 17px / W700 / 0.3 letter → Product Prices
├─ 16px / W600 / 0.2 letter → Product Names
├─ 16px / W400 / 0.0 letter → Body Text
├─ 14px / W500 / 0.3 letter → Labels, Captions
└─ 12px / W600 / 1.2 letter → Badges, Tags
```

## 🔘 Border Radius Guide

```
Component              Radius    Usage
──────────────────────────────────────────────
Cards                  20px      Product cards, containers
Buttons                16px      All button types
Input Fields           16px      Text inputs, search
Category Chips         24px      Pill-shaped filters
Badges                 20px      Admin status indicators
Small Elements         8px       Tooltips, micro UI
Decorative Lines       2px       Accent elements
```

## 🎭 Elevation & Shadows

```
Level  Usage                    Shadow
──────────────────────────────────────────────────
0      Flat elements            No shadow
1      App bar                  0px 1px 3px rgba(0,0,0,0.05)
2      Buttons                  0px 2px 4px rgba(0,0,0,0.08)
3      Cards (default)          0px 3px 8px rgba(0,0,0,0.08)
4      Cards (hover/active)     0px 4px 12px rgba(0,0,0,0.12)
6      Floating buttons         0px 6px 16px rgba(0,0,0,0.15)
```

## 📱 Responsive Breakpoints

```
Screen Size          Columns    Grid Spacing    Notes
──────────────────────────────────────────────────────
< 800px (Mobile)        2       20px × 24px     Portrait/small
800-1200px (Tablet)     3       20px × 24px     Landscape/tablet
> 1200px (Desktop)      4       20px × 24px     Full desktop
```

## 🎨 Component Styles

### App Bar
```
Background:   White (#FFFFFF)
Foreground:   Charcoal Black (#2C2C2C)
Elevation:    1
Height:       56px (default)
Icon size:    24px
```

### Product Card
```
Background:   White (#FFFFFF)
Border:       None (uses shadow)
Radius:       20px
Elevation:    4
Aspect:       0.68 (w:h ratio)
Image ratio:  4/6 of card height
Info ratio:   2/6 of card height
```

### Buttons (Elevated)
```
Background:   Walnut Brown (#6B4423)
Text:         White (#FFFFFF)
Padding:      16px × 32px
Radius:       16px
Font:         16px / W600 / 0.5 letter
```

### Category Chips
```
Selected:
  - Background: Walnut Brown (#6B4423)
  - Text: White (#FFFFFF)
  - Shadow: 0px 2px 8px rgba(107,68,35,0.2)
  
Unselected:
  - Background: White (#FFFFFF)
  - Border: 1.5px Warm Beige (#E8DCC4)
  - Text: Charcoal Black (#2C2C2C)
```

### Badge (Admin)
```
Available:
  - Background: Olive Green (#6B7C59)
  - Icon: check_circle
  
Unavailable:
  - Background: Terracotta (#CE8B70)
  - Icon: cancel
  
Common:
  - Text: White (#FFFFFF)
  - Font: 11px / W600 / 0.3 letter
  - Padding: 10px × 6px
  - Radius: 20px
```

## 🎯 Icon Usage

```
Style:        Outlined (for modern, minimal look)
Size:         24px (standard), 48-64px (empty states)
Color:        Charcoal Black (#2C2C2C) or contextual

Common Icons:
├─ shopping_bag_outlined     → Cart
├─ receipt_long_outlined     → Orders
├─ dashboard_outlined        → Admin
├─ person_outline            → Profile
├─ chair_outlined            → Furniture/empty state
├─ inventory_2_outlined      → Products
└─ forum_outlined            → Chat/support
```

## 📊 Grid Layout Visualization

### Mobile (2 columns)
```
┌────────┬────────┐
│ Card 1 │ Card 2 │
│        │        │
├────────┼────────┤
│ Card 3 │ Card 4 │
│        │        │
└────────┴────────┘
Spacing: 20px horizontal, 24px vertical
```

### Tablet (3 columns)
```
┌──────┬──────┬──────┐
│ C1   │ C2   │ C3   │
├──────┼──────┼──────┤
│ C4   │ C5   │ C6   │
└──────┴──────┴──────┘
```

### Desktop (4 columns)
```
┌────┬────┬────┬────┐
│ C1 │ C2 │ C3 │ C4 │
├────┼────┼────┼────┤
│ C5 │ C6 │ C7 │ C8 │
└────┴────┴────┴────┘
```

## 🎪 State Variations

### Product Card States

**Normal:**
- White background
- Shadow elevation 4
- Full color image

**Unavailable:**
- Black overlay at 65% opacity
- "OUT OF STOCK" badge (white background)
- Price with strikethrough

**Hover (Web):**
- Beige tint overlay at 10% opacity
- Cursor: pointer

**Loading:**
- Light gray placeholder (#F5F5F5)
- Circular progress indicator (walnut brown)

**Error:**
- Light gray background
- Chair icon in beige (#E8DCC4)
- "Image unavailable" text

## 🏷️ Text Hierarchy Example

```
┌──────────────────────────────────────────────┐
│  Timeless Design                  ← 32px/W700│
│  Curated furniture for modern living  ← 16px │
│  ▬▬▬▬                              ← 3px line│
├──────────────────────────────────────────────┤
│  [All] [Living Room] [Bedroom]    ← 14px/W600│
├──────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐            │
│  │   IMAGE    │  │   IMAGE    │            │
│  │            │  │            │            │
│  ├────────────┤  ├────────────┤            │
│  │ Name  15px │  │ Name  15px │ ← W600     │
│  │ ₱1,999 17px│  │ ₱1,999 17px│ ← W700     │
│  └────────────┘  └────────────┘            │
└──────────────────────────────────────────────┘
```

## ✨ Animation Guidelines (Future Enhancement)

Suggested durations for smooth interactions:
```
Fast:    150ms  - Hover effects, color changes
Normal:  300ms  - Card elevation, scale transforms
Slow:    500ms  - Page transitions, fades

Curves:
├─ easeInOut    → Standard interactions
├─ easeOut      → Entrances, expansions
└─ easeIn       → Exits, collapses
```

---

**Quick Reference Card Created:** November 8, 2025  
**For:** Modern Furniture E-Commerce Theme  
**Framework:** Flutter (Material 3 + Google Fonts)
