
require 'matrix'

class DimensionMismatchException < Exception
end

# Dimension symbols for those methods that use them:
# :l, :m, :t, :T, :c, :i, :mol

SI_PREFIX_ALIASES = {
    yotta: :yotta,
    Y: :yotta,
    zetta: :zetta,
    Z: :zetta,
    exa: :exa,
    E: :exa,
    peta: :peta,
    P: :peta,
    tera: :tera,
    T: :tera,
    giga: :giga,
    G: :giga,
    mega: :mega,
    M: :mega,
    kilo: :kilo,
    k: :kilo,
    hecto: :hecto,
    h: :hecto,
    deca: :deca,
    da: :deca,
    
    deci: :deci,
    d: :deci,
    centi: :centi,
    c: :centi,
    milli: :milli,
    m: :milli,
    micro: :micro,
    nano: :nano,
    n: :nano,
    pico: :pico,
    p: :pico,
    femto: :femto,
    f: :femto,
    atto: :atto,
    a: :atto,
    zepto: :zepto,
    z: :zepto,
    yocto: :yocto,
    y: :yocto
}
SI_PREFIX_ALIASES["\u03BC"] = :micro, # Unicode lower-case mu
SI_PREFIX_ALIASES["\u00B5"] = :micro, # Unicode "micro sign"
SI_PREFIX_ALIAS_NAMES = SI_PREFIX_ALIASES.keys

SI_PREFIX_PWRS = {
    yotta: 24,
    zetta: 21,
    exa: 18,
    peta: 15,
    tera: 12,
    giga: 9,
    mega: 6,
    kilo: 3,
    hecto: 2,
    deca: 1,
    
    deci: -1,
    centi: -2,
    milli: -3,
    micro: -6,
    nano: -9,
    pico: -12,
    femto: -15,
    atto: -18,
    zepto: -21,
    yocto: -24
}

SI_PREFIX_MULS = SI_PREFIX_PWRS.keys.inject({}) {|muls, pwr| muls[pwr] = 10**SI_PREFIX_PWRS[pwr]; muls}

class Dimensioned
    # Dimension indices
    LENGTH = 0
    MASS = 1
    TIME = 2
    TEMPERATURE = 3
    CURRENT = 4
    INTENSITY = 5
    MOLE = 6
    NUM_DIMS = 7
    
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
