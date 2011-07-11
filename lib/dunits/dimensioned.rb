
require 'matrix'

class DimensionMismatchException < Exception
end

class Dimensioned
    NUM_DIMS = 7 # length, mass, time, temperature, charge current, light intensity, moles
    
    NO_DIMS = Vector.elements(Array.new(NUM_DIMS, 0))
    @@consts = {}
    
    attr_accessor :value, :dimensions
    
    def initialize(value, dim = nil)
        @value = value
        @dimensions = ((dim)? dim : NO_DIMS).clone
        if(@dimensions.is_a? Array)
            @dimensions = Vector.elements(@dimensions)
        end
    end
    
    def dimensioned?(rhs)
        @dimensions != NO_DIMS
    end
    
    def dimensionless?(rhs)
        @dimensions == NO_DIMS
    end
    
    def +@()
        Dimensioned.new(@value, @dimensions)
    end
    
    def -@()
        Dimensioned.new(-@value, @dimensions)
    end
    
    def +(rhs)
        if(rhs.is_a? Dimensioned)
            if(@dimensions != rhs.dimensions)
                raise DimensionMismatchException
            end
            Dimensioned.new(@value + rhs.value, @dimensions)
        else
            if(self.dimensioned?)
                raise DimensionMismatchException
            end
            Dimensioned.new(@value + rhs, @dimensions)
        end
    end
    
    def -(rhs)
        if(rhs.is_a? Dimensioned)
            if(@dimensions != rhs.dimensions)
                raise DimensionMismatchException
            end
            Dimensioned.new(@value - rhs.value, @dimensions)
        else
            if(self.dimensioned?)
                raise DimensionMismatchException
            end
            Dimensioned.new(@value - rhs, @dimensions)
        end
    end
    
    def *(rhs)
        if(rhs.is_a? Dimensioned)
            Dimensioned.new(@value*rhs.value, @dimensions + rhs.dimensions)
        else
            Dimensioned.new(@value*rhs, @dimensions)
        end
    end
    
    def /(rhs)
        if(rhs.is_a? Dimensioned)
            Dimensioned.new(@value/rhs.value, @dimensions - rhs.dimensions)
        else
            Dimensioned.new(@value/rhs, @dimensions)
        end
    end
    
    def ==(rhs)
        @value == rhs.value && @dimensions == rhs.dimensions
    end
    
    def **(rhs)
        if(rhs.is_a? Dimensioned)
            if(rhs.dimensioned?)
                raise DimensionMismatchException
            end
            rhs = rhs.value
        end
        Dimensioned.new(@value**rhs, @dimensions*rhs)
    end
    
    def coerce(lhs)
        [Dimensioned.new(lhs, NO_DIMS), self]
    end
    
    def val(unit_name)
        unit = Units.lookup_unit(unit_name)
        if(@dimensions == unit.dimensions)
            @value/unit.value
        else
            raise DimensionMismatchException
        end
    end
    
    def to_s()
        "{#{@value}: #{@dimensions}}"
    end
    
end # class Dimensioned

class Numeric
    def [](a)
        if(a.is_a? Symbol)
            Units.lookup_unit(a)*self
        elsif(a.is_a? Dimensioned)
            a*self
        else
            raise "bad dimensioned unit parameter"
        end
    end
end

# dim(Nmeric, Symbol): numeric quantity in given units
# dim(Numeric, Dimensioned): numeric quantity in given units
# dim(Numeric): new undimensioned Dimensioned with given quantity
# dim(Symbol): lookup unit
def dim(a, b = nil)
    if(b && b.is_a?(Symbol))
        Units.lookup_unit(b)*a
    elsif(b && b.is_a?(Dimensioned))
        b*a
    elsif(a.is_a? Numeric)
        Dimensioned.new(a, Dimensioned::NO_DIMS)
    elsif(a.is_a? Symbol)
        Units.lookup_unit(a)
    else
        raise "bad dimensioned unit parameter"
    end
end
