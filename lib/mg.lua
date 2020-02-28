--[[ cheapskate lib for getting midi grid devices to behave like monome grid devices
     two things are run before returning, `setup_connect_handling()` and `update_devices()`.
     `setup_connect_handling()` copies over 'og' midi "add" and "remove" callbacks, and
     provides its own add and remove handlers, i.e. the call backs for:
       - `midi.add()`
       - `midi.remove()`
       - `midi.update_devices()`
     `find_midi_device_id()` iterates through `midi.devices` to see if the name matches, then
     returns `id`, this system manages its own ids, which is why you have to initialize it and
     why first, you connect to it (`midigrid.connect()`), which returns a midigrid object and
     does `set_midi_handler()`
]]

--local midigrid = include('midigrid/lib/base')
local vgrid = include('midigrid/lib/vgrid')
local supported_devices = include('midigrid/lib/supported_devices')

local midigrid = {
  vgrid = vgrid,
  core_grid = grid,
  core_midi_add = nil,
  core_midi_remove = nil,

}

function midigrid.init(layout)
  midigrid.vgrid.init(layout)
end

function midigrid._find_midigrid_devices()
  local found_device = nil
  local mounted_devices = {}

  print("core midi devices")
  tab.print(midi.devices)

  for _, dev in pairs(midi.devices) do
    found_device = supported_devices.find_midi_device_type(dev)
    print("Dev" .. dev.id .." FD "..found_device)

    if found_device then mounted_devices[dev.id] = found_device end
  end

  print("mounted_devices")
  tab.print(mounted_devices)

  return mounted_devices
end

function midigrid._load_midi_devices(midi_devs)
  local connected_devices = {}
  for midi_id,midi_device_type in pairs(midi_devs) do
    print("Loading midi device type:" .. midi_device_type .. " on midi port " .. midi_id)
    local device = include('midigrid/devices/'..midi_device_type)
    device.midi_id = midi_id
    connected_devices[midi_id] = device
  end
  
  return connected_devices
end

function midigrid.connect(dummy_id)
  if midigrid.vgrid == nil then
    -- User is calling connect without calling init, default to 64 button layout
    midigrid.vgrid = vgrid.init('64')
  end

  local midi_devices = midigrid._find_midigrid_devices()

  -- If no midi devices found
  if #midi_devices == 0 then
       print('No supported device found')
       -- Make midigrid transparent if no devices found and return the core grid connect()
       return midigrid.core_grid.connect()
  end

  local connected_devices = midigrid._load_midi_devices(midi_devices)
  
  print("Connected devices:")
  tab.print(connected_devices)
  
  vgrid:attach_devices(connected_devices)

  midigrid.setup_connect_handling()

  return midigrid
end

function midigrid.setup_connect_handling()
    midigrid.core_midi_add = midi.add
    midigrid.core_midi_remove = midi.remove
    midi.add = midigrid._handle_dev_add
    midi.remove = midigrid._handle_dev_remove
end

function midigrid._handle_dev_add(id, name, dev)
    midigrid.core_midi_add(id, name, dev)
    -- midigrid.update_devices()
end

function midigrid._handle_dev_remove(id)
    midigrid.core_midi_remove(id)
    -- midigrid.update_devices()
end

function midigrid.update_devices()
    --WTF does this do?
    midi.update_devices()
end

-- Grid emulation functions

function midigrid:rotate()
  --TODO Is there a sane way to implement this with multi device?
end

function midigrid:all(z)
  return self.vgrid:set_all(z)
end

function midigrid:led(x,y,z)
  return self.vgrid:set(x,y,z)
end

function midigrid:refresh()
  return self.vgrid:refresh()
end

return midigrid
