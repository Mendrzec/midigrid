local launchpad = {
  -- here we have the 'grid'. this looks literally like the grid notes as they are on
  -- the device.
  -- note though, that a call to this table will look backwards, i.e, to get the
  -- visual x=1 and y=2, you have to enter midigrid[2][1], not the other way around!
  grid_notes = {
      {81, 82, 83, 84, 85, 86, 87, 88},
      {71, 72, 73, 74, 75, 76, 77, 78},
      {61, 62, 63, 64, 65, 66, 67, 68},
      {51, 52, 53, 54, 55, 56, 57, 58},
      {41, 42, 43, 44, 45, 46, 47, 48},
      {31, 32, 33, 34, 35, 36, 37, 38},
      {21, 22, 23, 24, 25, 26, 27, 28},
      {11, 12, 13, 14, 15, 16, 17, 18}
  },


  --[[ values here correspond to the launchpad mk2 led settings found in the programmer's
           reference.
       HOWEVER, the lp pro can do full rgb, so we'll take andvantage of that. this requires
           sending sysex, and lets us use the full 16 brightness levels. we'll use a table of
           values directly indexed by the value passed into the fn
       NOTE! Individual LED brightnesses only range from 0x0-0x3f (i.e. 0-63); 1/4 the
          resolution of what we're used to (i.e. 0x0-0xff or 0-255)
  ]]
  less_angry_rainbow = {
    {0x00,0x00,0x00},
    {0x00,0x09,0x19},
    {0x05,0x16,0x2f},
    {0x14,0x18,0x34},
    {0x08,0x07,0x21},
    {0x12,0x07,0x21},
    {0x19,0x04,0x22},
    {0x29,0x0e,0x2b},
    {0x1f,0x00,0x1a},
    {0x30,0x04,0x20},
    {0x34,0x08,0x19},
    {0x3f,0x15,0x1b},
    {0x3f,0x19,0x14},
    {0x3f,0x20,0x0e},
    {0x3c,0x26,0x0b},
    {0x37,0x2d,0x0b}
  },
  brightness_handler = function(self, val)
      return self.less_angry_rainbow[val + 1]
  end,

  --[[ this is the column of keys on the sides of the grid, not necessary for strict
       grid emulation but handy!
       the lp pro round buttons send midi ccs
  ]]
  -- top to bottom
  -- right side
  auxcol = {89, 79, 69, 59, 49, 39, 29, 19},

  -- here we set the buttons to use when switching quads in multi-quad mode
  upper_left_quad_button = 89,
  upper_right_quad_button = 79,
  lower_left_quad_button = 69,
  lower_right_quad_button = 59,

  -- table of device-specific capabilities
  caps = {
    -- can we use sysex to update the grid leds?
    sysex = true,
    -- is this an rgb device?
    rgb = true,
    -- can we double buffer?
    lp_double_buffer = false,
    -- do the edge buttons send cc?
    cc_edge_buttons = true
  },

  create_colourspec = function(self, led_index, color)
      return {0x03, tonumber(led_index), color[1], color[2], color[3]}
  end,

  -- ONLY FOR MIDIGRID 64
  all_led_sysex = function(self, color)
      local bytes = {}
      for k, v in pairs(self.grid_notes) do
        for j, note in pairs(v) do
          table.insert(bytes, 0x03)
          table.insert(bytes, note)
          table.insert(bytes, color[1])
          table.insert(bytes, color[2])
          table.insert(bytes, color[3])
        end
      end
      return self.do_sysex(bytes)
  end,

  wrap_colourspec_into_sysex = function(self, colourspec)
    local sysex = {0xf0, 0x00, 0x20, 0x29, 0x02, 0x0C, 0x03}
    -- This appends colourspec bytes to sysex, so SYSEX is RESULT
    -- for i=1, #colourspec do
    --   sysex[#sysex + 1] = colourspec[i]
    -- end
    -- sysex[#sysex + 1] = 0xf7
    -- return sysex

    -- This prepends sysex to colourspec bytes, so BYTES is RESULT
    for i = #sysex, 1, -1 do
      table.insert(colourspec, 1, sysex[i])
    end

    table.insert(colourspec, 0xf7)
    return colourspec
  end,

    -- For unknown reason(s), allows us to use Programmer mode; the other ports don't
    --    work for this.
    device_name = 'launchpad x 2'
}
return launchpad
