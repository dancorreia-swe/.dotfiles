return {
  black = 0xff181819,
  white = 0xffe2e2e3,
  red = 0xfff38ba8, -- Changed to catuppcin red
  green = 0xff9ed072,
  blue = 0xff76cce0,
  yellow = 0xffe7c664,
  orange = 0xfff39660,
  purple = 0xffcba6f7,
  magenta = 0xffb39df3,
  grey = 0xff7f8490,
  base = 0xff1e1e2e,
  transparent = 0x00000000,
  surface = 0xff45475a,
  surface_zero = 0xff313244,

  bar = {
    bg = 0xcf181825,
    border = 0xff2c2e34,
  },
  popup = {
    bg = 0xc02c2e34,
    border = 0xff7f849
  },
  bg1 = 0xff363944,
  bg2 = 0xff414550,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
