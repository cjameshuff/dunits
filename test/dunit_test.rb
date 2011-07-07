require "test/unit"
require "dunit"

class TestDUnit < Test::Unit::TestCase
    def test_sanity
        true
    end
    
    def test_construction
        assert_not_nil(Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0]))
    end

    def test_lookup
        one =       Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0])
        radian =    Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0])
        steradian = Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0])
        meter =    Dimensioned.new(1, [1, 0, 0, 0, 0, 0, 0])
        kg =       Dimensioned.new(1, [0, 1, 0, 0, 0, 0, 0])
        gram =     Dimensioned.new(1.0/1000, [0, 1, 0, 0, 0, 0, 0])
        second =   Dimensioned.new(1, [0, 0, 1, 0, 0, 0, 0])
        kelvin =   Dimensioned.new(1, [0, 0, 0, 1, 0, 0, 0])
        ampere =   Dimensioned.new(1, [0, 0, 0, 0, 1, 0, 0])
        candela =  Dimensioned.new(1, [0, 0, 0, 0, 0, 1, 0])
        mol =      Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 1])
        
        assert_equal(meter.dimensions, dim(1.0, :meter).dimensions)
        assert_equal(meter.dimensions, dim(1.0, :kilometer).dimensions)
        assert_equal(meter.dimensions, dim(1.0, :foot).dimensions)
        
        assert_equal(kg.dimensions, dim(1.0, :kg).dimensions)
        assert_equal(kg.dimensions, dim(1.0, :gram).dimensions)
        assert_equal(gram.dimensions, dim(1.0, :gram).dimensions)
        
        assert_equal(second.dimensions, dim(1.0, :second).dimensions)
        
        assert_equal(kelvin.dimensions, dim(1.0, :kelvin).dimensions)
        
        assert_equal(ampere.dimensions, dim(1.0, :ampere).dimensions)
        
        assert_equal(candela.dimensions, dim(1.0, :candela).dimensions)
        
        assert_equal(mol.dimensions, dim(1.0, :mole).dimensions)
        
        assert_equal(mol.dimensions, dim(1.0, :mol).dimensions)
        
        b = Dimensioned.lookup_unit(:meter)
        puts "meter: #{Dimensioned.lookup_unit(:meter)}"
        puts "m: #{Dimensioned.lookup_unit(:m)}"
        puts "kilometer: #{Dimensioned.lookup_unit(:kilometer)}"
        puts "km: #{Dimensioned.lookup_unit(:km)}"
        
        puts "kilometer: #{dim(1, :kilometer)}"
    end

    def test_arithmetic
        a = dim(1.0)
        b = 5.0[:meter]
        c = 5.0[:meter]
        
        meter = Dimensioned.new(1, [1, 0, 0, 0, 0, 0, 0])
        meter2 = Dimensioned.new(1, [2, 0, 0, 0, 0, 0, 0])
        assert_equal(meter.dimensions, (b + c).dimensions)
        assert_equal(meter2.dimensions, (b*c).dimensions)
    end
end # class TestDUnit

