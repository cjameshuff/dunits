require "test/unit"
require "dunit"

class TestDUnit < Test::Unit::TestCase
  def test_sanity
      true
  end
  
  def test_construction
      assert_not_nil(Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0]))
      
  end
  
  def test_arithmetic
      a = 
      
  end
  
end

