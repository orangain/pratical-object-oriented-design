class Wheel
  attr_reader :rim, :tire

  def initialize(rim, tire)
    @rim = rim
    @tire = tire
  end

  def width
    rim + (tire * 2)
  end
end

class Gear
  attr_reader :chainring, :cog, :wheel, :observer
  def initialize(args)
    @chainring = args[:chainring]
    @cog = args[:cog]
    @wheel = args[:wheel]
    @observer = args[:observer]
  end

  def gear_inches
    ratio * wheel.width
  end

  def ratio
    chainring / cog.to_f
  end

  def set_cog(new_cog)
    @cog = new_cog
    changed
  end

  def set_chainring(new_chainring)
    @chainring = new_chainring
    changed
  end

  def changed
    observer.changed(chainring, cog)
  end

end

require 'minitest/autorun'

module DiameterizableInterfaceTest
  def test_implements_the_diameterizable_interface
    assert_respond_to(@object, :width)
  end
end

class DiameterDouble
  def width
    10
  end
end

class DiameterDoubleTest < MiniTest::Test
  include DiameterizableInterfaceTest

  def setup
    @object = DiameterDouble.new
  end
end

class WheelTest < MiniTest::Test
  include DiameterizableInterfaceTest

  def setup
    @wheel = @object = Wheel.new(26, 1.5)
  end

  def test_calculates_diameter
    wheel = Wheel.new(26, 1.5)
    assert_in_delta(29, wheel.width, 0.01)
  end
end

class GearTest < MiniTest::Test

  def setup
    @observer = MiniTest::Mock.new
    @gear = Gear.new(chainring: 52, cog: 11, observer: @observer)
  end

  def test_calculates_gear_inches
    gear = Gear.new(chainring: 52, cog: 11, wheel: DiameterDouble.new)
    assert_in_delta(47.27, gear.gear_inches, 0.01)
  end

  def test_notifies_observers_when_cogs_change
    @observer.expect(:changed, true, [52, 27])
    @gear.set_cog(27)
    @observer.verify
  end

  def test_notifies_observers_when_chanrings_change
    @observer.expect(:changed, true, [42, 11])
    @gear.set_chainring(42)
    @observer.verify
  end
end
