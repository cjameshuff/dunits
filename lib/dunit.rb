
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

SI_PREFIX_MULS = SI_PREFIX_PWRS.map {|key, pwr| 10**pwr}

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
    
    attr_accessor :value, :dimensions
    
    def initialize(value, dim = nil)
        @value = value
        @dimensions = ((dim)? dim : NO_DIMS).clone
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
        if(lhs.is_a? Dimensioned)
            [lhs, self]
        else
            [Dimensioned.new(lhs), self]
        end
    end
    
    def to_s()
        "{#{@value}: #{@dimensions}}"
    end

    def self.lookup_prefixed_unit(unit_name)
        # If no direct matches work, try a prefix-unit combination
        # Match start of string against SI_PREFIX_ALIASES.
        pfxs = SI_PREFIX_ALIAS_NAMES.find_all {|a| unit_name.start_with?(a)}
        
        # Return nil if no prefix
        if(pfxs.empty?)
            return nil
        end
        
        # If any prefixes match, look for units with remainder as name, trying each matched prefix
        # until a full match is found.
        matches = {}
        pfxs.each{|pfx|
            unit_sym = unit_name[pfx.length, unit_name.length].to_sym
            part_matches = @@units.keys.find_all {|u| u == unit_sym}
            if(!part_matches.empty?)
                matches[pfx] = part_matches
            end
        }
        matches
    end
    
    def self.lookup_unit(unit_name)
        # Look for match with full name.
        unit_sym = unit_name.to_sym
        matches = @@units.keys.find_all {|u| u == unit_sym}
        if(matches.empty?)
            matches = lookup_prefixed_unit(unit_name)
        end
        # No attempt made to disambiguate units with same name at present
        if(matches.empty?)
            raise "No match found for unit: #{unit_name}"
        end
        if(matches.length > 1)
            raise "Ambiguous unit string: #{unit_name}"
        end
        matches[0]
    end
    
    # TODO: handle instances where multiple units can share a name
    @@units = {}
    def self.def_unit(name, dunit)
        @@units[name.to_sym] = dunit
    end
    def self.def_unit_alias(name, base)
        @@units[name.to_sym] = @@units[base.to_sym]
    end
    
    def self.def_si_units()
        # Define base units.
        # kilogram is the actual base unit for deriving other units, but gram
        # is the unit defined to make handling prefixes easier.
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
        
        def_unit(:meter, meter)
        def_unit(:gram, gram)
        def_unit(:second, second)
        def_unit(:kelvin, kelvin)
        def_unit(:ampere, ampere)
        def_unit_alias(:amp, :ampere)
        def_unit(:candela, candela)
        def_unit(:mol, mol)
        def_unit_alias(:mole, :mol)
        def_unit(:radian, radian)
        def_unit(:steradian, steradian)
        
        
        def_unit_alias(:m, :meter)
        def_unit_alias(:g, :gram)
        def_unit_alias(:K, :kelvin)
        def_unit_alias(:A, :ampere)
        def_unit_alias(:cd, :candela)
        def_unit_alias(:rad, :radian)
        def_unit_alias(:sr, :steradian)
        
        # Derived units
        m = meter
        m2 = m*m
        
        s = second
        s2 = s*s
        
        newton = kg*m/s2
        joule = newton*m
        coulomb = s*ampere
        volt = joule/coulomb
        
        def_unit(:hertz, one/s)
        def_unit(:newton, kg*m/s2)
        def_unit(:pascal, newton/m2)
        def_unit(:joule, joule)
        def_unit(:watt, joule/s)
        def_unit(:coulomb, coulomb)
        def_unit(:volt, volt)
        def_unit(:farad, coulomb/volt)
        def_unit(:ohm, volt/ampere)
        def_unit(:siemens, ampere/volt)
        
        weber = joule/ampere
        def_unit(:weber, weber)
        def_unit(:tesla, weber/m2)
        def_unit(:henry, weber/ampere)
        
        def_unit(:lumen, candela) # cd/sr
        def_unit(:lux, candela/m2) # lm/m^2
        
        def_unit(:becquerel, one/s)
        def_unit(:gray, joule/kg)
        def_unit(:sievert, joule/kg)
        def_unit(:katal, mol/s)
        
        
        def_unit_alias(:Hz, :hertz)
        def_unit_alias(:N, :newton)
        def_unit_alias(:Pa, :pascal)
        def_unit_alias(:J, :joule)
        def_unit_alias(:W, :watt)
        def_unit_alias(:C, :coulomb)
        def_unit_alias(:V, :volt)
        def_unit_alias(:F, :farad)
        # def_unit_alias(:, :ohm)
        def_unit_alias(:S, :siemens)
        def_unit_alias(:Wb, :weber)
        def_unit_alias(:T, :tesla)
        def_unit_alias(:H, :henry)
        def_unit_alias(:lm, :lumen)
        def_unit_alias(:lx, :lux)
        def_unit_alias(:Bq, :becquerel)
        def_unit_alias(:Gy, :gray)
        def_unit_alias(:Sv, :sievert)
        def_unit_alias(:kat, :katal)
        
        
        # TODO: http://en.wikipedia.org/wiki/Non-SI_units_accepted_for_use_with_SI
        def_unit(:liter, Dimensioned.new(0.001, [3, 0, 0, 0, 0, 0, 0]))
        # various...TODO: Move to appropriate function
        # def_unit(:degree, Dimensioned.new(1, [0, 0, 0, 0, 0, 0, 0]))
    end
    
end # class Dimensioned

Dimensioned.def_si_units()

def dim(value, unit)
    Dimensioned.new(value, )
end
