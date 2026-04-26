return {
  rosewater = 0xfff5e0dc,
  flamingo = 0xfff2cdcd,
  pink = 0xfff5c2e7,
  mauve = 0xffcba6f7,
  red = 0xfff38ba8,
  maroon = 0xffeba0ac,
  peach = 0xfffab387,
  yellow = 0xfff9e2af,
  green = 0xffa6e3a1,
  teal = 0xff94e2d5,
  sky = 0xff89dceb,
  sapphire = 0xff74c7ec,
  blue = 0xff89b4fa,
  lavender = 0xffb4befe,
  text = 0xffcdd6f4,
  subtext1 = 0xffbac2de,
  subtext0 = 0xffa6adc8,
  overlay2 = 0xff9399b2,
  overlay1 = 0xff7f849c,
  overlay0 = 0xff6c7086,
  surface2 = 0xff585b70,
  surface1 = 0xff45475a,
  surface0 = 0xff313244,
  base = 0xff1e1e2e,
  mantle = 0xff181825,
  crust = 0xff11111b,

  black = 0xff11111b,
  white = 0xffcdd6f4,
  orange = 0xfffab387,
  purple = 0xffcba6f7,
  magenta = 0xfff5c2e7,
  grey = 0xff7f849c,
  transparent = 0x00000000,
  surface = 0xff45475a,
  surface_zero = 0xff313244,

  bar = {
    bg = 0x8c181825,
    border = 0x66b4befe,
  },
  popup = {
    bg = 0xee1e1e2e,
    border = 0x80b4befe
  },
  bg_solid = 0xff313244,
  bg0 = 0xaa313244,
  bg05 = 0x66313244,
  bg1 = 0x3345475a,
  bg2 = 0x55b4befe,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
