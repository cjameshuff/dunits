
require 'matrix'

# Dimensions:
# :l, :m, :t, :T, :c, :i, :mol
class Dimensioned
    LENGTH = 0
    MASS = 1
    TIME = 2
    TEMPERATURE = 3
    CURRENT = 4
    INTENSITY = 5
    MOLE = 6
    NUM_DIMS = 7
    
    attr_accessor :value, :dimensions
    
    def initialize(val, dim = nil)
        @value = val
        @dimensions = (dim)? dim : Vector.elements(Array.new(NUM_DIMS, 0))
    end
    
    def check_dim(rhs)
        @dimensions == rhs.dimensions
    end
    
    def +@()
        self
    end
    
    def -@()
    end
    
    def +(rhs)
        if(check_dim(rhs))
            Dimensioned.new(@val + rhs.val, @dimensions)
        end
    end
    
    def -(rhs)
        if(check_dim(rhs))
            Dimensioned.new(@val - rhs.val, @dimensions)
        end
    end
    
    def *(rhs)
        Dimensioned.new(@val*rhs.val, @dimensions + rhs.dimensions)
    end
    
    def /(rhs)
        Dimensioned.new(@val/rhs.val, @dimensions - rhs.dimensions)
    end
    
    def **(rhs)
        
    end
end # class Dimensioned


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
    # '': :micro,
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

SI_PREFIX_MULS = SI_PREFIX_PWRS.map {|key, pwr| 10**pwr}

# SI units are derived using the kilogram as a base unit, but handling
# of prefixes is more convenient if grams are treated as a base.
SI_BASES = {
    meter:    Dimensioned.new(1, [1, 0, 0, 0, 0, 0, 0]),
    kilogram: Dimensioned.new(1, [0, 1, 0, 0, 0, 0, 0]),
    second:   Dimensioned.new(1, [0, 0, 1, 0, 0, 0, 0]),
    kelvin:   Dimensioned.new(1, [0, 0, 0, 1, 0, 0, 0]),
    ampere:   Dimensioned.new(1, [0, 0, 0, 0, 1, 0, 0]),
    candela:  Dimensioned.new(1, [0, 0, 0, 0, 0, 1, 0]),
    mole:     Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 1])
}

SI_BASENAMES = {
    meter:    Dimensioned.new(1, [1, 0, 0, 0, 0, 0, 0]),
    gram:     Dimensioned.new(1/1000, [0, 1, 0, 0, 0, 0, 0]),
    second:   Dimensioned.new(1, [0, 0, 1, 0, 0, 0, 0]),
    kelvin:   Dimensioned.new(1, [0, 0, 0, 1, 0, 0, 0]),
    ampere:   Dimensioned.new(1, [0, 0, 0, 0, 1, 0, 0]),
    candela:  Dimensioned.new(1, [0, 0, 0, 0, 0, 1, 0]),
    mole:     Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 1])
}


